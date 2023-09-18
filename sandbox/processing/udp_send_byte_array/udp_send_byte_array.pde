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

int UDP_PACKET_SIZE = 1;
int NUM_PANELS = 39;
int COLS_PER_PANEL = 4;
int ROWS_PER_PANEL = 4;
int NUM_ACT_PTS = NUM_PANELS * COLS_PER_PANEL * ROWS_PER_PANEL;//total activation points

//byte array for sending active points
byte[] byteArray = new byte[UDP_PACKET_SIZE]; //78 bytes

byte setBit(byte b, int position) { //set to one
  return (byte) (b | (1 << position));
}
byte unsetBit(byte b, int position) { //set to zero
  return (byte) (b & ~(1 << position)); 
}

void setup() {


  int count = 0;
 
  // for each byte in the packet
  for(int theByte = 0; theByte < UDP_PACKET_SIZE; theByte++) {
    
       byteArray[theByte] = 0; // starting with all bits set to 0: 00000000

      // for each bit in the byte
      for(int bitPos = 0; bitPos < 8; bitPos++) {
        
        //int rand_int = int(random(2)); //random int 0 or 1
          
        int rand_int;
        if(bitPos % 2 == 0) {
          rand_int = 1;
        } else {
          rand_int = 0;
        }
        
        if(rand_int == 0) {
          byteArray[theByte] = setBit(byteArray[theByte], bitPos); //set bit to 1
          
        } else if (rand_int == 1) {
          byteArray[theByte] = unsetBit(byteArray[theByte], bitPos); //set bit to 1
          
        }
        
        
        count++;
      }
      
      //println( binary( byteArray[theByte], 8) );
      
      println(String.format("%8s", Integer.toBinaryString(byteArray[theByte] & 0xFF)).replace(' ', '0'));

      //println("Byte no. " + theByte + " = " + char(byteArray[theByte])); 
      
      
      // set each byte in the motor control buffer
      //mtrCtrlBuff[theByte] = byte( map( int(activePtBuff[theByte]), 0, 255, -128, 127 ));
    }
    

  
}

void draw() {
  
}
void udpSend(String ip, int port, byte[] packet) {
  udp.send(packet, ip, port);
}
void mousePressed() {

  println("sending bytearray");
  println(byteArray);
  udpSend("10.1.0.101", 7010, byteArray);
}
