# GeoVision System

GeoVision is a system designed for capturing infrastructure images, analyzing them using AI (Groq), and visualizing the results on a web dashboard with mapping and alert creation capabilities.

## System Architecture

1.  **Backend (Flask)**: Processes images using Google Gemini API and serves analysis results.
2.  **Web Dashboard (React/HTML)**: Displays the latest analysis, map location, and allows creating infrastructure alerts.
3.  **Mobile App (Flutter)**: Captures or uploads images and sends them to the backend.

---

## 1. Backend Setup (Flask)

### Prerequisites
- Python 3.8+
- A Google Gemini API Key ([Get one here](https://aistudio.google.com/app/apikey))

### Installation
1.  Navigate to the `backend` directory:
    ```bash
    cd backend
    ```
2.  Install dependencies:
    ```bash
    pip install -r requirements.txt
    ```
3.  Set up environment variables:
    - Copy `.env.example` to `.env`.
    - Add your `GEMINI_API_KEY` to the `.env` file.

### Running the Server
```bash
python app.py
```
The server will start at `http://localhost:5050`.

---

## 2. Web Dashboard Setup

The dashboard is a single-page website that interacts with the Flask API.

### How to Run
1.  Navigate to the `web` directory:
    ```bash
    cd web
    ```
2.  Open `dashboard.html` in any modern web browser.
3.  The dashboard will automatically poll the backend for the latest analysis results every 10 seconds.

---

## 3. Flutter Mobile App Setup

### Prerequisites
- Flutter SDK installed.
- Android Emulator or physical device connected.

### Installation
1.  Navigate to the `geo_vision_app` directory:
    ```bash
    cd geo_vision_app
    ```
2.  Install Flutter dependencies:
    ```bash
    flutter pub get
    ```

### Running the App
```bash
flutter run
```

> **Note for Android Emulators**: The app is configured to use `http://10.0.2.2:5050` to communicate with the Flask server running on your host machine.

---

## API Testing

### 1. Health Check
`GET http://localhost:5050/health`
Response: `{"status": "online"}`

### 2. Upload Image (Simulate Mobile App)
`POST http://localhost:5050/locate`
- Body: `multipart/form-data`
- Field: `image` (File)

### 3. Fetch Latest Result
`GET http://localhost:5050/latest_result`

### 4. Create Alert
`POST http://localhost:5050/create_alert`
- Body: `JSON`
  ```json
  {
    "asset_type": "Bridge",
    "severity": "High",
    "description": "Crack detected in main pillar.",
    "location": "Golden Gate Bridge"
  }
  ```
