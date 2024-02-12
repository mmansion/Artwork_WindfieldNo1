class Point {
  
    PVector position;
    public Boolean active = false;
    Arrow arrow = null;
    float x, y, angle;

    int tileId = -1; //track which tile this point belongs to
    int pointIndex = -1;

    Point(PVector position, float angle, int tileId, int pointIndex) {
      this.tileId = tileId;
      this.position = position.copy();
      this.angle = angle;
      this.arrow = new Arrow(position, angle, 3);
    }
    void update() {
      this.arrow.angle = this.angle;
    }
    void drawPoint() {
      pushStyle();
      if(active && tileId > -1) {
        noStroke();
        fill(255);
        ellipse(this.position.x, this.position.y, 10, 10);  
      }
      popStyle();
    }
    void drawArrow() {
      arrow.display();
    }
    Boolean onTile() {//whether this point belongs to a tile or is an empty position
      return tileId > -1;
    }
}
