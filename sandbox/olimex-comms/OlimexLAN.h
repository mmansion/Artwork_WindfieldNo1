// ETHERNET DEPENDENCIES
#define ETH_CLK_MODE ETH_CLOCK_GPIO17_OUT
#define ETH_PHY_POWER 12
#include <ETH.h>
#include <WiFiUdp.h>

// WIFI DEPENDENCIES
// #include <WiFi.h>
// #include <ESPmDNS.h>
// #include <ArduinoOTA.h>

// IMPORTANT:
// Sending OSC formatted messages to Max requires the CNMAT OSC library's OSCMessage
// https://github.com/CNMAT/OSC
// #include <OSCMessage.h>

bool debug_udp = true;
#define UDP_TX_PACKET_MAX_SIZE 86 // Increase max packet size

bool eth_connected  = false;
bool wifi_connected = false;

class OlimexLAN {

  public:
    OlimexLAN();

    void connectEth();
    void connectWifi(char* ssid, char* password);

    // void setupOTA();
    void setupUDP(IPAddress remoteIp, int remotePort, int localPort);

    void update(); // update will check both OTA & UDP

    // void checkOTA();
    void checkUDP();

    void sendUDP(String theMessage);
    // void sendOSC(const char *theMessage);

    char packetBuffer[UDP_TX_PACKET_MAX_SIZE];

    void (*onMessageReceived) (String message);

    WiFiUDP ethUdp; // udp obj, uses ethernet
  private:


    IPAddress remoteUdpIp;
    int remoteUdpPort;

    int connectTimeout = 10000;

    static void onLanEvent(WiFiEvent_t event) {
      Serial.println(event);
      switch (event) {

        case ARDUINO_EVENT_WIFI_AP_PROBEREQRECVED: 
          Serial.println("\nARDUINO_EVENT_WIFI_AP_PROBEREQRECVED");
          break;
        case ARDUINO_EVENT_ETH_START: 
          Serial.println("\nARDUINO_EVENT_ETH_START");
          break;
        case ARDUINO_EVENT_ETH_CONNECTED:
          Serial.println("\nARDUINO_EVENT_ETH_CONNECTED");
          break;

        // WIFI EVENTS -----------------------------------------
        case SYSTEM_EVENT_STA_START:
          Serial.println("\nSYSTEM_EVENT_STA_START");
          WiFi.setHostname("esp32-ethernet");
          break;
        case SYSTEM_EVENT_STA_CONNECTED:
          Serial.println("\nSYSTEM_EVENT_STA_CONNECTED");
          break;
        case SYSTEM_EVENT_STA_GOT_IP:
          Serial.println("\nSYSTEM_EVENT_STA_GOT_IP");
          Serial.print("\nWIFI MAC: ");
          Serial.println(WiFi.macAddress());
          Serial.print("WIFI IPv4: ");
          Serial.println(WiFi.localIP());
          wifi_connected = true;
          break;
        case SYSTEM_EVENT_STA_DISCONNECTED:
          Serial.println("SYSTEM_EVENT_STA_DISCONNECTED");
          wifi_connected = false;
          break;
        case SYSTEM_EVENT_STA_STOP:
          Serial.println("\nSYSTEM_EVENT_STA_STOP");
          wifi_connected = false;
          break;

         // ETH EVENTS ------------------------------------------
        case SYSTEM_EVENT_ETH_START:
          Serial.println("\nETHERNET_EVENT_START");
          //set eth hostname here
          ETH.setHostname("esp32-ethernet");
          break;
        case SYSTEM_EVENT_ETH_CONNECTED:
          Serial.println("\nSYSTEM_EVENT_ETH_CONNECTED");
          break;
        case SYSTEM_EVENT_ETH_GOT_IP:
          Serial.println("\nSYSTEM_EVENT_ETH_GOT_IP");
          Serial.print("\nETH MAC: ");
          Serial.println(ETH.macAddress());
          Serial.print("ETH IPv4: ");
          Serial.println(ETH.localIP());
          eth_connected = true;
          break;
        case SYSTEM_EVENT_ETH_DISCONNECTED:
          Serial.println("\nSYSTEM_EVENT_ETH_DISCONNECTED");
          eth_connected = false;
          break;
        case SYSTEM_EVENT_ETH_STOP:
          Serial.println("\nSYSTEM_EVENT_ETH_STOP");
          eth_connected = false;
          break;
        default:
          break;
      }
  }//end static

};

