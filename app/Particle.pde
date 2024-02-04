class Particle {
    public PVector pos;
    Particle() {
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
    void update2() {
      // Get angle from the closest point in the grid
      float angle = grid.getAngleAtClosestPoint(pos);
  
      // Update position based on the angle
      pos.x += cos(angle) * boost;
      pos.y += sin(angle) * boost;
  
      if (!onScreen(pos)) {
          pos = randParticlePos();
      }
    }
    void display() {
      point(pos.x, pos.y);

      fill(0, 255, 255, 100);
      ellipse(pos.x, pos.y, 5, 5);
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
