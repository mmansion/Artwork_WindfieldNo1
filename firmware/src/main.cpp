#include <Arduino.h>
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
  float multiplex_delay = 0.1; //must be very short
  matrixControl.setup(multiplex_delay);

  //set bytes all to 0
  memset(bytes, 0, sizeof(bytes));
  // Initialize some example byte values
  bytes[2] = 0b10101010;
  bytes[3] = 0b01010101;

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
}
long lastRefresh = 0;
int matrixRefresh = 1000;
//------------------------------------------------------------
void loop() {
  olimexLAN->checkUDP(); //check for messages

  if(millis() - lastRefresh > matrixRefresh) {
    lastRefresh = millis();
    matrixControl.update(bytes);
    matrixControl.display();
  }
}