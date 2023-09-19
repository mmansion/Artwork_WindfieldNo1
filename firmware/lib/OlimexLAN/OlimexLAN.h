


//TODO: check pin settings
// i believe one of the digital outs is affecting the serial comms


// ETHERNET DEPENDENCIES
#define ETH_CLK_MODE ETH_CLOCK_GPIO17_OUT
#define ETH_PHY_POWER 12
#include <ETH.h>
#include <WiFiUdp.h>
// https : // github.com/espressif/arduino-esp32/tree/master/libraries/WiFi

// WIFI DEPENDENCIES
#include <WiFi.h>
#include <ESPmDNS.h>
#include <ArduinoOTA.h>

// IMPORTANT:
// Sending OSC formatted messages to Max requires the CNMAT OSC library's OSCMessage
// https://github.com/CNMAT/OSC
// #include <OSCMessage.h>

bool debug_udp = true;

#define UDP_TX_PACKET_MAX_SIZE 86


class OlimexLAN {

  public:
    OlimexLAN();

    bool eth_connected  = false;
    bool wifi_connected = false;
    
    void connectEth();
    void connectWifi(char* ssid, char* password);
    void setupOTA();

    // void setupUDP(IPAddress remoteIp, int remotePort, int localPort, bool multicast);
    void setupUDP(int port, bool multicast = false);

    void update(); // update will check both OTA & UDP
    void checkOTA();
    void checkUDP();
    void sendUDP(String theMessage);
    void onLanEvent(WiFiEvent_t event); //connection events

    // void sendOSC(const char *theMessage);
    char packetBuffer[UDP_TX_PACKET_MAX_SIZE];
    void (*onMessageReceived) (String message);
    WiFiUDP ethUdp; // udp obj, uses ethernet
  
  private:
    IPAddress remoteUdpIp;
    // IPAddress localUdpIp;

    // int remoteUdpPort;
    int localUdpPort;
    int connectTimeout = 10000;
};
//------------------------------------------------------------------
// constructor: LAN Only
OlimexLAN::OlimexLAN() {
  if(!Serial) Serial.begin(115200);
  Serial.println("\n\n\n");
  // WiFi.onEvent(void(&onLanEvent));
  //create event handler for Wifi.onEvent
  WiFi.onEvent([this](WiFiEvent_t event, WiFiEventInfo_t info) {
    this->onLanEvent(event);
  });
}

//------------------------------------------------------------------
void OlimexLAN::connectEth() {
  ETH.begin();
  long startConnectTime = millis();
  while(!eth_connected) {
    delay(100);
    Serial.print(".");
    if(millis() - startConnectTime > this->connectTimeout) break;
  }
  Serial.println();
}

//------------------------------------------------------------------
void OlimexLAN::connectWifi(char* ssid, char* password) {
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  long startConnectTime = millis();
  while(!wifi_connected) {
    delay(100);
    Serial.print(".");
    if(millis() - startConnectTime > this->connectTimeout) break;
  }
}

//------------------------------------------------------------------
//setup the UDP client, defaults to multicast false
void OlimexLAN::setupUDP(int port, bool multicast) {

  Serial.println("Setting up UDP Comms");
  delay(1000);

  this->localUdpPort = port;

  if(!multicast) { //multicast = false (default)

      if(this->ethUdp.begin(this->localUdpPort)) {
        Serial.println("UDP listener started successfully");
        Serial.print("Listening on UDP port ");
        Serial.println(this->localUdpPort);
        delay(1000);
      } else {
        Serial.println("UDP listener failed to start");
        delay(1000);
      }

  } else { //multicast = true

    Serial.println("Multicast = TRUE");
    delay(1000);

    if (this->ethUdp.beginMulticast(ETH.localIP(), this->localUdpPort)) {
      Serial.println("UDP Multicast listener started successfully");
      Serial.print("Listening on UDP port ");
      Serial.println(this->localUdpPort);
      delay(1000);
    } else {
      Serial.println("UDP Multicast listener failed to start");
      delay(1000);
    }
  }
}

