#include <Arduino.h>
// #include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
#include <OlimexLAN.h>
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

// LED TEST w/ 74HC595
// by Amanda Ghassaei 2012
// https://www.instructables.com/id/Multiplexing-with-Arduino-and-the-74HC595/

/*
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 */

// this code will light up each led in the 4x4 matrix one at a time


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
float t = 1;
float tt = 50;
void loop() {

  // Serial.println("looping...");

  olimexLAN->checkUDP();
  // iterateOverLEDs();

  //iterate over ledValues
  for (int i = 0; i < 16; i++) {
    if(ledStates[i] == 1) {
      // setlatch pin low so the LEDs don't change while sending in bits
      digitalWrite(latchPin, LOW);
          // shift out the bits of dataToSend to the 74HC595
      shiftOut(dataPin, clockPin, LSBFIRST, ledValues[i]);
          // set latch pin high- this sends data to outputs so the LEDs will light up
      digitalWrite(latchPin, HIGH);
      delay(t);
    } else {
      delay(t);
    }
    
    // delay(1000);
  }
  clear();
  delay(tt);
  
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



