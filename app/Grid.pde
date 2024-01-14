class Grid {

  Tile[] tiles;
  PVector[] center_points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  boolean[] tiled;
  int decay = 500;
  ArrayList<PointWithAngle> allPoints;
  
  Grid() {
    //one dimensional arrays
    int n = GRID_COLS * GRID_ROWS;
    tiles = new Tile[n];
    active  = new boolean[n];
    timeOff = new int[n];
    tiled   = new boolean[n];
    center_points = new PVector[n];
    // allPoints = new ArrayList();
    allPoints = new ArrayList<PointWithAngle>();

    int i = 0;
    int offset = UNIT_SIZE/2;
    int row = 0;
    int col = 0;


    for (int y = 0; y < UNIT_SIZE * GRID_ROWS; y += UNIT_SIZE) { //rows
      col = 0;
      for (int x = 0; x < UNIT_SIZE * GRID_COLS; x += UNIT_SIZE) {//cols
        if (TILE_ARRANGEMENT[row][col] == 1) {
          tiled[i] = true;
          tiles[i] = new Tile(i, new PVector(x, y), 255);
          
          ArrayList<PVector> localPoints = tiles[i].getPoints();
          ArrayList<PVector> offsetPoints = new ArrayList();
          for(int p = 0; p <  localPoints.size(); p++) {
            PVector offsetPoint = localPoints.get(p).copy();
            offsetPoint.x += x;
            offsetPoint.y += y;
            // offsetPoints.add(offsetPoint);

            float angle = 0.0; //temp
            //float angle = calculateAngle(offsetPoint); // Replace `calculateAngle` with your own angle calculation logic
            PointWithAngle pointWithAngle = new PointWithAngle(offsetPoint, angle);
            allPoints.add(pointWithAngle); // Add the point to the list
          
          }

          
          // allPoints.addAll(offsetPoints); //TODO: pickup here  
                  
        } else {
          tiled[i] = false;
          tiles[i] = null;
        }
        active[i] = false;
        
        center_points[i] = new PVector(x, y);
        i++;
        //println("col: " + col);
        col++;
      }
      //println("row: " + row);
      row++;
    }
   
  }
  void allOff() {
    //for(int i = 0; i < center_points.length; i++) {
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
  
    int n = GRID_COLS * GRID_ROWS;
    for (int i = 0; i < n; i++) {
      //if (active[i]) {
      //  fill(255);
      //} else {
      //  fill(50);
      //}
      //ellipse(center_points[i].x, center_points[i].y, LED_SIZE, LED_SIZE);
      noFill();
      strokeWeight(2);
      stroke(0, 255, 255, 50);
      rect(center_points[i].x, center_points[i].y, UNIT_SIZE, UNIT_SIZE);
      

      if (tiled[i]) {
        //fill(255, 0, 255);
        //ellipse(center_points[i].x, center_points[i].y, 5, 5);
        tiles[i].display();
      }


      noFill();
    }
    frameBorder();
  }
 
  
  void frameBorder() {
    pushStyle();
    rectMode(CORNER);
    stroke(0, 255, 255);
    strokeWeight(2);
    rect(
      -GRID_BORDER_MARGIN/2,
      -GRID_BORDER_MARGIN/2,
      UNIT_SIZE * GRID_COLS + GRID_BORDER_MARGIN,
      UNIT_SIZE * GRID_ROWS + GRID_BORDER_MARGIN);
    popStyle();
  }
  void checkRange(PVector wp) {
    //for (int i = 0; i < center_points.length; i++) {
    //  if (center_points[i].dist(wp) < range) {
    //    turnOn(i);
    //  }
    //}
  }
  // Inner class to hold both PVector and angle
  class PointWithAngle {
    PVector point;
    float x, y, angle;

    PointWithAngle(PVector point, float angle) {
      this.point = point;
      this.angle = angle;
      this.x = point.x;
      this.y = point.y;
    }
  }
}
