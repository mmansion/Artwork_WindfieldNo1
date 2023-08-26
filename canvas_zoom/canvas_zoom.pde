//a test sketch to get zoom to work

float x=0, y=0;
float w, h;
float X, Y;
float mX, mY, pmX, pmY;
float panx=0, pany=0, px=0, py=0, dpx=0, dpy=0;
float easing=.065;
boolean[] keys=new boolean[2];
float angle=0;
float da;

int zoomDir = 0;
long lastDirChange = 0;

boolean yellow=false;

void setup() {
  size(500, 500);
  w=width;
  h=height;
  smooth();
}

void draw() {
 transform();
  yellow=true;
  background(0);
 


  //some test rectangles
  fill(255);
  rect(225, 225, 50, 50);
  rect(245, 125, 10, 10);
  rect(245, 25, 10, 10);

  fill(255, 0, 0);
  rect(290, 290, 20, 20);

  if (yellow) fill (255, 255, 0, 100);
  else fill(255, 255, 0);
  rect(45, 45, 10, 10);
}

void transform() {
  

    //r to reset all zooms and translates
    if (key == 'r') {
      x=0;
      y=0;
      w=width;
      h=height;
      mX=0;
      mY=0;
      angle=0;
    }
  

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

void mouseWheel(MouseEvent event) {
   float e = event.getCount();
   if(e == 0) return;
   float speed = map(e, 0, 20, 1, 1.2);
   int scrollDir = (e >= 0) ? 1 : -1;
  
   if(millis() - lastDirChange > 300) {
    if(scrollDir != zoomDir) {
      lastDirChange = millis();
      zoomDir = scrollDir;
      println("change dir");
      println(zoomDir);
    }
  }
  
  //print(zoomDir);
  
  //println(e);
  float zoom = (zoomDir > 0) ? 1.01 : 0.99;
  zoom*=speed;
  x += .5 * w * ( 1 - 1 / zoom );
  y += .5 * h * ( 1 - 1 / zoom );
  w *= 1 / zoom;
  h *= 1 / zoom;
    
}

void mouseDragged() {
  float[] m=mouseRotate(constrain(mouseX, 0, width), 
  constrain(mouseY, 0, height), angle, width/2, height/2);
  mX=m[0];
  mY=m[1];

  m=mouseRotate(constrain(pmouseX, 0, width), 
  constrain(pmouseY, 0, height), angle, width/2, height/2);
  pmX=m[0];
  pmY=m[1];

  panx += (mX - pmX) * w/width;
  pany += (mY - pmY) * h/height;
}

void keyPressed() {
  if (keyCode == LEFT) keys[0]=true;
  if (keyCode == RIGHT) keys[1]=true;
}

void keyReleased() {
  if (keyCode == LEFT) keys[0]=false;
  if (keyCode == RIGHT) keys[1]=false;
}

float[] mouseRotate(float mx, float my, float angle, 
float xc, float yc) {
  float mtx=mx;
  float mty=my;
  mx= xc + (mtx-xc) * cos(-angle) - (mty-yc) * sin(-angle);
  my= yc + (mtx-xc) * sin(-angle) + (mty-yc) * cos(-angle);
  float[] mxmy= {
    mx, my
  };
  return mxmy;
}
