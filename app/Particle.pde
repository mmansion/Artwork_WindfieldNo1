class Particle {
    public PVector pos;
    Particle() {
        pos = this.randParticlePos();
    }
    void update() {
        float n = noise(pos.x * noiseScale, pos.y * noiseScale, frameCount * noiseScale * noiseScale);
        float a = TWO_PI * n;
        pos.x += cos(a) * wind.speed;
        pos.y += sin(a) * wind.speed;
        
        if (!onScreen(pos)) {
          pos = randParticlePos();
        }
    }
    void update2() {
      // Get angle from the closest point in the grid
      float angle = grid.getAngleAtClosestPoint(pos);
  
      // Update position based on the angle
      pos.x += cos(angle) * wind.speed;
      pos.y += sin(angle) * wind.speed;
  
      if (!onScreen(pos)) {
          pos = randParticlePos();
      }
    }
    void display() {
      point(pos.x, pos.y);
      noStroke();
      fill(100, 150, 255, 80);
      ellipse(pos.x, pos.y, particleSize, particleSize);
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