void OlimexLAN::setupOTA() {

   //------------------------------------------------------------------
  // Port defaults to 3232
  // ArduinoOTA.setPort(3232);

  // Hostname defaults to esp3232-[MAC]
  // ArduinoOTA.setHostname("myesp32");

  // No authentication by default
  // ArduinoOTA.setPassword("admin");

  // Password can be set with it's md5 value as well
  // MD5(admin) = 21232f297a57a5a743894a0e4a801fc3
  // ArduinoOTA.setPasswordHash("21232f297a57a5a743894a0e4a801fc3");

  ArduinoOTA
    .onStart([]() {
      String type;
      if (ArduinoOTA.getCommand() == U_FLASH)
        type = "sketch";
      else // U_SPIFFS
        type = "filesystem";

      // NOTE: if updating SPIFFS this would be the place to unmount SPIFFS using SPIFFS.end()
      Serial.println("Start updating " + type);
    })
    .onEnd([]() {
      Serial.println("\nEnd");
    })
    .onProgress([](unsigned int progress, unsigned int total) {
      Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
    })
    .onError([](ota_error_t error) {
      Serial.printf("Error[%u]: ", error);
      if (error == OTA_AUTH_ERROR)         Serial.println("Auth Failed");
      else if (error == OTA_BEGIN_ERROR)   Serial.println("Begin Failed");
      else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
      else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
      else if (error == OTA_END_ERROR)     Serial.println("End Failed");
    });

    delay(1000);
    ArduinoOTA.begin();
}


void OlimexLAN::checkOTA() {
  ArduinoOTA.handle();
}

void OlimexLAN::update() {
  this->checkOTA();
  this->checkUDP();
}

void OlimexLAN::sendUDP(String theMessage) {

}

// void OlimexLAN::sendOSC(const char *theMessage) {

//     OSCMessage msg(theMessage);

//     //msg.add("hello, osc."); //todo integrate command opt

//     ethUdp.beginPacket(this->remoteUdpIp, this->remoteUdpPort);

//     msg.send(ethUdp);

//     ethUdp.endPacket();

//     msg.empty();
// }
void OlimexLAN::checkUDP() {
 int packetSize = this->ethUdp.parsePacket();
  if (packetSize) {
    Serial.print("Received packet of size : ");
    Serial.println(packetSize);

    if (debug_udp) {
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      Serial.print("From ");
      IPAddress remote = this->ethUdp.remoteIP();
      for (int i = 0; i < 4; i++)
      {
        Serial.print(remote[i], DEC);
        if (i < 3)
        {
          Serial.print(".");
        }
      }
      Serial.print(", port ");
      Serial.println(this->ethUdp.remotePort());
    }

    // read the packet into the packetBuffer
    this->ethUdp.read(this->packetBuffer, UDP_TX_PACKET_MAX_SIZE);
    Serial.println("Contents:");
    
    for (int i = 0; i < packetSize; i++) {
      // Print each byte in binary format
      if (packetBuffer[i] < 0b10000000) Serial.print("0"); // leading bit
      if (packetBuffer[i] < 0b1000000)  Serial.print("0"); // second bit
      if (packetBuffer[i] < 0b100000)   Serial.print("0"); // and so on...
      if (packetBuffer[i] < 0b10000)    Serial.print("0");
      if (packetBuffer[i] < 0b1000)     Serial.print("0");
      if (packetBuffer[i] < 0b100)      Serial.print("0");
      if (packetBuffer[i] < 0b10)       Serial.print("0");
      Serial.print(packetBuffer[i], BIN);
      Serial.print(" ");
    }
    Serial.println();  // Newline after printing all bytes
  }
  this->ethUdp.flush();
  delay(10);
}
/*
void OlimexLAN::checkUDP() {
  int packetSize = this->ethUdp.parsePacket();

  if(packetSize) {
    Serial.println(packetSize);
    if (debug_udp) {
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      Serial.print("From ");
      IPAddress remote = this->ethUdp.remoteIP();
      for (int i = 0; i < 4; i++)
      {
        Serial.print(remote[i], DEC);
        if (i < 3)
        {
          Serial.print(".");
        }
      }
      Serial.print(", port ");
      Serial.println(this->ethUdp.remotePort());
    }

    // read the packet into packetBufffer
    this->ethUdp.read(this->packetBuffer, UDP_TX_PACKET_MAX_SIZE);
    Serial.println("Contents:");
    Serial.println(this->packetBuffer);
    String message = String(this->packetBuffer);

    // this->onMessageReceived(message);

    this->ethUdp.flush();
  }
  delay(100);
}
*/

