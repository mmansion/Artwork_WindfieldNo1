WindParticle[] windParticles;
boolean showParticles = false;
boolean applyGrid = true;

boolean showRange = true;

int numParticles = 2;
float boost = 10.0;
int range = 50; // particle dist to point to activate
Grid grid;
int ledSize = 4;
int cols = 16;
int rows = 16;
float noiseScale = 0.01/4; // increase divisor for change in pattern

CanvasCam cam;

void setup() {
  size(800, 800);
  
  
  background(0);
  windParticles = new WindParticle[numParticles];
  for (int i = 0; i < numParticles; i++) {
    windParticles[i] = new WindParticle(random(width), random(height));
  }
  ellipseMode(CENTER);
  clear();
  if (applyGrid) {
    grid = new Grid(cols, rows);
  }
  
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
  if (applyGrid) {
    grid.display();
  }
  stroke(255);
  for (int i = 0; i < numParticles; i++) {
    windParticles[i].update();
    windParticles[i].display();
  }
}
void mousePressed() {
  println("mouse was pressed");
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
    if (applyGrid) {
      grid.checkRange(pos);
    }
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
