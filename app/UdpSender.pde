class UdpSender { //singleton class

   //---------------------------------------------
  //static int MCU_ID = 37;  //0-37 (e.g. MCU_ID 0 is mcu-001)
  
 // static int NUM_TILES = 38;
  // UDP

  UDP udp;  // define the UDP object
  
  String[] ipAddresses = new String[NUM_TILES];
  
  //byte array for sending active points
  //38 * 16 = 608 bits / 8 = 76 bytes
  byte[] byteArray = new byte[UDP_PACKET_SIZE];  //initializes to zero
  
  UdpSender(PApplet root) {
    
    // UDP Setup
    udp = new UDP(root, UDP_SEND_PORT);
  
    //populate IP addresses
    for (int i = 0; i < ipAddresses.length; i++) {
      ipAddresses[i] = "10.1.0." + (101 + i);
      println(ipAddresses[i]);
    }
  }
  
  byte setBit(byte b, int position) { //set to one
    return (byte) (b | (1 << position));
  }
  byte unsetBit(byte b, int position) { //set to zero
    return (byte) (b & ~(1 << position)); 
  }

  void send(String ip, int port, byte[] packet) {
    udp.send(packet, ip, port);
  }
  
  /* probably do not need this function
  
  public void updateStatus(int MCU_ID, int status) {//status = 0 or 1
    
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
  */

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
}
