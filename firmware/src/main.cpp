#include <Arduino.h>
// #include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
#include <OlimexLAN.h>
//-----------------------------------------------
// setup OlimexLAN
char *wifi_ssid = "";
char *wifi_pwd = "";

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
IPAddress remoteUdpIp = IPAddress(192, 168, 86, 20); // 192.168.86.20

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

// pin connections- the #define tag will replace all instances of "latchPin" in your code with A1 (and so on)
#define latchPin 1 // RCLK
#define clockPin 3 // SRCLK
#define dataPin  0  // SER

// pin connections- the #define tag will replace all instances of "latchPin" in your code with A1 (and so on)
//  #define latchPin 1 //RCLK (register clock)
//  #define clockPin 3 //SRCLK (shift register clock)
//  #define dataPin  0 //SER (serial input)
// looping variables
byte i;
byte j;

// storage variable
byte dataToSend;

void setup()
{
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

    // olimexLAN->setupUDP(remoteUdpIp, remoteUdpPort, localUdpPort);

    // register event handler for inbound messages
    // olimexLAN->onMessageReceived = onMessageReceived;

    // set pins as output
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
}

void loop()
{
  return;//disable loop

  for (i = 0; i < 4; i++)
  {

    for (j = 0; j < 4; j++)
    {

      // bit manipulation (more info at http://arduino.cc/en/Reference/Bitshift ,  http://arduino.cc/en/Reference/BitwiseXorNot , and http://arduino.cc/en/Reference/BitwiseAnd)
      dataToSend = (1 << (i + 4)) | (15 & ~(1 << j)); // preprare byte (series of 8 bits) to send to 74HC595
      // for example when i =2, j = 3,
      // dataToSend = (1 << 6) | (15 & ~(1 << 3));
      // dataToSend = 01000000 | (15 & ~(00001000));
      // dataToSend = 01000000 | (15 & 11110111);
      // dataToSend = 01000000 | (15 & 11110111);
      // dataToSend = 01000000 | 00000111;
      // dataToSend = 01000111;
      // the first four bits of dataToSend go to the four rows (anodes) of the LED matrix- only one is set high and the rest are set to ground
      // the last four bits of dataToSend go to the four columns (cathodes) of the LED matrix- only one is set to ground and the rest are high
      // this means that going through i = 0 to 3 and j = 0 to three with light up each led once

      // setlatch pin low so the LEDs don't change while sending in bits
      digitalWrite(latchPin, LOW);
      // shift out the bits of dataToSend to the 74HC595
      shiftOut(dataPin, clockPin, LSBFIRST, dataToSend);
      // set latch pin high- this sends data to outputs so the LEDs will light up
      digitalWrite(latchPin, HIGH);

      delay(100); // wait
    }
  }
}


