// import UDP library
import hypermedia.net.*;


UDP udp;  // define the UDP object

/*
MTU Details: //maximum transmission unit

Total required -> 86 byte MTU 

UDP Header       -> 8 bytes
Source port      -> 2 bytes
Destination port -> 2 bytes
Length           -> 2 bytes: len of header + payload/data (min is 8b, meaning header itself w/ no data) 
Checksum         -> 2 bytes: used for error-checking (header + data). optional in IPv4; mandatory in IPv6.
----------------------------
UDP Data         -> 78 bytes
39 panels x 16 points = 624 bits / 8 (8 bits per 1 byte) = 78 bytes.

UDP_PACKET_SIZE = 78
*/

int UDP_PACKET_SIZE = 78;
int NUM_PANELS = 39;
int COLS_PER_PANEL = 4;
int ROWS_PER_PANEL = 4;
int NUM_ACT_PTS = NUM_PANELS * COLS_PER_PANEL * ROWS_PER_PANEL;//total activation points

//byte array for sending active points
char[] byteArray = new char[UDP_PACKET_SIZE]; //78 bytes



//Use the bitwise or and and operators. To set a bit:
char setBit(char byteVal, int bitPos) {
  return char(byteVal | (1 << bitPos));
}

//To un-set a bit:
char clearBit(char byteVal, int bitPos) {
  return char(byteVal & ~(1 << bitPos));
}

Boolean isBitSet(char b, int bit) {
  return (b & (1 << bit)) != 0;
}

void setup() {


  int count = 0;
  // for each byte in the packet
  for(int theByte = 0; theByte < UDP_PACKET_SIZE; theByte++) {

      // for each bit in the byte
      for(int bitPos = 0; bitPos < 8; bitPos++) {
        
        int rand_int = int(random(2)); //random int 0 or 1
        
        // rand char '0' or '1' (representing the bit) 
        char bit_val = Integer.toString( rand_int ).charAt(0);
        
        if(rand_int == 0) {
          
          byteArray[theByte] = setBit(bit_val, bitPos); //set bit to 1
          
        } else if (rand_int == 1) {
          
          byteArray[theByte] = clearBit(bit_val, bitPos); //set bit to 1
          
        }
        
     
        
        count++;

      }
      
      println( binary( byteArray[theByte], 8) );
      //println("Byte no. " + theByte + " = " + char(byteArray[theByte])); 
      
      
      // set each byte in the motor control buffer
      //mtrCtrlBuff[theByte] = byte( map( int(activePtBuff[theByte]), 0, 255, -128, 127 ));
    }
    

  
}

void draw() {
  
}

void mousePressed() {

  byte[] message = new byte[2];
  message[0] = 0;
  message[1] = 0;

}

void udpSend(String ip, int port, byte[] packet) {
  udp.send(packet, ip, port);
}
