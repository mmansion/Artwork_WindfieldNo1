require('dotenv').config();
const AmbientWeatherApi = require('ambient-weather-api');
const express = require('express');
const app = express();
const port = 3000; // You can choose any port that suits your setup

// Global variable to store wind speed and direction
let windData = {
  speed: 3,
  direction: 300
};

// helper function
function getName(device) {
  return device.info.name;
}

const apiKey = process.env.AMBIENT_WEATHER_API_KEY || 'Put your AW apiKey here';
const api = new AmbientWeatherApi({
  apiKey,
  applicationKey: process.env.AMBIENT_WEATHER_APPLICATION_KEY || 'Put your AW applicationKey here'
});

api.connect();
api.on('connect', () => console.log('Connected to Ambient Weather Realtime API!'));

api.on('subscribed', data => {
  console.log('Subscribed to ' + data.devices.length + ' device(s): ');
  console.log(data.devices.map(getName).join(', '));
});

api.on('data', data => {
  console.log(data.date + ' - ' + getName(data.device) + ' current outdoor temperature is: ' + data.tempf + '°F');
  // Update windData with the latest speed and direction
  windData.speed = data.windspeedmph; // Assuming 'windspeedmph' is the property name for wind speed
  windData.direction = data.winddir; // Assuming 'winddir' is the property name for wind direction
});

api.subscribe(apiKey);

// API endpoint to retrieve the latest wind speed and direction
app.get('/api/wind', (req, res) => {
  res.json(windData);
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
