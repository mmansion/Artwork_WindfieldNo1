class Wind {
  public float direction = 0.0;
  public float speed = 0.0; //current wind speed

  float timeForSpeed = 0; // Initialize a time variable
  float timeForDirection = 0;


  //float windSpeed = 0; // Current wind speed
  float noiseOffset = random(10); // Offset for noise function
  float gustStrength = 3.0; // Maximum strength of wind gusts
  float lastGustTime = 0; // When the last gust happened
  float gustFrequency = 8; // How often gusts can occur, in seconds (increased for less frequent gusts)
  boolean isGusting = false; // Whether a gust is currently happening

  boolean useSensorValue = false;
  float lastSensorCheck = -10000;
  float sensorCheckFrequency = 10000;//under run duration
  float sensorRunDuration = 5000;

  JSONObject json = null;
  GetRequest get = new GetRequest("http://localhost:3000/api/wind");

  Wind() {
  }
  void update() {

    // set dynamic properties

    //println("Reponse Content: " + get.getContent());
    //println("Reponse Content-Length Header: " + get.ge/\tHeader("Content-Length"));

    updateSpeed();
    //updateDirection();
    //println(speed);
  }
  public float getDirection() { //called from Grid
    return this.direction + this.driftDirection();
  }
  float getSensorSpeed() { //called from  Wind.updateSpeed
    //return 10.0;
    return speed + getScaledValue(); //naturalizeWind();
  }
  float getScaledValue() {
    // Generate a random number between 0 and 1 to determine if we should scale
    float chance = random(1);

    // Approximately 10% of the time, scale the value up to 0.1
    if (chance < 0.1) {
      return 0.01; // Scale by multiplying the base value
    } else {
      // Remain around the base value most of the time
      // Add a small variation to make it "float" around 0.01
      return random(-0.002, 0.00002);
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
      if (millis() - lastGustTime > gustFrequency * 1000 && random(1) < 0.01) { // Reduced probability for starting a gust
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
