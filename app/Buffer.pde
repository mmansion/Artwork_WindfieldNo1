class Buffer { //singleton class
  UDP udp;  // define the UDP object
  public String[] ipAddresses = new String[NUM_TILES];

  //byte array for sending active points
  //NUM_TILES * COLS_PER_TILE * ROWS_PER_TILE = n bits / 8 = x bytes
  byte[] byteArray = new byte[UDP_PACKET_SIZE];  //initializes to zero

  Buffer(PApplet root) {

    // UDP Setup
    udp = new UDP(root, UDP_SEND_PORT);
    
    udp.broadcast(true);

    //populate IP addresses
    for (int i = 0; i < ipAddresses.length; i++) {
      ipAddresses[i] = "10.1.0." + (101 + i);
      //println(ipAddresses[i]);
    }
  }
  public void set(int mcuId, int pointIndex, Boolean isActive) {
    int startIndex = mcuId * 2; // Each MCU controls 16 bits, so 2 bytes

    // Check if byteIndex is within the bounds of the array
    if (startIndex < 0 || startIndex + 1 >= byteArray.length) {
      System.out.println("Invalid start index.");
      return; // Exit the function if startIndex is out of bounds
    }

    int byteIndex = startIndex + pointIndex / 8; // Calculate which byte to modify
    int bitIndex = pointIndex % 8; // Calculate which bit in the byte to modify

    if (isActive) {
      // Set the bit to 1
      byteArray[byteIndex] |= (1 << (7 - bitIndex));
    } else {
      // Clear the bit to 0
      byteArray[byteIndex] &= ~(1 << (7 - bitIndex));
    }
  }
  void send() {
    //udp.send(byteArray, "10.1.0.129", UDP_SEND_PORT);
    for (int i = 0; i < ipAddresses.length; i++) {
      udp.send(byteArray, ipAddresses[i], UDP_SEND_PORT);
    }
  }
  //void send() {
  //  // Iterate over all IP addresses in the array
  //  for (int i = 0; i < ipAddresses.length; i++) {
  //    try {
  //      // Send the byteArray to the current IP address as a string, using UDP_SEND_PORT
  //      udp.send(byteArray, ipAddresses[i], UDP_SEND_PORT);
  //    } catch (Exception e) {
  //      // Handle exceptions, such as issues with sending the packet
  //      println("Error sending to: " + ipAddresses[i] + " - " + e.getMessage());
  //    }
  //  }
  //}


  void printBytes() {
    println("");
    for (int i = 0; i < byteArray.length; i++) {
      if ( i % 2 == 0) {
        println("");
        print(ipAddresses[i/2] + ": ");
      }

      String binaryString = byteToBinary(byteArray[i]);
      print(binaryString);

      // If not the last element, print a comma
      if (i < byteArray.length - 1) {
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
