class Circle {
  int x, y, d;
  Boolean hovered = false;

  Circle(int x_, int y_, int d_) {
    x = x_;
    y = y_;
    d = d_;
  }

  boolean contains(int mx, int my) {
    return dist(x, y, mx, my) < d/2;
  }

  void update(int mx, int my) {
    if (contains(mx, my)) {
      this.hovered = true;
      fill(255, 0, 0, 50);
    } else {
      this.hovered = false;
      //noFill();
      fill(255);
    }
  }

  void display(boolean clicked) {
    if (clicked) {
      fill(255, 0, 0, 100);
    }
    ellipse(x, y, d, d);
    noFill();
  }
}
