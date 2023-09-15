class UdpSender {

  private UDP    udp;
  private int    mtu; //maximum transmission unit
  private String localIp;
  private long   lastSendTime;
  private byte[] udpTransportPacket;

  UdpSender(PApplet root, String ip, int port) {

    // // keep track of maximum transmittion unit
    // this.mtu = bufferSize;

    // instantiate new udp object
    this.udp = new UDP(root, port);

    // preserve this machine's LOCAL ip
    this.localIp = ip;

    // listen for incoming messages
    this.udp.listen(true);
    //
    // // init packet buffer based on buffer length
    // udpTransportPacket = new byte[bufferSize];
    //
    // for(int i = 0; i < mtu; i++) {
    //   this.udpTransportPacket[i] = 0;
    // }
  }

  // takes an unsigned char buffer and converts to signed byte buffer
  /*
  As primitives are signed the Java compiler will prevent you from assigning a value higher than +127 to a byte (or lower than -128). However, there's nothing to stop you downcasting an int (or short) in order to achieve this:
  */
  //NOT USED
  private void loadPacketBuffer(char[] charBuffer) {

    //for number of bytes in packet
    // char buffer should be same size as packet buffer
    // for(int i = 0; i < this.mtu; i++) {
    //   this.udpTransportPacket[i] = (byte) charBuffer[i];
    // }
  }

  public void send(String ip, int port, byte[] packet) {

    // 2. send udp packet buffer to arduino
    this.udp.send(packet, ip, port);
  }
}
