#include <Arduino.h>
#include <FastLED.h>
//-----------------------------------------------
//PIN DEFINITIONS
#define DATA_PIN  2 // SER
#define LATCH_PIN 4 // RCLK
#define CLOCK_PIN 5 // SRCLK

//-----------------------------------------------
//CONSTANTS
#define NUM_POINTS 16
#define NUM_BYTES 78
#define NUM_MCU 39 //no of MCU sculpture panels

//-----------------------------------------------
const int BPM = 120; //beats per minute
long last_tick = 0;

const float n_32nd = 0.125;
const float n_16th = 0.25;
const float n_8th  = 0.5;
const float n_4th  = 1.0;

float  note_len; //4th, 8th, 16th or 32nd
double bpms = 0.0;
//-----------------------------------------------
#include <iostream>

// #include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
#include <OlimexLAN.h>
#include <MatrixControl.h>
//-----------------------------------------------
unsigned char bytes[78]; //bytes set states of 16 points

// remote communication settings (UDP/OSC)
IPAddress remoteUdpIp = IPAddress(10,1,0,8); //receiver cpu
const int remoteUdpPort = 8020;
const int localUdpPort  = 7010;

// localIp assigned by router when OlimexLAN connects eth
OlimexLAN *olimexLAN;
MatrixControl matrixControl;

//------------------------------------------------------------
// register this callback with olimexUDP instance
void onMessageReceived(String message) {
  Serial1.println("onMessageReceived: " + message);
}
void onConnect(String ip) {
  Serial.println("onConnect: " + ip);
  matrixControl.setID(ip);
}
//------------------------------------------------------------
void setup() {
  Serial.begin(115200); 
  Serial.println("initiating...");
  delay(1000);

  //------------------------------------------------------------
  // setup matrixControl
  float multiplex_delay = 0.0; //must be very short
  matrixControl.setup(multiplex_delay);

  //set bytes all to 0
  memset(bytes, 0, sizeof(bytes));
  // Initialize some example byte values
  bytes[2] = 0b00000000;
  bytes[3] = 0b00001000;

  //-----------------------
  // Setup olimexLAN
  olimexLAN = new OlimexLAN();
  olimexLAN->onConnect = onConnect;
  olimexLAN->connectEth();

  // register event handler for inbound messages
  olimexLAN->onMessageReceived = onMessageReceived;
  // olimexLAN->setupOTA(); //TODO: over the air programming
  olimexLAN->setupUDP(localUdpPort);

  //-----------------------
  // set pins as output
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);
  pinMode(DATA_PIN, OUTPUT);

  //-----------------------
  // initial state
  // turn off all points on init
  matrixControl.setAllLow();
  matrixControl.display();

  //-----------------------
  //set bpm and note length
  bpms = float(1000/(BPM/60));
  note_len = n_32nd;

  randomSeed(analogRead(0));
}
//------------------------------------------------------------
void setRandomBits() {

  // For bytes[2] and bytes[3]
  for (int i = 2; i <= 3; i++) {
    // Iterate over each bit in the byte
    for (int b = 0; b < 8; b++) {
      if (random(100) < 25) {
        // Set the bit with 25% probability
        bytes[i] |= (1 << b);
      } else {
        // Clear the bit with 75% probability
        bytes[i] &= ~(1 << b);
      }
    }
  }
}

uint16_t x = 0;
long last_period_start = 0;
long last_period_end = 0;

int period_duration = 2000;
int period_interval = 6000;

bool started_period = false;
float frequency = 1000.0;

float lerp(float a, float b, float t) {
  return a + t * (b - a);
}
//------------------------------------------------------------
void loop() {
  olimexLAN->checkUDP(); //check for messages

  float frequency = 1000.0; //set high
  
  long time = millis();

  if(!started_period && time - last_period_end > period_interval) {
    Serial.println("starting period");
    started_period = true;
    last_period_start = time;

  } else if(started_period && time - last_period_start < period_duration) {
    Serial.println("in period");

    // Generate Perlin noise value
    uint8_t noiseValue = inoise8(x, 0);

    // Map the noise value from range [0, 255] to [0, 1]
    float noiseFloat = noiseValue / 255.0;

    // Bias the noise value towards 0 (100 in the mapped range)
    // Applying square root for bias towards lower values.
    // noiseFloat = sqrt(noiseFloat);
    noiseFloat = noiseFloat * noiseFloat * noiseFloat;  // Cubing for stronger bias towards 500.

    // Map the noise value to the desired range [10, 500]
    frequency = lerp(1, 62, noiseFloat);

    // Output the frequency
    if(frequency < 62.0) {
      Serial.println(frequency);
    }

    x += 10; // Adjust the step size for noticeable changes in noise values.
  } else if(started_period && time - last_period_start > period_duration) {
    Serial.println("ending period");
    started_period = false;
    last_period_end = time;
    frequency = 1000.0; //set high
  }

  // Serial.println(float(bpms * note_len), DEC);
  if(time - last_tick > frequency || /*whichever is shorter*/
     time - last_tick > float(bpms * note_len)) {
    setRandomBits();
    last_tick = millis();
    matrixControl.update(bytes);
    matrixControl.display();  
  }
}