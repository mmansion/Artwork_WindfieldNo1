class Particle {
    PVector pos = new PVector(0, 0);
    Particle(PVector pos) {
        // pos = new PVector(x, y);
        pos = pos.copy();
    }
    void update() {
        float n = noise(pos.x * noiseScale, pos.y * noiseScale, frameCount * noiseScale * noiseScale);
        float a = TWO_PI * n;
        pos.x += cos(a) * boost;
        pos.y += sin(a) * boost;
        if (!onScreen(pos)) {
        pos = randParticlePos();
        }

        grid.checkRange(pos);
    }
    void display() {
        if (showParticles) {
        point(pos.x, pos.y);
    }
    if(showRange) {
        //noFill();
        fill(255);
        ellipse(pos.x, pos.y, range, range);
    }
    
  }
    // PVector position;
    // PVector velocity;
    // PVector acceleration;
    // float lifespan;

    // Particle(PVector pos) {
    //     position = pos.copy();
    //     velocity = new PVector();
    //     acceleration = new PVector();
    //     lifespan = 255.0;
    // }

    // void applyForce(PVector force) {
    //     acceleration.add(force);
    // }

    // void update() {
    //     velocity.add(acceleration);
    //     position.add(velocity);
    //     acceleration.mult(0);
    //     lifespan -= 2.0;
    // }

    // void display() {
    //     stroke(255, lifespan);
    //     fill(255, lifespan);
    //     ellipse(position.x, position.y, 8, 8);
    // }

    // boolean isDead() {
    //     return lifespan < 0.0;
    // }
}
