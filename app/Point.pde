class Point {
  PVector position;
  Arrow arrow = null;
  float x, y, angle;

  public int id = -1;     // track which tile this point belongs to
  public int index = -1; // track index position on the tile
  public Boolean active = false;

  Point(PVector position, float angle, int tileId, int pointIndex) {
    this.id = tileId;
    this.index = pointIndex;
    this.position = position.copy();
    this.angle = angle;
    this.arrow = new Arrow(position, angle, 3);
  }
  void update() {
    this.arrow.angle = this.angle;
  }
  void drawPoint() {
    pushStyle();
    if (active && id > -1) {
      noStroke();
      fill(255);
      ellipse(this.position.x, this.position.y, 10, 10);
    }
    popStyle();
  }
  void drawArrow() {
    arrow.display();
  }
}
