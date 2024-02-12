class Grid {

  Tile[] tiles;
  
  PVector[] center_points;
  int[] timeOff; //when to turn off in millis
  boolean[] active;
  boolean[] isTiled;
  int decay = 500;
  ArrayList<Point> allPoints;
  
  // Assuming you have a baseDirection variable and a method to update it
  float baseDirection = 0; // Initial direction in degrees
  float directionChangeRate = 0.001; // How quickly the direction changes
  
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

            //float angle = 0.0; //TMP
            //float angle = calculateAngle(offsetPosition); // Replace `calculateAngle` with your own angle calculation logic
            float angle = map(noise(offsetPosition.x * noiseScale, offsetPosition.y * noiseScale), 0, 1, 0, TWO_PI); // map from [0,1] to [0,TWO_PI] for a full rotation
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

            //float angle = 0.0; //TMP
            //float angle = calculateAngle(offsetPosition); // Replace `calculateAngle` with your own angle calculation logic
            float angle = map(noise(offsetPosition.x * noiseScale, offsetPosition.y * noiseScale), 0, 1, 0, TWO_PI); // map from [0,1] to [0,TWO_PI] for a full rotation

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

  void update() { 
    
    // TODO: update wind in this function
    // TODO: update buffer in this function
       
    for (int i = 0; i < allPoints.size(); i++) {    
      Point point = allPoints.get(i);
      
      if(point.onTile()) { //check if point lies on a tile
        println(point.tileId);
      }
      
      float timeOffset = noise(point.position.x * noiseScale, point.position.y * noiseScale, frameCount * noiseScale) * TWO_PI; // TWO_PI for a full rotation
      
      // Adjust baseDirection over time
      baseDirection += directionChangeRate;
      
      // Ensure baseDirection stays within 0-360 degrees
      baseDirection = baseDirection % 360;
      
      // Convert baseDirection to radians for the math functions
      float baseDirectionRadians = radians(baseDirection);
      // Apply timeOffset and baseDirection to calculate the new angle
      point.angle = baseDirectionRadians + timeOffset; // This line adjusts the angle based on base direction and time
      
      // point.active = false;     
      //important to call update on the points to ensure the arrows reflect a change
      point.update();
    }
        
    //baseDirection+=1;
    //if (baseDirection > 360) {
    //  baseDirection = 0;
    //}
    //println("base direct = " + baseDirection);
    //println(allPoints.get(0).angle);
  }

  void display() {
    pushStyle();

    noStroke();
  
    int n = GRID_COLS * GRID_ROWS;
  
    for (int i = 0; i < n; i++) {
      // maybe the grid can be optimized by drawing into a pgraphics once
      if (isTiled[i]) {
        //fill(255, 0, 255);
        //ellipse(center_points[i].x, center_points[i].y, 5, 5);
        tiles[i].display();
      } else {
        noFill();
        strokeWeight(2);
        stroke(0, 255, 255, 50);
        rect(center_points[i].x, center_points[i].y, UNIT_SIZE, UNIT_SIZE);
      }
     
      noFill();
    }
    
    frameBorder();
    popStyle();
  }

  void displayVectors() {
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
  void checkParticlesInRange(Particle[] particles, float range) {
     for (Point point : allPoints) {
      point.active = false; // Reset point's active state for this check
      
      // Now loop through all particles for each point
      for (Particle particle : particles) {
        // Calculate the distance between the current point and particle
        float dist = PVector.dist(point.position, particle.pos);
      
        // Check if the distance is within the specified range
        if (dist <= range) {
          // If so, set the point's active flag to true
          point.active = true;
          break; // Stop checking other particles for this point if one is found within range
        }
      }
    }
  }

  float getAngleAtClosestPoint(PVector pos) {
    float minDist = Float.MAX_VALUE;
    float angle = 0;
    for (Point point : allPoints) {
        float dist = PVector.dist(pos, point.position);
        if (dist < minDist) {
            minDist = dist;
            angle = point.angle;
        }
    }
    return angle;
  }
}
