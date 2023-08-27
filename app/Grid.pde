class Grid {
  PVector[] points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  float spacingX;
  float spacingY;
  
  int decay = 500;
  
  Grid(int c, int r) {
    //one dimensional arrays
    points  = new PVector[c * r];
    active  = new boolean[c * r];
    timeOff = new int[c * r];
    
    int idx = 0;
    
    println(points.length);
    for (int x = UNIT_SIZE; x <= UNIT_SIZE * c; x += UNIT_SIZE) {
      for (int y = UNIT_SIZE; y <= UNIT_SIZE * r; y += UNIT_SIZE) {
            points[idx] = new PVector(x, y);
            active[idx] = false;
            idx++;      
      }
    }
  }
  void allOff() {
    //for(int i = 0; i < points.length; i++) {
    //  if(millis() > timeOff[i]) {
    //    active[i] = false;
    //  }
    //}
  }
  void turnOn(int i) {
    //active[i]  = true;
    //timeOff[i] = millis() + decay;
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
      ellipse(points[i].x, points[i].y, LED_SIZE, LED_SIZE);
    }
  }
  void checkRange(PVector wp) {
    //for (int i = 0; i < points.length; i++) {
    //  if (points[i].dist(wp) < range) {
    //    turnOn(i);
    //  }
    //}
  }
}
