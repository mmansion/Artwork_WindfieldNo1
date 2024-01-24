class Grid {

  Tile[] tiles;
  PVector[] center_points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  boolean[] isTiled;
  int decay = 500;
  ArrayList<Point> allPoints;
  
  Grid() {

    //ONE dimensional arrays
    int n = GRID_COLS * GRID_ROWS;

    // tiles are used for visual reference only
    // they are not used for wind vector calculations or activation of nodes
    tiles   = new Tile[n];
    active  = new boolean[n];
    timeOff = new int[n];
    isTiled   = new boolean[n];
    center_points = new PVector[n];

    // allPoints = new ArrayList<PointWithAngle>();
    allPoints = new ArrayList<Point>();

    int i = 0;
    int mcu_count = 0;
    int offset = UNIT_SIZE/2;
    int pointsPerTile = ROWS_PER_TILE * COLS_PER_TILE;
    int row = 0;
    int col = 0;


    for (int y = 0; y < UNIT_SIZE * GRID_ROWS; y += UNIT_SIZE) { //rows
      col = 0;
      for (int x = 0; x < UNIT_SIZE * GRID_COLS; x += UNIT_SIZE) {//cols

        //if there is a tile at this position on the grid
        if (TILE_ARRANGEMENT[row][col] == 1) {

          // maintain a record of the index
          isTiled[i] = true;
          tiles[i] = new Tile(mcu_count++, new PVector(x, y), 255);
          
          ArrayList<PVector> localPoints = tiles[i].getPoints();
         // ArrayList<PVector> offsetPoints = new ArrayList();
          for(int pointIndex = 0; pointIndex < pointsPerTile; pointIndex++) {
            PVector offsetPosition = localPoints.get(pointIndex).copy();
            offsetPosition.x += x;
            offsetPosition.y += y;
            // offsetPositions.add(offsetPosition);

            float angle = 0.0; //TMP
            //float angle = calculateAngle(offsetPosition); // Replace `calculateAngle` with your own angle calculation logic
            Point point = new Point(offsetPosition, angle, tiles[i].id, pointIndex);
           
            allPoints.add(point); // Add the point to the list
          }
                  
        } else {
          isTiled[i] = false;
          tiles[i] = new Tile(-1, new PVector(x, y), 255);
          
          ArrayList<PVector> localPoints = tiles[i].getPoints();
          // ArrayList<PVector> offsetPoints = new ArrayList();
          for(int pointIndex = 0; pointIndex < pointsPerTile; pointIndex++) {
            PVector offsetPosition = localPoints.get(pointIndex).copy();
            offsetPosition.x += x;
            offsetPosition.y += y;

            float angle = 0.0; //TMP
            //float angle = calculateAngle(offsetPosition); // Replace `calculateAngle` with your own angle calculation logic
            Point point = new Point(offsetPosition, angle, tiles[i].id, pointIndex);
          
            allPoints.add(point); // Add the point to the list
          }
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
      

      if (isTiled[i]) {
        //fill(255, 0, 255);
        //ellipse(center_points[i].x, center_points[i].y, 5, 5);
        tiles[i].display();
      }


      noFill();
    }
    
    frameBorder();
  }
  void displayPoints() {
    for (int i = 0; i < allPoints.size(); i++) {
      Point point = allPoints.get(i);
      point.drawArrow();
      point.drawPoint();
    }
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
  // class PointWithAngle {
  //   PVector point;
  //   float x, y, angle;
  //   Arrow arrow = null;
  //   PointWithAngle(PVector point, float angle) {
  //     this.point = point;
  //     this.angle = angle;
  //     this.x = point.x;
  //     this.y = point.y;
  //     this.arrow = new Arrow(point, angle, 5);
  //   }
  //   void drawPoint() {
  //     fill (255, 0, 0);
  //     ellipse(x, y, 10, 10);
  //   }
  //   void drawArrow() {
  //     arrow.display();
  //   }
  // }
}
