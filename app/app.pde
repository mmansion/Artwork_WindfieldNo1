WindParticle[] windParticles;
boolean showParticles = true;
boolean showRange = false;

PGraphics pg;
int numParticles = 2;
float boost = 10.0;
int range = 50; // particle dist to point to activate
Grid grid;
int ledSize = 4;
float noiseScale = 0.01/4; // increase divisor for change in pattern

CanvasCam cam;

void setup() {
  size(800, 800);
  
  rectMode(CENTER);
  background(0);
  windParticles = new WindParticle[numParticles];
  for (int i = 0; i < numParticles; i++) {
    windParticles[i] = new WindParticle(random(width), random(height));
  }
  ellipseMode(CENTER);
  clear();
 
  pg = createGraphics(GRID_ROWS * UNIT_SIZE, GRID_COLS * UNIT_SIZE);
  grid = new Grid(GRID_ROWS, GRID_COLS);
  
 
  cam = new CanvasCam(this);
  
}

void draw() {
 
  if (showParticles) {
    fill(0, 10);
    rect(0, 0, width, height);
    //background(0, 8);
  } else {
    background(0);
  }

  grid.display();
  
  stroke(255);
  for (int i = 0; i < numParticles; i++) {
    windParticles[i].update();
    windParticles[i].display();
  }
}
void mousePressed() {
  
}

void mouseReleased() {
  noiseSeed(millis());
}

class WindParticle {
  PVector pos;
  WindParticle(float x, float y) {
    pos = new PVector(x, y);
  }
  void update() {
    float n = noise(pos.x * noiseScale, pos.y * noiseScale, frameCount * noiseScale * noiseScale);
    float a = TWO_PI * n;
    pos.x += cos(a) * boost;
    pos.y += sin(a) * boost;
    if (!onScreen(pos)) {
      pos.x = random(width);
      pos.y = random(height);
    }

    grid.checkRange(pos);
    
  }
  void display() {
    if (showParticles) {
      point(pos.x, pos.y);
    }
    if(showRange) {
      noFill();
      stroke(0,255,255, 10);
      ellipse(pos.x, pos.y, range, range);
    }
    
  }
}

boolean onScreen(PVector v) {
  return v.x >= 0 && v.x <= width && v.y >= 0 && v.y <= height;
}
