class Point {
  PVector position;
  Arrow arrow = null;
  float x, y, angle;
  long activationTime = 0; // Timestamp when the point was last activated
  int activeDuration = 1000; // Duration in milliseconds the point remains active after being set active

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
    // Automatically set inactive if the active duration has passed
    if (active && millis() - activationTime > activeDuration) {
      active = false;
    }
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

  // Method to activate the point
  void setActive(int duration) {
    active = true;
    activeDuration = duration; // Update active duration based on argument
    activationTime = millis(); // Record the activation time
  }

  // Method to manually set the point inactive
  void setInactive() {
    // Automatically set inactive if the active duration has passed
    if (active && millis() - activationTime > activeDuration) {
      active = false;
    }
  }
}
