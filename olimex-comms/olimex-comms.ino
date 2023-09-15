#include "OlimexLAN.h" //features: Wifi, Eth, OTA, UDP/OSC
// #include <Regexp.h>

char *wifi_ssid = "MANSION";
char *wifi_pwd  = "Valley*24";

// remote communication settings (UDP/OSC)
WiFiUDP   etheretUdp;

//test ip (manually set your computer to this addr to test)
IPAddress remoteUdpIp = IPAddress(192,168,86,245); 
IPAddress olimexIP = IPAddress(192,168,86,50);

const int remoteUdpPort = 8020;
const int localUdpPort  = 7010;

// localIp assigned by router when OlimexLAN connects eth

// LAN class object
OlimexLAN *olimexLAN;

// #include <OSCBundle.h>


//------------------------------------------------------------
void setup() {

  Serial.begin(115200);
  Serial.print("Starting up");

  //------------------------------------------------------------
  // 1. setup ethernet and wifi connections

    //olimexLAN = new OlimexLAN(wifi_ssid, wifi_pwd);
    
    olimexLAN = new OlimexLAN();
  
//    olimexLAN->connectEth(192.168.86.45);
    olimexLAN->connectWifi(wifi_ssid, wifi_pwd);

  //------------------------------------------------------------
  // 2. setup "over the air" programming (works for eth or wifi)

    olimexLAN->setupOTA();
  
  //------------------------------------------------------------
  // 3. setup UDP communications

    olimexLAN->setupUDP(remoteUdpIp, remoteUdpPort, localUdpPort);

    // register event handler for inbound messages
//    olimexLAN->onMessageReceived = onMessageReceived;
}

//------------------------------------------------------------
void loop() {

  // in order for OTA to work, must repeatedly check
  olimexLAN->checkOTA();

  // check for incoming udp/osc messages
  olimexLAN->checkUDP();
  
  // you can also call olimexLAN->update(); 
  // shortcut to call both checkUDP + checkOTA
}

//------------------------------------------------------------
// register this callback with olimexUDP instance
//void onMessageReceived(boolean bits[16]) {
////  MatchState ms; //matchstate object (requirs regex lib)
////  
////  byte maxBufLen = UDP_TX_PACKET_MAX_SIZE;
////  
////  //search target
////  char buf [maxBufLen];
////  message.toCharArray(buf, maxBufLen);
////
////  //set target buffer
////  ms.Target(buf);
////
////  // setup your own commands here:
////  
////  if( ms.Match ("/test") ) {
////      Serial.println("received test command");
////      Serial.println(buf);
//////      olimexLAN->sendOSC("received");
////  }
//    
//}
