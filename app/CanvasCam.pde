//import processing.event.*;


public class CanvasCam {
  float x=0, y=0;
  float w, h;
  float X, Y;
  float mX, mY, pmX, pmY;
  float panx=50, pany=50, px=0, py=0, dpx=0, dpy=0;
  float easing=.065;
  
  boolean[] keys = new boolean[2];
  
  float angle=0;
  float da;
  int zoomDir = 0;
  long lastDirChange = 0;

  CanvasCam(PApplet p) { //canvas w and h
    this.w = p.width;
    this.h = p.height;
    p.registerMethod("pre", this); //before draw
    p.registerMethod("draw", this); //after draw
    p.registerMethod("mouseEvent", this);
    p.registerMethod("keyEvent", this);
    // At the end of drawing.
    //p.registerMethod("draw", this);
  }
  
  float[] mouseRotate(float mx, float my, float angle,
    float xc, float yc) {
    float mtx=mx;
    float mty=my;
    mx= xc + (mtx-xc) * cos(-angle) - (mty-yc) * sin(-angle);
    my= yc + (mtx-xc) * sin(-angle) + (mty-yc) * cos(-angle);
    float[] mxmy= { mx, my };
    return mxmy;
  }

  public void draw() {
   
  }

  //void mousePressed() {
  //  println("mouse was pressed at frame "+frameCount);
  //}

  public void mouseEvent(MouseEvent e) {
    switch (e.getAction()) {
      case MouseEvent.PRESS:
        break;
      case MouseEvent.RELEASE:
        break;
      case MouseEvent.DRAG:
      
        float[] m = mouseRotate(constrain(mouseX, 0, width),
        constrain(mouseY, 0, height), angle, width/2, height/2);
        mX=m[0];
        mY=m[1];

        m=mouseRotate(constrain(pmouseX, 0, width),
        constrain(pmouseY, 0, height), angle, width/2, height/2);
        pmX=m[0];
        pmY=m[1];

        panx += (mX - pmX) * w/width;
        pany += (mY - pmY) * h/height;
        break;
        
      case MouseEvent.WHEEL: //TODO: smooth with rolling average of count
        float count = e.getCount();
        if(FLIP_ZOOM) count *= -1;
        if(count == 0) return;
        float speed = map(count, 0, 20, 1, 1.2);
        int scrollDir = (count >= 0) ? 1 : -1;
        
        if(scrollDir != zoomDir) {
          if(millis() - lastDirChange > 200) {
            lastDirChange = millis();
            zoomDir = scrollDir;
          } else {
            return;
          }
        }
        float zoom = (zoomDir > 0) ? 1.01 : 0.99;
        zoom*=speed;
        x += .5 * w * ( 1 - 1 / zoom );
        y += .5 * h * ( 1 - 1 / zoom );
        w *= 1 / zoom;
        h *= 1 / zoom;
        break;
      default:
        break;
    }
  }
  void onKeyPress() {
    
  }
  public void keyEvent(KeyEvent e) {
    if (!keyRepeatEnabled && e.isAutoRepeat()) return;

    char key2 = e.getKey();
    keyCode = e.getKeyCode();

    switch (e.getAction()) {
      case KeyEvent.PRESS:    
        println("keypressed");
        if (keyCode == LEFT)  {
          println("LEFT-PRESS");
          this.keys[0]=true;
        }
        if (keyCode == RIGHT) {
          println("RIGHT-PRESS");
          this.keys[1]=true;
        }
        break;
      case KeyEvent.RELEASE:  
        if (keyCode == LEFT)  {
          println("LEFT-RELEASE");
          keys[0]=false;
        }
        if (keyCode == RIGHT) {
          println("RIGHT-RELEASE");
          keys[1]=false;
        }
        break;
      case KeyEvent.TYPE:
        println(key2);
        if(key2 == 'r') {
          x=0;
          y=0;
          w=width;
          h=height;
          mX=0;
          mY=0;
          angle=0;
          zoomDir = 0;
        }
        
        //this.keyTyped( key2);
        break;
      }
  }

  public void pre() {
    
    //mouseDragged translation
    dpx= (panx - px) * easing;
    dpy= (pany - py) * easing;
    x -= dpx;
    y -= dpy;
    px += dpx;
    py += dpy;

    //arrowkey Rotation, keys[]
    if (keys[0]) angle+=radians(-2);
    if (keys[1]) angle+=radians(2);

    translate(width/2, height/2);
    rotate(angle);
    translate(-width/2, -height/2);

    scale( width / w, height / h);
    translate(-x, -y);
  }
}
