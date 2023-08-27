class Grid {
  
  PVector[] points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  boolean[] tiled;
  
  int decay = 500;
  
  Grid(int r, int c) {
    //one dimensional arrays
    points  = new PVector[c * r];
    active  = new boolean[c * r];
    timeOff = new int[c * r];
    tiled   = new boolean[c * r];
    
    int i = 0;
    int offset = UNIT_SIZE/2;
    int row = 0;
    int col = 0;
    for (int y = offset; y < UNIT_SIZE * r + offset; y += UNIT_SIZE) { //rows
      col = 0;
      for (int x = offset; x < UNIT_SIZE * c + offset; x += UNIT_SIZE) {//cols 
        tiled[i] = boolean(TILE_ARRANGEMENT[row][col]);
        points[i] = new PVector(x, y);
        active[i] = false;
        i++;
        //println("col: " + col);
        col++;
        
      }
      //println("row: " + row);
      row++;
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
      //if (active[i]) {
      //  fill(255);
      //} else {
      //  fill(50);
      //}
      //ellipse(points[i].x, points[i].y, LED_SIZE, LED_SIZE);
      noFill();
      strokeWeight(2);
      stroke(0, 255, 255, 100);
      if(tiled[i]) {
        fill(255, 0, 0, 200);
      }
      ellipse(points[i].x, points[i].y, LED_SIZE, LED_SIZE);
      
      noFill();
      
      rect(points[i].x, points[i].y, UNIT_SIZE, UNIT_SIZE);
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
