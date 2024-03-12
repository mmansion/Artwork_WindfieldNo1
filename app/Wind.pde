class Wind {
  public float direction = 0.0;
  public float speed = 0.0; //current wind speed

  float timeForSpeed = 0; // Initialize a time variable
  float timeForDirection = 0;


  //float windSpeed = 0; // Current wind speed
  float lastGustTime = 0; // When the last gust happened

  float noiseOffset = 0.0;
  float lastSensorCheck = 0;
  float lastUpdate = 0;
  boolean useSensorValue = false;

  //boolean useSensorValue = false;
  //float lastSensorCheck = -10000;
  float sensorCheckFrequency = 10000;//under run duration
  float sensorRunDuration = 5000;

  float gustOffset = 0.0; // Separate offset for gusts
  float lastGustCheck = 0; // Track when the last gust check occurred
  boolean isGusting = false; // Indicates if a gust is currently happening
  float gustDuration = 1000; // Duration of gust in milliseconds
  float gustStrength = 50.0; // Example gust strength

  boolean isCalm = false; // To track calm periods
  float calmDuration = 0; // Duration of calm periods
  float lastCalmCheck = millis(); // Last time calm period was checked

  JSONObject json = null;
  GetRequest get = new GetRequest("http://localhost:3000/api/wind");

  Wind() {
  }
  void update() {

    // set dynamic properties

    //println("Reponse Content: " + get.getContent());
    //println("Reponse Content-Length Header: " + get.ge/\tHeader("Content-Length"));

    //updateSpeed();
    updateSpeedSim(); //hotfix 240311

    driftDirection();
    direction+=0.1;
    //println(speed);
  }
  public float getDirection() { //called from Grid
    return this.direction + this.driftDirection();
  }
  float getSensorSpeed() { //called from  Wind.updateSpeed
    //return 10.0;
    return speed * getScaledValue(); //naturalizeWind();
  }
  float getScaledValue() {
    // Generate a random number between 0 and 1 to determine if we should scale
    float chance = random(1);

    // Approximately 10% of the time, scale the value up to 0.1
    if (chance < 0.1) {
      return 2.0; // Scale by multiplying the base value
    } else {
      // Remain around the base value most of the time
      // Add a small variation to make it "float" around 0.01

      return 1.0;
    }
  }
  void updateSpeedSim() {
    float currentTime = millis();

    // Check for calm periods
    if (!isCalm && currentTime - lastCalmCheck > random(20000, 40000)) { // Check for calm every 20-40 seconds
      if (random(1) < 0.1) { // 10% chance to start a calm period
        isCalm = true;
        calmDuration = random(5000, 10000); // Calm lasts between 5 and 10 seconds
        lastCalmCheck = currentTime; // Reset lastCalmCheck to current time
      }
    }

    if (isCalm) {
      //println("CALM");
      speed = lerp(speed, 0, 0.05); // Gradually decrease to zero for calm
      if (currentTime - lastCalmCheck > random(5000, 20000)) {
        isCalm = false; // End calm period
      }
    } else {
      // Regular wind behavior using Perlin noise
      float baseWind = map(noise(noiseOffset), 0, 1, WIND_MIN_SPD, WIND_MAX_SPD * 0.5);
      noiseOffset += 0.005; // Slow change for organic movement

      // Check and handle gusts
      handleGusts(currentTime);

      if (!isGusting) {
        // Transition back to base wind
        speed = lerp(speed, baseWind, 0.02);
      }

      // Enforce wind speed limits
      if (speed > WIND_MAX_SPD) {
        speed = WIND_MAX_SPD;
      } else if (speed < WIND_MIN_SPD) {
        speed = WIND_MIN_SPD;
      }
    }


    //println(speed); // Monitor wind speed
  }

  void handleGusts(float currentTime) {
    // Check for gusts
    if (currentTime - lastGustCheck > random(10000, 30000)) { // Check every 10-30 seconds
      lastGustCheck = currentTime;
      if (random(1) < 0.2) { // 20% chance to start a gust
        isGusting = true;
      }
    }

    if (isGusting) {
      println("GUSTING");
      // Use a higher gust strength and ensure it decays quickly after the gust duration
      float gustWind = map(noise(gustOffset), 0, 1, speed, gustStrength);
      gustOffset += 0.1; // Faster change for gust
      speed = lerp(speed, gustWind, 0.1); // Smooth transition to gust speed

      if (currentTime - lastGustCheck > gustDuration) {
        isGusting = false; // End gust after its duration
        gustOffset = 0.0; // Reset gust offset for the next gust
      }
    }
  }
  void updateSpeed() {

    if (useSensorValue) {
      speed = lerp(speed, speed+getScaledValue(), 2.5); // smoothly increase to sensor strength
      if (millis() - lastSensorCheck > sensorRunDuration) { // sensing duration
        useSensorValue = false;
      }
      //print("using sensor speed");
    } else {
      float idleWind = map(noise(noiseOffset), 0, 1, -1, 1);
      noiseOffset += 0.001; // Increment noise offset

      //// Check for gusts with reduced probability
      if (millis() - lastGustTime > random(10000, 30000) && random(1) < 0.01) { // Reduced probability for starting a gust
        isGusting = true;
        lastGustTime = millis();
      }

      if (isGusting) {
        speed = lerp(speed, gustStrength, 0.05); // Smoothly increase to gust strength
        if (millis() - lastGustTime > 500) { // Gust duration
          isGusting = false;
        }
      } else {
        speed = lerp(speed, idleWind, 0.1); // Return to idle wind behavior
      }

      speed *= driftSpeed();
      // speed = lerp(speed, driftSpeed(), 2.5); // smoothly increase to sensor strength
    }
    //TODO: lookup API speed
    if (millis() - lastSensorCheck > sensorCheckFrequency) {

      try {
        json = loadJSONObject(WIND_API_URL);
        if (json == null) {
          throw new Exception("Failed to load JSON object");
        }
      }
      catch (Exception e) {
        System.out.println("An error occurred: " + e.getMessage());
        // Handle the error, e.g., by loading a default JSON object, showing an error message, etc.
      }

      if (json != null) {
        speed = round(json.getFloat("speed"));
        direction = json.getFloat("direction");
      }




      println("speed = " + speed);
      println("direction = " + direction);

      sensorRunDuration = random(1000, 12000);
      lastSensorCheck = millis();
      useSensorValue = true;
    }
    if (speed > WIND_MAX_SPD) {
      speed = WIND_MAX_SPD;
    } else if (speed < WIND_MIN_SPD) {
      speed = 0.0; //turn
    }

    //println(speed);

    //speed += this.driftSpeed();
  }

  float driftSpeed() {
    // adjust time based on driftSpeed
    timeForSpeed += DRIFT_RATE_SPD;

    // generate perlin noise value for current time
    // add a base offset to ensure we explore different parts of the noise space
    float noiseValue = noise(timeForSpeed + 1000); // 1000 is arbitrary to offset in the noise space

    // map noise value to the desired drift range
    float drift = map(noiseValue, 0, 1, MIN_DRIFT_SPD, MAX_DRIFT_SPD);
    //println(drift);

    return drift;
  }
  float driftDirection() {
    // adjust time based on driftSpeed
    timeForDirection += DRIFT_RATE_DIR;

    // generate perlin noise value for current time
    // add a base offset to ensure we explore different parts of the noise space
    float noiseValue = noise(timeForDirection + 1000); // 1000 is arbitrary to offset in the noise space

    // map noise value to the desired drift range
    float drift = map(noiseValue, 0, 1, MIN_DRIFT_DIR, MAX_DRIFT_DIR);
    return drift;
  }
}
