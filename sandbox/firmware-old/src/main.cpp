//arduino core libraries
#include <Arduino.h>
#include <WiFi.h>
#include <WiFiUdp.h>
// https://reference.arduino.cc/reference/en/libraries/wifi/wifiudp/

#include <OSCMessage.h>

const char *ssid = "";
const char *password = "";
const int localPort = 7999; // local port to listen on

bool debug_udp = true;

#define UDP_TX_PACKET_MAX_SIZE 64
char packetBuffer[UDP_TX_PACKET_MAX_SIZE]; // max packet size

WiFiUDP ethUdp; // udp obj, uses ethernet

void setup() {
  
  Serial.begin(115200);
  delay(2000);

  // We start by connecting to a WiFi network

  Serial.println("\n");
  Serial.print("Connecting to ");
  Serial.println(ssid);
  Serial.println("\n");
  delay(1000);

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED)
  {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\n");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  // start UDP
  // Begin listening to UDP port
  delay(1000);
  ethUdp.begin(localPort);
  Serial.print("Listening on UDP port ");
  Serial.println(localPort);
}

void checkUDP() {

  int packetSize = ethUdp.parsePacket();

  if (packetSize) {

    if (debug_udp)
    {
      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      Serial.print("From ");
      IPAddress remote = ethUdp.remoteIP();
      for (int i = 0; i < 4; i++)
      {
        Serial.print(remote[i], DEC);
        if (i < 3)
        {
          Serial.print(".");
        }
      }
      Serial.print(", port ");
      Serial.println(ethUdp.remotePort());
    }

    // read the packet into packetBufffer
    ethUdp.read(packetBuffer, UDP_TX_PACKET_MAX_SIZE);
    Serial.println("Contents:");
    Serial.println(packetBuffer);
    String message = String(packetBuffer);

    //onMessageReceived(message);

    ethUdp.flush();
  }
  delay(10);
}

void loop() {
  checkUDP();
}
