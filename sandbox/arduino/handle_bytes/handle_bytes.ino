#define MTU 1 //maximum transfer unit (the packet size in bytes)


uint8_t byteArray[78] = {0};

byte bytes[] = {
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000,
  B00000000
  };

int count = 0;
byte pos;

void pulsePin() {
  // outputs update on this rising edge
  digitalWrite(latchPin, LOW); //SPI_SS
  digitalWrite(latchPin, HIGH); //SPI_SS
}

void initPacketBuff() {
  // 1. iterate through all the bytes in the packet buffer
  for(int theByte = 0; theByte < maxBytes; theByte++) {
    packetBuffer[theByte] = B00000000;
  }
}

void stopAll() {
  for(int theByte = 0; theByte < maxBytes; theByte++) {
    SPI.transfer(B00000000);
  }
  pulsePin();
}

void setup() {

  Serial.begin(9600);
  Serial.print("Local MTU (max transmission unit) = ");
  Serial.println(MTU);

  digitalWrite(clearPin, HIGH); //drive clearpin high for duration

  //SPISettings(speedMaximum, dataOrder, dataMode)
  //ref: https://www.arduino.cc/en/Reference/SPISettings
  SPI.beginTransaction(SPISettings(16000000, MSBFIRST, SPI_MODE0));

  stopAll();
  initPacketBuff();
}

/**
 * @function - getUnsignedByte
 *
 * @params   - char signedValue
 * @returns  - char unsignedValue
 *
 * Takes a signed byte/char value and returns its signed equivalent.
 * The method works by using a simple primitive widening conversion,
 * which allows negative values to be sign-extended.
 * IE -> 1111 1111 becomes 11111111 11111111, still -1, but this time as a short.
 * Then the bitmask 0xff (00000000 11111111) is used to get the last 8 bits out again:
 *
 *  -1: 11111111 1111111
 *  0xFF: 00000000 1111111
 *  ======================
 *  255: 00000000 1111111
 *
 *  ref: http://stackoverflow.com/questions/19061544/bitwise-anding-with-0xff-is-important
 */

// char getUnsignedByte (char signedValue) {
//
//   short tmpVal;
//
//   tmpVal = signedValue;
//   tmpVal &= 0xFF;
//
//   return (byte) tmpVal;
// }

char getUnsignedByte (char signedValue) {
  short tmpVal;
  tmpVal = signedValue;
  tmpVal &= 0xFF;
  return (byte) tmpVal;
}

void updateMotors() {

  // 1. iterate through all the bytes in the packet buffer
  for(int theByte = 0; theByte < maxBytes; theByte++) {
    char ctrlByte = packetBuffer[theByte];

    // 2. iterate through the bits of each byte and update bytes array
    for(int theBit = 0; theBit < 8; theBit++) { //iterate through bits of each byte

      //use bitwise and to check if bit is set
      // bit set means the bit is 1
      // bit clear means the bit 0

      bitRead(ctrlByte, theBit);
      bitWrite(bytes[theByte], theBit, 0);
    }

    // 3. shift the bits into the register
    //TODO: enable spi transfer
    //SPI.transfer(bytes[theByte]);

    if(DEBUG_UDP) {
      char byteVal = getUnsignedByte( -127 );
      Serial.print( map(packetBuffer[theByte], -127, 127, 0,255));
      Serial.print(" : ");
      Serial.print( packetBuffer[theByte] , DEC);
      if(theByte != MTU-1) Serial.print(",");
    }
  }
  Serial.println("");

  // 4. flip the latch and let er rip
  //pulsePin();
}

void loop() {

  /*
  The UDP object returns a packetBuffer, which is a c-style char array (i.e. byte array).
  A char is only 1 byte (either -127 to 127 signed, or 0 -255 unsigned).
  The  char array used here is a c-style (naked) array, and so isn't wrapped in a class object.
  It therefore  does not have convenience methods such as bounds checking, or a length property.
  In order to understand it's size, there is a feature of the UPD class, called parsePacket().
  Alternatively we can use the sizeOf(packetBuffer) function for determining its byte length.
  */

  // Use the parsePacket() method to read the buffer size;
  // proceed if there is data available
  int packetSize = Udp.parsePacket();

  // In Processing, we set the maximum transfer unit (MTU) to be 60 bytes.
  // 60 bytes is enough information to drive 480 separate motors through 8-bit shift registers.
  // Since each motor can be driven from a single bit, and there are 8 bits to every byte,
  // we have enough data in 60 bytes to drive all the motors--i.e. 480 bits / 8 = 60 bytes MTU

  // Adapted for Windfield No.1:
  
  // 39 Panels, ea w 16 activation points (LEDs and Piezo Speakers)
  // 39 x 16 = 624 points
  // 624 bits / 8 = 78 byte MTU
 
 

  if (packetSize) {

    if(DEBUG_UDP) {

      Serial.print("Received packet of size ");
      Serial.println(packetSize);
      //Serial.println(sizeof(packetBuffer));

      Serial.print("From ");
      IPAddress remote = Udp.remoteIP();

      for (int i = 0; i < 4; i++) {
        Serial.print(remote[i], DEC);
        if (i < 3) {
          Serial.print(".");
        }
      }

      Serial.print(", port ");
      Serial.println(Udp.remotePort());

    } //end debug_udp

    // read the packet into packetBuffer
    Udp.read(packetBuffer, MTU);

    updateMotors();

    //send a reply to the IP address and port that sent us the packet we received
    Udp.beginPacket(Udp.remoteIP(), Udp.remotePort());
    Udp.write(ReplyBuffer);
    Udp.endPacket();
  }
  delay(100);


}
