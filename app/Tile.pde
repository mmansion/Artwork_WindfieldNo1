class Panel {

  public  PVector origin;
  private PVector p1, p2, p3, p4, t1;
  private int     platformId;
  private Boolean[] activePtArr  = new Boolean[MTU * 8];
  private char[]    activePtBuff = new char[MTU];
  private byte[]    mtrCtrlBuff = new byte[MTU];
  public PVector[][] points = new PVector[ROWS_PER_PANEL][COLS_PER_PANEL];
  public String ip; // network address of platform
  Panel(int id, PVector pos, float deg, color col) {

    platformId = id;
    origin = pos; // set the origin position of the platform

    setPointPositions();

    println("Platform #" + platformId + " , with " + points.length);
    //platformGui = new PlatformGui(platformId, p2, p4);

    for(int i = 0; i < MTU * 8; i++) {
      activePtArr[i] = false;
    }
  }

  public void setIp(String platformIp) {
    this.ip = platformIp;
  }

  public void draw() {

   
  }

  public void setPointPositions() {

  }

  public void drawPoints() {

  }

  //public void updateMotors()

  public void setActiveMotorPoints() {

    int p = 0; //iterate points

    // for each byte in the packet
    for(int theByte = 0; theByte < MTU; theByte++) {

      // for each bit in the byte
      for(int bitPos = 0; bitPos < 8; bitPos++) {

        if(activePtArr[p]) {
          activePtBuff[theByte] = this.setBit( activePtBuff[theByte], bitPos );
        } else {
          activePtBuff[theByte] = this.clearBit( activePtBuff[theByte], bitPos );
        }
        p++;
      }
      // set each byte in the motor control buffer
      mtrCtrlBuff[theByte] = byte( map( int(activePtBuff[theByte]), 0, 255, -128, 127 ));
    }
  }

  public void drawActivePoints() {

   
  }
 

  // ref: https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/BitOp/bitI.html

  //Use the bitwise or and and operators. To set a bit:
  private char setBit(char byteVal, int bitPos) {
    return char(byteVal | (1 << bitPos));
  }

  //To un-set a bit:
  private char clearBit(char byteVal, int bitPos) {
    return char(byteVal & ~(1 << bitPos));
  }

  private Boolean isBitSet(char b, int bit) {
    return (b & (1 << bit)) != 0;
  }

}

class PlatformGui {

  //private int platformId;
  //private PVector vertex1, vertex2;
  //private PShape  platformShape;

  //PlatformGui(int id, PVector p1, PVector p2) {
  //  vertex1 = p1;
  //  vertex2 = p2;
  //  platformId = id;
  //  platformShape = createShape();
  //  Interactive.add( this ); // register it with the gui manager
  //   platformShape.beginShape();
  //  platformShape.fill(0, 0, 255, 90);
  //  platformShape.noStroke();
  //  platformShape.vertex(0, 0);
  //  platformShape.vertex(vertex1.x, vertex1.y);
  //  platformShape.vertex(vertex2.x, vertex2.y);
  //  platformShape.vertex(0, 0);
  //  platformShape.endShape(CLOSE);
  //}

  //// called by manager
  //void mousePressed () {

  //  println("platform " + platformId + " was clicked");
  //}

  //void draw () {

  //  shape(platformShape, 0, 0);
  //}

}
