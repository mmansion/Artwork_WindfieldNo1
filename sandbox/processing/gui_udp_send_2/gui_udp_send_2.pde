//---------------------------------------------
static int MCU_ID = 37;  //0-37 (e.g. MCU_ID 0 is mcu-001)

static int NUM_TILES = 38;
// UDP
import hypermedia.net.*;
UDP udp;  // define the UDP object
int UDP_PACKET_SIZE = 76;
static int UDP_PORT = 7010;

String[] ipAddresses = new String[NUM_TILES];

//byte array for sending active points
//38 * 16 = 608 bits / 8 = 76 bytes
byte[] byteArray = new byte[UDP_PACKET_SIZE];  //initializes to zero

byte setBit(byte b, int position) { //set to one
  return (byte) (b | (1 << position));
}
byte unsetBit(byte b, int position) { //set to zero
  return (byte) (b & ~(1 << position)); 
}
//---------------------------------------------
// GUI
int cols = 4, rows = 4;
Circle[][] circles = new Circle[cols][rows];
boolean[][] clicked = new boolean[cols][rows];
boolean[][] hovered = new boolean[cols][rows];
int circleDiameter;
//---------------------------------------------
void setup() {
  size(800, 800);
 
  // UDP Setup
  udp = new UDP(this, 8020);
  
  // populate IP addresses
  for (int i = 0; i < ipAddresses.length; i++) {
    ipAddresses[i] = "10.1.0." + (101 + i);
  }
  
  // GUI SETUP
  circleDiameter = width / 5; // Calculate the diameter of each circle
  // Initialize the circles and clicked states
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      int x = width / 5 * (i + 1);
      int y = height / 5 * (j + 1);
      circles[i][j] = new Circle(x, y, circleDiameter);
      clicked[i][j] = false;
    }
  }
}

byte[] status = new byte[2]; // byte array to hold the status of each circle

void updateStatus() {
  int startIndex = MCU_ID * 2; //16 bits
  println("Start index = " + startIndex);
  // Check if startIndex and startIndex+1 are within the bounds of the array
  if (startIndex < 0 || startIndex + 1 >= byteArray.length) {
    println("Invalid start index.");
    return; // Exit the function if startIndex is out of bounds
  }

  // Initialize the specified bytes to zero
  byteArray[startIndex] = 0;
  byteArray[startIndex + 1] = 0;

  // Update the bits based on the clicked array
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      if (clicked[j][i] || hovered[j][i]) { // notice the swapped indices
        // Calculate the index of the byte and the bit within that byte
        int index = i * cols + j;
        int byteIndex = startIndex + index / 8;
        int bitIndex = index % 8;

        // Additional check to prevent ArrayIndexOutOfBoundsException
        if (byteIndex >= byteArray.length) {
          println("Byte index out of bounds.");
          return; // Exit the function if byteIndex is out of bounds
        }

        // Set the bit to 1
        byteArray[byteIndex] |= (1 << (7 - bitIndex)); // notice the 7 - bitIndex
      }
    }
  }
   return;
  // Print the status bytes in binary format
  //for (int i = 0; i < status.length; i++) {
  //  printByteInBinary(status[i]);
  //  println();
  //}
  //println("-----");
}
void printByteInBinary(byte b) {
  for (int i = 7; i >= 0; i--) {
    print((b >> i) & 1); // Shift and mask to print each bit
  }
  
}

//---------------------------------------------
void draw() {
  background(255);
  noFill();
  rect(width/10, height/10, width - width/5, height - height/5); // Draw the square outline
  
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Circle c = circles[i][j];
      c.update(mouseX, mouseY);
      hovered[i][j] = c.hovered;
      c.display(clicked[i][j]);
    }
  }
  //genRandBits();
 
  
  updateStatus(); // Update the status bytes after drawing
  println("sending byteArray to " + ipAddresses[MCU_ID]);
  printBytes(byteArray);
  udpSend(ipAddresses[MCU_ID], UDP_PORT, byteArray);
}
void mousePressed() {
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows; j++) {
      Circle c = circles[i][j];
      if (c.contains(mouseX, mouseY)) {
        clicked[i][j] = !clicked[i][j];
      }
    }
  }
}
void udpSend(String ip, int port, byte[] packet) {
  udp.send(packet, ip, port);
}
void genRandBits() {
  int count = 0;
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
        count++;
      }      
      //println(String.format("%8s", Integer.toBinaryString(byteArray[theByte] & 0xFF)).replace(' ', '0'));
    }
    println(count);
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
