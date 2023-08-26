WindParticle[] windParticles;
boolean showParticles = true;
boolean applyGrid = true;
int numParticles = 1000;
float boost = 1.0;
int range = 10; // particle dist to point to activate
int decay = 500;
Grid grid;
int ledSize = 4;
int cols = 16;
int rows = 16;
float noiseScale = 0.01/4; // increase divisor for change in pattern
int particleSize = 20;

void setup() {
  size(800  , 800);
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
    // ellipse(pos.x, pos.y, particleSize, particleSize);
  }
}

boolean onScreen(PVector v) {
  return v.x >= 0 && v.x <= width && v.y >= 0 && v.y <= height;
}

class Grid {
  PVector[] points;
  boolean[] activePoints;
  IntList timeouts;
  float spacingX;
  float spacingY;
  Grid(int r, int c) {
    points = new PVector[r * c];
    activePoints = new boolean[r * c];
    timeouts = new IntList(r * c);
    spacingX = width / (r + 1);
    spacingY = height / (c + 1);
    int idx = 0;
    for (float x = spacingX; x < width; x += spacingX) {
      for (float y = spacingY; y < height; y += spacingY) {
        if (idx < points.length) {
            points[idx] = new PVector(x, y);
            activePoints[idx] = false;
            timeouts.append(0);
            idx++;
        }
        //points[idx] = new PVector(x, y);
        //activePoints[idx] = false;
        //timeouts.append(0);
        //idx++;
      }
    }
  }
  void turnOn(int i) {
    //activePoints[i] = true;
    //if (timeouts.get(i) != 0) {
    //  clearTimeout(timeouts.get(i));
    //}
    //int timeoutID = setTimeout(() -> {
    //  activePoints[i] = false;
    //}, decay);
    //timeouts.set(i, timeoutID);
  }
  void display() {
    noStroke();
    for (int i = 0; i < points.length; i++) {
      if (activePoints[i]) {
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

int setTimeout(Runnable runnable, int delay) {
  return java.util.concurrent.Executors.newSingleThreadScheduledExecutor().schedule(runnable, delay, java.util.concurrent.TimeUnit.MILLISECONDS).hashCode();
}

void clearTimeout(int timeoutID) {
  // Unfortunately, we can't really clear timeouts in Processing in the same way as in JavaScript.
  // This function is a placeholder.
}
