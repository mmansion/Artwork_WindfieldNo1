class Grid {
  
  PVector[] points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  float spacingX;
  float spacingY;
  
  int decay = 500;
  
  Grid(int r, int c) {
    points  = new PVector[r * c];
    active  = new boolean[r * c];
    timeOff = new int[r * c];
    
    spacingX = width / (r + 1);
    spacingY = height / (c + 1);
    
    int idx = 0;
    
    for (float x = spacingX; x < width; x += spacingX) {
      for (float y = spacingY; y < height; y += spacingY) {
        if (idx < points.length) {
            points[idx] = new PVector(x, y);
            active[idx] = false;
            //timeouts.append(0);
            idx++;
        }
        //points[idx] = new PVector(x, y);
        //activePoints[idx] = false;
        //timeouts.append(0);
        //idx++;
      }
    }
  }
  void allOff() {
    for(int i = 0; i < points.length; i++) {
      if(millis() > timeOff[i]) {
        active[i] = false;
      }
    }
  }
  void turnOn(int i) {
    active[i]  = true;
    timeOff[i] = millis() + decay;
  }
  void display() {
    allOff();
    noStroke();
    for (int i = 0; i < points.length; i++) {
      if (active[i]) {
        fill(255);
      } else {
        fill(50);
      }
      ellipse(points[i].x, points[i].y, ledSize, ledSize);
    }
  }
  void checkRange(PVector wp) {
    for (int i = 0; i < points.length; i++) {
      if (points[i].dist(wp) < range) {
        turnOn(i);
      }
    }
  }
}