void OlimexLAN::onLanEvent(WiFiEvent_t event) {
  switch (event) {
  case ARDUINO_EVENT_WIFI_READY:
    // Serial.println("\nARDUINO_EVENT_WIFI_READY");
    break;
  case ARDUINO_EVENT_WIFI_SCAN_DONE:
    // Serial.println("\nARDUINO_EVENT_WIFI_SCAN_DONE");
    break;
  case ARDUINO_EVENT_WIFI_STA_START:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_START");
    break;
  case ARDUINO_EVENT_WIFI_STA_STOP:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_STOP");
    break;
  case ARDUINO_EVENT_WIFI_STA_CONNECTED:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_CONNECTED");
    Serial.println("\n[WIFI]\nConnected!");
    this->wifi_connected = true; // set conn status
    break;
  case ARDUINO_EVENT_WIFI_STA_DISCONNECTED:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_DISCONNECTED");
    Serial.println("\n[WIFI]\nDisconnected!");
    this->wifi_connected = false; // set conn status
    break;
  case ARDUINO_EVENT_WIFI_STA_AUTHMODE_CHANGE:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_AUTHMODE_CHANGE");
    break;
  case ARDUINO_EVENT_WIFI_STA_GOT_IP:
    Serial.println("\n[WIFI]\nReceived IPv4:");
    Serial.print("@WIFI MAC: ");
    Serial.println(WiFi.macAddress());
    Serial.print("@WIFI IPv4: ");
    Serial.println(WiFi.localIP());
    break;
  case ARDUINO_EVENT_WIFI_STA_GOT_IP6:
    Serial.println("\n[WIFI]\nReceived IPv6:");
    Serial.print("@WIFI MAC: ");
    Serial.println(WiFi.macAddress());
    Serial.print("@WIFI IPv6: ");
    Serial.println(WiFi.localIPv6());
    break;
  case ARDUINO_EVENT_WIFI_STA_LOST_IP:
    // Serial.println("\nARDUINO_EVENT_WIFI_STA_LOST_IP");
    break;
  case ARDUINO_EVENT_WIFI_AP_START:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_START");
    break;
  case ARDUINO_EVENT_WIFI_AP_STOP:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_STOP");
    break;
  case ARDUINO_EVENT_WIFI_AP_STACONNECTED:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_STACONNECTED");
    break;
  case ARDUINO_EVENT_WIFI_AP_STADISCONNECTED:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_STADISCONNECTED");
    break;
  case ARDUINO_EVENT_WIFI_AP_STAIPASSIGNED:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_STAIPASSIGNED");
    break;
  case ARDUINO_EVENT_WIFI_AP_PROBEREQRECVED:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_PROBEREQRECVED");
    break;
  case ARDUINO_EVENT_WIFI_AP_GOT_IP6:
    // Serial.println("\nARDUINO_EVENT_WIFI_AP_GOT_IP6");
    break;
  case ARDUINO_EVENT_WIFI_FTM_REPORT:
    // Serial.println("\nARDUINO_EVENT_WIFI_FTM_REPORT");
    break;
  case ARDUINO_EVENT_ETH_START:
    // Serial.println("\nARDUINO_EVENT_ETH_START");
    break;
  case ARDUINO_EVENT_ETH_STOP:
    // Serial.println("\nARDUINO_EVENT_ETH_STOP");
    break;
  case ARDUINO_EVENT_ETH_CONNECTED:
    // Serial.println("\nARDUINO_EVENT_ETH_CONNECTED");
    Serial.println("\n[ETHERNET]\nConnected!");
    this->eth_connected = true; // set conn status
    break;
  case ARDUINO_EVENT_ETH_DISCONNECTED:
    // Serial.println("\nARDUINO_EVENT_ETH_DISCONNECTED");
    Serial.println("\n[ETHERNET]\nDisconnected!");
    this->eth_connected = false; // set conn status
    break;
  case ARDUINO_EVENT_ETH_GOT_IP:
    Serial.println("\n[ETHERNET]\nReceived IPv4:");
    Serial.print("@ETH MAC: ");
    Serial.println(ETH.macAddress());
    Serial.print("@ETH IPv4: ");
    Serial.println(ETH.localIP());
    break;
  case ARDUINO_EVENT_ETH_GOT_IP6:
    Serial.println("\n[ETHERNET]\nReceived IPv6:");
    Serial.print("@ETH MAC: ");
    Serial.println(ETH.macAddress());
    Serial.print("@ETH IPv6: ");
    Serial.println(ETH.localIPv6());
    break;
  case ARDUINO_EVENT_WPS_ER_SUCCESS:
    Serial.println("\nARDUINO_EVENT_WPS_ER_SUCCESS");
    break;
  case ARDUINO_EVENT_WPS_ER_FAILED:
    Serial.println("\nARDUINO_EVENT_WPS_ER_FAILED");
    break;
  case ARDUINO_EVENT_WPS_ER_TIMEOUT:
    Serial.println("\nARDUINO_EVENT_WPS_ER_TIMEOUT");
    break;
  case ARDUINO_EVENT_WPS_ER_PIN:
    Serial.println("\nARDUINO_EVENT_WPS_ER_PIN");
    break;
  case ARDUINO_EVENT_WPS_ER_PBC_OVERLAP:
    Serial.println("\nARDUINO_EVENT_WPS_ER_PBC_OVERLAP");
    break;
  case ARDUINO_EVENT_SC_SCAN_DONE:
    Serial.println("\nARDUINO_EVENT_SC_SCAN_DONE");
    break;
  case ARDUINO_EVENT_SC_FOUND_CHANNEL:
    Serial.println("\nARDUINO_EVENT_SC_FOUND_CHANNEL");
    break;
  case ARDUINO_EVENT_SC_GOT_SSID_PSWD:
    Serial.println("\nARDUINO_EVENT_SC_GOT_SSID_PSWD");
    break;
  case ARDUINO_EVENT_SC_SEND_ACK_DONE:
    Serial.println("\nARDUINO_EVENT_SC_SEND_ACK_DONE");
    break;
  case ARDUINO_EVENT_PROV_INIT:
    Serial.println("\nARDUINO_EVENT_PROV_INIT");
    break;
  case ARDUINO_EVENT_PROV_DEINIT:
    Serial.println("\nARDUINO_EVENT_PROV_DEINIT");
    break;
  case ARDUINO_EVENT_PROV_START:
    Serial.println("\nARDUINO_EVENT_PROV_START");
    break;
  case ARDUINO_EVENT_PROV_END:
    Serial.println("\nARDUINO_EVENT_PROV_END");
    break;
  case ARDUINO_EVENT_PROV_CRED_RECV:
    Serial.println("\nARDUINO_EVENT_PROV_CRED_RECV");
    break;
  case ARDUINO_EVENT_PROV_CRED_FAIL:
    Serial.println("\nARDUINO_EVENT_PROV_CRED_FAIL");
    break;
  case ARDUINO_EVENT_PROV_CRED_SUCCESS:
    Serial.println("\nARDUINO_EVENT_PROV_CRED_SUCCESS");
    break;
  default:
    Serial.println("\nUnknown event");
  }
}