//------------------------------------------------------------------

// constructor: LAN Only
OlimexLAN::OlimexLAN() {
  if(!Serial) Serial.begin(115200);
  Serial.println("\n\n\n");
  WiFi.onEvent(onLanEvent);
}

//------------------------------------------------------------------
void OlimexLAN::connectEth() {
  ETH.begin();

  Serial.print("Connecting to Ethernet: @MAC");
  Serial.println(ETH.macAddress());
  long startConnectTime = millis();

  delay(3000);
  while(!eth_connected) {
    delay(100);
    Serial.print(".");
    if(millis() - startConnectTime > this->connectTimeout) break;
  }
  Serial.println();
}

//------------------------------------------------------------------
// void OlimexLAN::connectWifi(char* ssid, char* password) {
//   WiFi.mode(WIFI_STA);
//   WiFi.begin(ssid, password);
//   Serial.print("Connecting to WiFi: @MAC: ");
//   Serial.println(WiFi.macAddress());
//   long startConnectTime = millis();
//   while(!wifi_connected) {
//     delay(100);
//     Serial.print(".");
//     if(millis() - startConnectTime > this->connectTimeout) break;
//   }
//   Serial.println();
// }

//------------------------------------------------------------------
void OlimexLAN::setupUDP(IPAddress remoteIp, int remotePort, int localPort) {
  Serial.println("Setting up UDP Comms");
  this->remoteUdpIp = remoteIp;
  this->remoteUdpPort = remotePort;

  // Begin listening to UDP port
  this->ethUdp.begin(localPort);
  Serial.print("Listening on UDP port ");
  Serial.println(localPort);
}

// void OlimexLAN::setupOTA() {

//    //------------------------------------------------------------------
//   // Port defaults to 3232
//   // ArduinoOTA.setPort(3232);

//   // Hostname defaults to esp3232-[MAC]
//   // ArduinoOTA.setHostname("myesp32");

//   // No authentication by default
//   // ArduinoOTA.setPassword("admin");

//   // Password can be set with it's md5 value as well
//   // MD5(admin) = 21232f297a57a5a743894a0e4a801fc3
//   // ArduinoOTA.setPasswordHash("21232f297a57a5a743894a0e4a801fc3");

//   ArduinoOTA
//     .onStart([]() {
//       String type;
//       if (ArduinoOTA.getCommand() == U_FLASH)
//         type = "sketch";
//       else // U_SPIFFS
//         type = "filesystem";

//       // NOTE: if updating SPIFFS this would be the place to unmount SPIFFS using SPIFFS.end()
//       Serial.println("Start updating " + type);
//     })
//     .onEnd([]() {
//       Serial.println("\nEnd");
//     })
//     .onProgress([](unsigned int progress, unsigned int total) {
//       Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
//     })
//     .onError([](ota_error_t error) {
//       Serial.printf("Error[%u]: ", error);
//       if (error == OTA_AUTH_ERROR)         Serial.println("Auth Failed");
//       else if (error == OTA_BEGIN_ERROR)   Serial.println("Begin Failed");
//       else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
//       else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
//       else if (error == OTA_END_ERROR)     Serial.println("End Failed");
//     });

//     delay(1000);
//     ArduinoOTA.begin();
// }


// void OlimexLAN::checkOTA() {
//   ArduinoOTA.handle();
// }

void OlimexLAN::update() {
  // this->checkOTA();
  this->checkUDP();
}

// void OlimexLAN::sendUDP(String theMessage) {

// }

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

  if(packetSize) {
    Serial.print("something");

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

    this->onMessageReceived(message);

    this->ethUdp.flush();
  }
  delay(100);
}
