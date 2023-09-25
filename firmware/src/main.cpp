#include <Arduino.h>
//-----------------------------------------------
//PIN DEFINITIONS
#define dataPin  2 // SER
#define latchPin 4 // RCLK
#define clockPin 5 // SRCLK
//-----------------------------------------------
#include <iostream>

// #include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
#include <OlimexLAN.h>
#include <MatrixControl.h>
//-----------------------------------------------
unsigned char bytes[78]; //bytes set states of 16 points

//-----------------------------------------------
// setup OlimexLAN
// char *wifi_ssid = "";
// char *wifi_pwd = "";

//------------------------------------------------------------
// register this callback with olimexUDP instance
void onMessageReceived(String message)
{
  Serial1.println("onMessageReceived: " + message);

  // MatchState ms; // matchstate object (requirs regex lib)

  // byte maxBufLen = UDP_TX_PACKET_MAX_SIZE;

  // // search target
  // char buf[maxBufLen];
  // message.toCharArray(buf, maxBufLen);

  // // set target buffer
  // ms.Target(buf);

  // // setup your own commands here:

  // if (ms.Match("/test"))
  // {

  //   Serial.println("received test command");
  //   olimexLAN->sendOSC("received");
  // }
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

#define dataPin  2 // SER //important this pin doesn't interfere with Serial
#define latchPin 4 // RCLK
#define clockPin 5 // SRCLK

byte r;
byte c;

// storage variable
byte dataToSend;


bool ledStates[16];
unsigned long lastChangeTime = 0;
bool inHighState = false;
const unsigned long highStateDuration = 1000;  // 3 seconds
const unsigned long period = 5000;  // 10 seconds, for example

void setup() {

  Serial.begin(115200); 
  Serial.println("initiating...");
  delay(1000);

  //set bytes all to 0
  memset(bytes, 0, sizeof(bytes));

  //------------------------------------------------------------
  // 1. setup ethernet and wifi connections

  // olimexLAN = new OlimexLAN(wifi_ssid, wifi_pwd);
  olimexLAN = new OlimexLAN();
  olimexLAN->connectEth();
  // olimexLAN->connectWifi(wifi_ssid, wifi_pwd);

  // while (!wifi_connected) {
  //   delay(100);
  //   Serial.print(".");
  // }
  //------------------------------------------------------------
  // 2. setup "over the air" programming (works for eth or wifi)

  // olimexLAN->setupOTA();

  //------------------------------------------------------------
  // 3. setup UDP communications
  olimexLAN->setupUDP(localUdpPort);

  // register event handler for inbound messages
  // olimexLAN->onMessageReceived = onMessageReceived;


  // set pins as output
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
}

void updateLedStates(bool ledStates[16], unsigned char bytes[78], int n) {
    for(int i = 0; i < 16; i++) {
        // Determine which byte to use: n or n+1
        int byteIndex = n + (i / 8);
        // Calculate the index within the byte
        int bitIndex = i % 8;
        ledStates[i] = (bytes[byteIndex] & (1 << bitIndex)) != 0;
    }
}

void setPoint(int r, int c) {
  dataToSend = (1 << (r + 4)) | (15 & ~(1 << c));
  // for example when r = 2, c = 3,
      // dataToSend = (1 << 6) | (15 & ~(1 << 3));
      // dataToSend = 01000000 | (15 & ~(00001000));
      // dataToSend = 01000000 | (15 & 11110111);
      // dataToSend = 01000000 | (15 & 11110111);
      // dataToSend = 01000000 | 00000111;
      // dataToSend = 01000111;
      // the first four bits of dataToSend go to the four rows (anodes) of the LED matrix- only one is set high and the rest are set to ground
      // the last four bits of dataToSend go to the four columns (cathodes) of the LED matrix- only one is set to ground and the rest are high
      // this means that going through i = 0 to 3 and j = 0 to three with light up each led once

  // dataToSend = (1 << (7 - r)) | (15 & ~(1 << c)); //reverse rows
  // dataToSend = (1 << (7 - r)) | (15 & ~(1 << (3-c))); //reverse rows and columns


  // setlatch pin low so the LEDs don't change while sending in bits
  digitalWrite(latchPin, LOW);
      // shift out the bits of dataToSend to the 74HC595
  shiftOut(dataPin, clockPin, LSBFIRST, dataToSend);
      // set latch pin high- this sends data to outputs so the LEDs will light up
  digitalWrite(latchPin, HIGH);

  randomSeed(analogRead(0));
}

int row_inc = 0;
int col_inc = 0;

void turnOnLED(int r, int c) {
    byte dataToSend = (1 << (r + 4)) | (15 & ~(1 << c));
    // Send dataToSend to your multiplexer or LED driver.
    // The exact method will depend on your hardware setup.
     // setlatch pin low so the LEDs don't change while sending in bits
    digitalWrite(latchPin, LOW);
        // shift out the bits of dataToSend to the 74HC595
    shiftOut(dataPin, clockPin, LSBFIRST, dataToSend);
        // set latch pin high- this sends data to outputs so the LEDs will light up
    digitalWrite(latchPin, HIGH);
}

void iterateOverLEDs() {
    for (int r = 0; r < 4; r++) {
        for (int c = 0; c < 4; c++) {
            turnOnLED(r, c);
            delay(100); // Delay for 100ms to see the LED change. Adjust as needed.
        }
    }
}

byte ledValues[16] = {
  135, 139, 141, 142,
  71, 75, 77, 78,
  39, 43, 45, 46,
  23, 27, 29, 30
};

void setRandomValues() {
  for (int i = 0; i < 16; i++) {
    ledStates[i] = (random(100) < 25) ? 1 : 0; // 25% chance of being 1, 75% chance of being 0
  }
}


void clear() {
  digitalWrite(latchPin, LOW);
  // shift out the bits of dataToSend to the 74HC595
  shiftOut(dataPin, clockPin, LSBFIRST, 0b00000000);
  // set latch pin high- this sends data to outputs so the LEDs will light up
  digitalWrite(latchPin, HIGH);
}
void setAllHigh() {
  for (int i = 0; i < 16; i++) {
    ledStates[i] = 1;
  }
}
void setAllLow() {
  for (int i = 0; i < 16; i++) {
    ledStates[i] = 0;
  }
}


void loop() {
  // -----------------------------------------------
  
  // Initialize some example byte values
  bytes[2] = 0b11111111;
  bytes[3] = 0b10000001;

  updateLedStates(ledStates, bytes, 2);

  // Output the ledStates to verify
  for(int i = 0; i < 16; i++) {
    std::cout << "LED " << i << ": " << (ledStates[i] ? "ON" : "OFF") << std::endl;
  }

  // -----------------------------------------------

  // Serial.println("looping...");

  olimexLAN->checkUDP();
  // iterateOverLEDs();

  
  
  unsigned long currentTime = millis();
  
  if (!inHighState && currentTime - lastChangeTime > period) {
    lastChangeTime = currentTime;
    inHighState = true;
  } else if (inHighState && currentTime - lastChangeTime > highStateDuration) {
    lastChangeTime = currentTime;
    inHighState = false;
  }

  if(!inHighState) {
    setRandomValues();
  } else {
    setAllLow();
    // setAllHigh();
  }
  
  // delay(100);

  // for (r = 0; r < 4; r++)
  // {
  //   for (c = 0; c < 4; c++)
  //   {
  //     setPoint(r, c);
  //     delay(10);
  //   }
  // }
  // byte value = 0b11110000;
  // // setlatch pin low so the LEDs don't change while sending in bits
  // digitalWrite(latchPin, LOW);
  //     // shift out the bits of dataToSend to the 74HC595
  // shiftOut(dataPin, clockPin, LSBFIRST, value);
  //     // set latch pin high- this sends data to outputs so the LEDs will light up
  // digitalWrite(latchPin, HIGH);
 
}



