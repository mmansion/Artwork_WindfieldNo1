// import UDP library
import hypermedia.net.*;
import processing.sound.*;

SoundFile snd;
UDP udp;  // define the UDP object

static Boolean ENABLE_SEND = true;
static String  TEST_IP = "10.1.0.101";
static int     TEST_PORT = 7010;

//-------------------------------
float wind;
float timeOffset = 0.0;

// Declare the scaling variables
float minScale = 50;
float maxScale = 500;
//-------------------------------

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



int UDP_PACKET_SIZE = 39;
int NUM_PANELS = 39;
int COLS_PER_PANEL = 4;
int ROWS_PER_PANEL = 4;
int NUM_ACT_PTS = NUM_PANELS * COLS_PER_PANEL * ROWS_PER_PANEL;//total activation points

//byte array for sending active points
//39 * 16 = 424 bits / 8 = 78 bytes
byte[] byteArray = new byte[UDP_PACKET_SIZE]; 

byte setBit(byte b, int position) { //set to one
  return (byte) (b | (1 << position));
}
byte unsetBit(byte b, int position) { //set to zero
  return (byte) (b & ~(1 << position)); 
}

void setup() {
  size(400, 400);
  udp = new UDP(this, 8020);
  
  snd = new SoundFile(this, "click.mp3");
  
  //frameRate(10);
}
long lastTick = 0;
void draw() {
  
  calcWind();
  drawWindSim();
  
  if(millis() - lastTick >  wind) {
    lastTick = millis();
    println("tick " + wind);
    snd.cue(0);
    snd.play();
    if(ENABLE_SEND) {
      genRandBits();
      println("sending byteArray");
      printBytes(byteArray);
      udpSend(TEST_IP, TEST_PORT, byteArray);
    } 
  }
  
}
void calcWind() {
  // Generate a noise value between 0 and 1
  float n = noise(timeOffset);
  
  // Bias the noise by squaring it
  float biasedNoise = n * n;
  
  // Scale the biased noise value using the scaling variables
  wind = biasedNoise * (maxScale - minScale) + minScale;
  
  // Increment the timeOffset to move through the noise space
  timeOffset += 0.01;
  
}
void drawWindSim() {
  // For demonstration: Draw the wind value as a circle's Y position
  background(220);
  fill(50, 50, 250); // blue color for the circle
  ellipse(width/2, map(wind, minScale, maxScale, height, 0), 20, 20); // We use map() to flip the Y position
  
  textSize(16);
  fill(0);
  text("Wind Value: " + nf(wind, 0, 2), 10, height - 10); // Display the wind value 
}
void sendSerialized(byte[] data) {
  String serialized = "";
  for (byte b : data) {
    serialized += char(b); // Convert byte to char and append to the string
  }
  udp.send(serialized, TEST_IP, TEST_PORT);
}

void udpSend(String ip, int port, byte[] packet) {
  udp.send(packet, ip, port);
}

void genRandBits() {
  
  // for each byte in the packet
  for(int theByte = 0; theByte < UDP_PACKET_SIZE; theByte++) {
       byteArray[theByte] = 0; // starting with all bits set to 0: 00000000
      // for each bit in the byte
      for(int bitPos = 0; bitPos < 8; bitPos++) {
        int rand_int = int(random(2)); //random int 0 or 1
        //int rand_int;
        //if(bitPos % 2 == 0) {
        //  rand_int = 1;
        //} else {
        //  rand_int = 0;
        //}
        
        if(rand_int == 0) {
          byteArray[theByte] = setBit(byteArray[theByte], bitPos); //set bit to 1
          
        } else if (rand_int == 1) {
          byteArray[theByte] = unsetBit(byteArray[theByte], bitPos); //set bit to 1
          
        }
      }      
      //println(String.format("%8s", Integer.toBinaryString(byteArray[theByte] & 0xFF)).replace(' ', '0'));
    }
}

void mousePressed() {
  genRandBits();
  println("sending byteArray");
  printBytes(byteArray);
  udpSend(TEST_IP, TEST_PORT, byteArray);
}

void printBytes(byte[] data) {
 for (int i = 0; i < data.length; i++) {
    String binaryString = byteToBinary(data[i]);
    print(binaryString);
    
    // If not the last element, print a comma
    if (i < data.length - 1) {
      print(",");
    }
  }
  println();  // To end the line after printing all bytes 
}
// Converts a byte to its 8-bit binary string representation
String byteToBinary(byte b) {
  String result = "";
  for (int i = 7; i >= 0; i--) {
    result += ((b >> i) & 1);
  }
  return result;
}
