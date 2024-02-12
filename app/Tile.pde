class Tile {

  public int         id = -1; //if id = -1, then it's an empty tile spot on the grid
  public  PVector    position;
  public String ip; // network address of platform

  ArrayList<PVector> points = new ArrayList();
  Boolean empty = true; //deemed empty until assigned an ID

  Tile(int id, PVector position, color col) {
    this.id = id;
    this.position = position; // set the origin position of the platform
    setPoints();
  }

  public void setIp(String platformIp) {
    this.ip = platformIp;
  }

  public void display() {
    pushMatrix();
    translate(this.position.x, this.position.y);

    pushStyle();
    rectMode(CORNER);

    //draw red text in the top right corner of the tile the mcu number
    fill(255, 0, 0);
    textAlign(CENTER, CENTER); // Set text alignment to center
    textSize(14);
    text(buffer.ipAddresses[id], 34, 20);

    noFill(); 
    stroke(220, 200, 100, 200);
    rect(0, 0, UNIT_SIZE, UNIT_SIZE);
    for(int i = 0; i < points.size(); i++) {
      PVector p = points.get(i);
      noFill();
      stroke(60, 200);
      strokeWeight(.75);
      ellipse(p.x, p.y, 16, 16);
      //draw the text of the index number at this position
      fill(220, 200, 100, 200);
      textAlign(CENTER, CENTER); // Set text alignment to center
      textSize(10);
      text(i, p.x, p.y-2);

    }
    popMatrix();
    popStyle();
  }

  public void setPoints() {
    int subUnitSize = UNIT_SIZE/4;
    int i = 0;
    for (int y = subUnitSize/2; y < subUnitSize * 4; y += subUnitSize) { //rows
      for (int x = subUnitSize/2; x < subUnitSize * 4; x += subUnitSize) {//cols
        points.add(new PVector(x, y));
        i++;
      }
    }
  }
  public ArrayList<PVector> getPoints() {
    ArrayList<PVector> copy = new ArrayList<PVector>(points);
    return copy;
  }

}
