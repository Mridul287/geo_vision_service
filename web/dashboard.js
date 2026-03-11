const API_BASE_URL = 'http://localhost:5050';

let map;
let marker;

function initMap() {
    // Default to SF
    map = L.map('map').setView([37.7749, -122.4194], 13);
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
}

function updateMap(lat, lng) {
    if (marker) {
        marker.setLatLng([lat, lng]);
    } else {
        marker = L.marker([lat, lng]).addTo(map);
    }
    map.setView([lat, lng], 15);
}

async function checkHealth() {
    try {
        const response = await axios.get(`${API_BASE_URL}/health`);
        if (response.data.status === 'online') {
            document.getElementById('status-banner').classList.add('hidden');
        }
    } catch (error) {
        document.getElementById('status-banner').classList.remove('hidden');
    }
}

async function fetchLatestResult() {
    const loading = document.getElementById('loading');
    const errorContainer = document.getElementById('error-container');
    const resultSection = document.getElementById('result-section');
    const analysisContent = document.getElementById('analysis-content');

    loading.classList.remove('hidden');
    errorContainer.classList.add('hidden');

    try {
        const response = await axios.get(`${API_BASE_URL}/latest_result`);
        const data = response.data;

        document.getElementById('location-name').textContent = data.location;
        document.getElementById('city-country').textContent = `${data.city}, ${data.country}`;
        document.getElementById('lat').textContent = data.lat.toFixed(4);
        document.getElementById('lng').textContent = data.lng.toFixed(4);
        document.getElementById('confidence-val').textContent = `${(data.confidence * 100).toFixed(0)}%`;
        document.getElementById('confidence-bar').style.width = `${(data.confidence * 100)}%`;
        document.getElementById('description').textContent = data.description;

        // Populate form
        document.getElementById('location').value = `${data.location}, ${data.city}, ${data.country}`;
        document.getElementById('alert_description').value = data.description;

        const cluesContainer = document.getElementById('clues-container');
        cluesContainer.innerHTML = '';
        data.clues.forEach(clue => {
            const chip = document.createElement('div');
            chip.className = 'clue-chip';
            chip.textContent = clue;
            cluesContainer.appendChild(chip);
        });

        updateMap(data.lat, data.lng);
        analysisContent.classList.remove('hidden');
        loading.classList.add('hidden');
    } catch (error) {
        loading.classList.add('hidden');
        if (error.response && error.response.status === 404) {
            // No results yet, just stay quiet
        } else {
            errorContainer.classList.remove('hidden');
        }
    }
}

document.getElementById('retry-btn').addEventListener('click', fetchLatestResult);

document.getElementById('alert-form').addEventListener('submit', async (e) => {
    e.preventDefault();
    const submitBtn = document.getElementById('submit-alert');
    const successMsg = document.getElementById('alert-success');

    const formData = {
        asset_type: document.getElementById('asset_type').value,
        severity: document.getElementById('severity').value,
        description: document.getElementById('alert_description').value,
        location: document.getElementById('location').value
    };

    submitBtn.disabled = true;
    try {
        await axios.post(`${API_BASE_URL}/create_alert`, formData);
        successMsg.classList.remove('hidden');
        setTimeout(() => successMsg.classList.add('hidden'), 5000);
    } catch (error) {
        alert('Failed to create alert. Please try again.');
    } finally {
        submitBtn.disabled = false;
    }
});

// Initial load
initMap();
checkHealth();
fetchLatestResult();

// Poll for health and new results every 10 seconds
setInterval(() => {
    checkHealth();
    fetchLatestResult();
}, 10000);
