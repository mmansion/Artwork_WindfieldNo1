/* App Objects
  ------------------------------ */
UdpSender udpSender;


Particle[] windParticles;
boolean showParticles = true;
boolean showRange = true;

Grid grid;

PGraphics pg;
int numParticles = 200;
float boost = 10.0;
int range = 5; // particle dist to point to activate

int ledSize = 4;
float noiseScale = 0.01/4; // increase divisor for change in pattern

CanvasCam cam;
void settings() {
    size(UNIT_SIZE*GRID_COLS, UNIT_SIZE*GRID_ROWS);

}
void setup() {
  
  background(0);
  windParticles = new Particle[numParticles];
  for (int i = 0; i < numParticles; i++) {
    PVector pos = randParticlePos();
    windParticles[i] = new Particle(pos);
  }
  ellipseMode(CENTER);
  clear();
 
  pg = createGraphics(GRID_ROWS * UNIT_SIZE, GRID_COLS * UNIT_SIZE);
  
  // creates new tile grid according to config/TILE_ARRANGEMENT
  grid = new Grid(); 
  
  cam = new CanvasCam(this);
  
}
// 1 = grid dev
// 2 = tile dev
int MODE = 1;

Boolean showWindParticles = false;
int inc = 0;
void draw() { 
 
  
  
  if(MODE == 1) {
    background(0);
    grid.display();
    grid.displayPoints();
    
    //pushStyle();
    //fill(255, 0, 0);
    //PVector p = grid.allPoints.get(inc);
    //ellipse(p.x, p.y, 10, 10);
    //popStyle();
    
    // for(int i = 0; i < grid.allPoints.size(); i++) {
    //   fill(255);
    //   ellipse(grid.allPoints.get(i).x, grid.allPoints.get(i).y, 10, 10);
    // }
    
    stroke(255);
    if(showWindParticles) {
      for (int i = 0; i < numParticles; i++) {
        windParticles[i].update();
        windParticles[i].display();
      }
    }
    
    
  }
  
  if(MODE == 2) {
    background(0);
    //Panel(int id, PVector pos, float deg, color col) {
    Tile tile = new Tile(0, new PVector(0,0), 255);
    tile.display();
  }
 
  //if (showParticles) {
  //  fill(0, 10);
  //  rect(0, 0, width, height);
  //  //background(0);
  //} else {
  //  background(0);
  //}
  
  
}
void mousePressed() {
  
}

void mouseReleased() {
  noiseSeed(millis());
}



PVector randParticlePos() {
  return new PVector(random(GRID_COLS * UNIT_SIZE), random(GRID_ROWS * UNIT_SIZE));
}

boolean onScreen(PVector v) {
  int w = GRID_COLS * UNIT_SIZE + UNIT_SIZE;
  int h = GRID_ROWS * UNIT_SIZE + UNIT_SIZE;
  return v.x >= -UNIT_SIZE && v.x <= w && v.y >= -UNIT_SIZE && v.y <= h;
}
