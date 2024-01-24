class Point {
  
    PVector position;
    Boolean active = false;
    Arrow arrow = null;
    float x, y, angle;

    int tileId = -1;
    int pointIndex = -1;

    Point(PVector position, float angle, int tileId, int pointIndex) {
      this.tileId = tileId;
      this.position = position.copy();
      this.angle = angle;
      this.arrow = new Arrow(position, angle, 3);
    }
    void drawPoint() {
      if(tileId == -1) {
        noStroke();
        fill(0, 0, 100);
        ellipse(this.position.x, this.position.y, 10, 10);
      } else {
        noFill();
        noStroke();
      }
    }
    void drawArrow() {
      arrow.display();
    }
}