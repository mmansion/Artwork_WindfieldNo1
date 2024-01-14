class Arrow {
    float angle;
    float scale;
    float x;
    float y;
    
    Arrow(PVector pos, float angle, float scale) {
        this.angle = angle;
        this.scale = scale;
        this.x = pos.x;
        this.y = pos.y;
    }
    
    void display() {
        pushMatrix();
        pushStyle();

        translate(x, y);
        rotate(angle);
        
        float arrowSize = 10 * scale;
        float arrowHeadSize = 3 * scale;
        
        stroke(255);
        strokeWeight(1);
       
        // Draw arrow body
        line(-arrowSize/2, 0, arrowSize/2, 0); // Centered arrow body
        
        // Draw arrowhead
        beginShape();
        vertex(arrowSize/2, 0);
        vertex(arrowSize/2 - arrowHeadSize, -arrowHeadSize / 2);
        vertex(arrowSize/2 - arrowHeadSize, arrowHeadSize / 2);
        endShape(CLOSE);
        
        popStyle();
        popMatrix();

    }
}
