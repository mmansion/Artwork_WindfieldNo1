/* App Objects
 ------------------------------ */
Buffer buffer;

Wind wind;

Particle[] windParticles;
boolean SHOW_PARTICLES = true;

Grid grid;

PGraphics pg;

float particleSize = MIN_PARTICLE_SIZE;
//float boost = 10.0;

int ledSize = 4;
float noiseScale = 0.01/4; // increase divisor for change in pattern

CanvasCam cam;
void settings() {
  size(UNIT_SIZE*GRID_COLS + GRID_BORDER_MARGIN, UNIT_SIZE*GRID_ROWS + GRID_BORDER_MARGIN);
}

void setup() {

  background(0);
  windParticles = new Particle[NUM_PARTICLES];
  for (int i = 0; i < NUM_PARTICLES; i++) {
    windParticles[i] = new Particle();
  }
  ellipseMode(CENTER);

  pg = createGraphics(GRID_ROWS * UNIT_SIZE, GRID_COLS * UNIT_SIZE);

  // creates new tile grid according to config/TILE_ARRANGEMENT
  grid = new Grid();

  buffer = new Buffer(this);

  cam = new CanvasCam(this);

  wind = new Wind();
}
// 1 = grid dev
// 2 = tile dev
int MODE = 1;
int inc = 0;
int wait_posFrame = 2000;
int wait_buildGrid = 4000;
void draw() {

  if (FREEZE_TO_INSPECT) return;
  wind.update();

  if (millis() > wait_posFrame) {

    if (MODE == 1) {
      background(0);
      grid.update();
      grid.checkRange(windParticles);

      grid.display();
      grid.displayVectors();

      stroke(255);
      particleSize = lerp(particleSize, int(map(wind.speed, WIND_MIN_SPD, WIND_MAX_SPD, MIN_PARTICLE_SIZE, MAX_PARTICLE_SIZE)), 0.1);
      if (SHOW_PARTICLES && millis() > wait_buildGrid) {
        for (int i = 0; i < NUM_PARTICLES; i++) {
          windParticles[i].update2();
          //if(wind.speed >= MIN_WIND_SPD) {//display only if above min
            windParticles[i].display();
          //}
        }
      }
    }
  }
}
Boolean toggleFreeze = false;
void mousePressed() {
  FREEZE_TO_INSPECT = !FREEZE_TO_INSPECT;
  if (FREEZE_TO_INSPECT) {
    buffer.printBytes();
  }
}

void mouseReleased() {
  //noiseSeed(millis());
}
