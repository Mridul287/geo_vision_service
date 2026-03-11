import os
import json
import base64
from flask import Flask, request, jsonify
from flask_cors import CORS
from dotenv import load_dotenv
from groq import Groq
from PIL import Image
import io

load_dotenv()

app = Flask(__name__)
CORS(app)

# Configure Groq
api_key = os.getenv("GROQ_API_KEY")
model_name = os.getenv("GROQ_MODEL", "llama-3.2-11b-vision-preview")
if api_key:
    client = Groq(api_key=api_key)
else:
    print("Warning: GROQ_API_KEY not found in environment variables.")

# Global storage for the latest result
latest_result = None

def analyze_image(image_bytes):
    """
    Analyzes the image using Groq (Llama Vision) and returns a structured JSON response.
    """
    try:
        # Encode image to base64
        base64_image = base64.b64encode(image_bytes).decode('utf-8')
        
        prompt = """
        Analyze this image of infrastructure or a location. 
        Identify the landmark or location.
        Return the result strictly as a JSON object with the following fields:
        - location (name of the place)
        - city
        - country
        - lat (latitude, float)
        - lng (longitude, float)
        - confidence (float between 0 and 1)
        - clues (list of strings describing visual cues)
        - description (a brief paragraph about the location)
        
        If you cannot identify the location precisely, provide your best estimate based on visual cues.
        """
        
        completion = client.chat.completions.create(
            model=model_name,
            messages=[
                {
                    "role": "user",
                    "content": [
                        {"type": "text", "text": prompt},
                        {
                            "type": "image_url",
                            "image_url": {
                                "url": f"data:image/jpeg;base64,{base64_image}",
                            },
                        },
                    ],
                }
            ],
            temperature=0.1,
            max_tokens=1024,
            top_p=1,
            stream=False,
            response_format={"type": "json_object"}
        )
        
        # Extract JSON from response
        result = json.loads(completion.choices[0].message.content)
        return result
    except Exception as e:
        print(f"Error analyzing image with Groq: {e}")
        return None

@app.route('/locate', methods=['POST'])
def locate():
    global latest_result
    if 'image' not in request.files:
        return jsonify({"error": "No image part"}), 400
    
    file = request.files['image']
    if file.filename == '':
        return jsonify({"error": "No selected file"}), 400
    
    try:
        image_bytes = file.read()
        result = analyze_image(image_bytes)
        
        if result:
            latest_result = result
            return jsonify(result), 200
        else:
            return jsonify({"error": "Failed to analyze image"}), 500
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/latest_result', methods=['GET'])
def get_latest_result():
    if latest_result:
        return jsonify(latest_result), 200
    else:
        return jsonify({"error": "No results yet"}), 404

@app.route('/create_alert', methods=['POST'])
def create_alert():
    data = request.json
    print(f"Alert Created: {data}")
    # For now, just mock the creation
    return jsonify({"message": "Alert created successfully."}), 201

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "online"}), 200

if __name__ == '__main__':
    # host='0.0.0.0' allows the server to be accessible from other devices on the same network
    app.run(host='0.0.0.0', port=5050, debug=True)
