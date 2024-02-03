class Particle {
    PVector pos;
    Particle() {
        // pos = new PVector(x, y);
        //pos = pos.copy();
        pos = this.randParticlePos();
    }
    void update() {
        float n = noise(pos.x * noiseScale, pos.y * noiseScale, frameCount * noiseScale * noiseScale);
        float a = TWO_PI * n;
        pos.x += cos(a) * boost;
        pos.y += sin(a) * boost;
        if (!onScreen(pos)) {
          pos = randParticlePos();
        }

        //grid.checkRange(pos);
    }
    void display() {
      point(pos.x, pos.y);
 
      if(SHOW_RANGE) {
          //noFill();
          fill(255);
          ellipse(pos.x, pos.y, range, range);
      }
  }
  PVector randParticlePos() {
    return new PVector(random(GRID_COLS * UNIT_SIZE), random(GRID_ROWS * UNIT_SIZE));
  }
  boolean onScreen(PVector v) {
    int w = GRID_COLS * UNIT_SIZE + UNIT_SIZE;
    int h = GRID_ROWS * UNIT_SIZE + UNIT_SIZE;
    return v.x >= -UNIT_SIZE && v.x <= w && v.y >= -UNIT_SIZE && v.y <= h;
  }
}
