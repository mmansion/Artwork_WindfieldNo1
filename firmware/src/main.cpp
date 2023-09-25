#include <Arduino.h>
//-----------------------------------------------
//PIN DEFINITIONS
#define DATA_PIN  2 // SER
#define LATCH_PIN 4 // RCLK
#define CLOCK_PIN 5 // SRCLK
//-----------------------------------------------
#include <iostream>

// #include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
#include <OlimexLAN.h>
#include <MatrixControl.h>
//-----------------------------------------------
unsigned char bytes[78]; //bytes set states of 16 points

//------------------------------------------------------------
// register this callback with olimexUDP instance
void onMessageReceived(String message) {
  Serial1.println("onMessageReceived: " + message);
}

// remote communication settings (UDP/OSC)
WiFiUDP etheretUdp;

// test ip (manually set your computer to this addr to test)
IPAddress remoteUdpIp = IPAddress(10,1,0,8); // 192.168.86.20

const int remoteUdpPort = 8020;
const int localUdpPort = 7010;

// localIp assigned by router when OlimexLAN connects eth

// LAN class object
OlimexLAN *olimexLAN;

#define DATA_PIN  2 // SER //important this pin doesn't interfere with Serial
#define LATCH_PIN 4 // RCLK
#define CLOCK_PIN 5 // SRCLK

byte r;
byte c;

// storage variable
byte dataToSend;


bool ledStates[16];
unsigned long lastChangeTime = 0;
bool inHighState = false;
const unsigned long highStateDuration = 1000;  // 3 seconds
const unsigned long period = 5000;  // 10 seconds, for example

MatrixControl matrixControl;

void setup() {

  Serial.begin(115200); 
  Serial.println("initiating...");
  delay(1000);

  //------------------------------------------------------------
  // Setup MatrixControl
  float multiplex_delay = 1.0; //must be very short
  matrixControl.setup(multiplex_delay);

  //set bytes all to 0
  memset(bytes, 0, sizeof(bytes));

  //------------------------------------------------------------
  // Setup OlimexLAN
  olimexLAN = new OlimexLAN();
  olimexLAN->connectEth();

  // olimexLAN->setupOTA(); //TODO: over the air programming
  olimexLAN->setupUDP(localUdpPort);

  // register event handler for inbound messages
  // olimexLAN->onMessageReceived = onMessageReceived;
  //------------------------------------------------------------
  // set pins as output
  pinMode(LATCH_PIN, OUTPUT);
  pinMode(CLOCK_PIN, OUTPUT);
  pinMode(DATA_PIN, OUTPUT);


  //------------------------------------------------------------
  // Initialize some example byte values
  bytes[2] = 0b11000000;
  bytes[3] = 0b00000011;

  //------------------------------------------------------------
  // initial state
  // turn off all points on init
  matrixControl.setAllLow();
  matrixControl.display();
}

void loop() {
  // matrixControl.update(bytes, 2);
  // matrixControl.display();
  olimexLAN->checkUDP(); //check for messages
}



