// SETTINGS

boolean FREEZE_TO_INSPECT = false;

color LED_OFF = color(150);
color LED_ON = color(255);
static int LED_SIZE = 100;

static boolean FLIP_ZOOM = true;
static int UNIT_SIZE = 100; // grid unit
static int UNITS_PER_FOOT = 10;
static int TILE_SIZE = 4; //ft
static int PIXELS_PER_FOOT = 4;
static int PIXEL_SIZE = 2;
static int TILE_OFFSET = 8; //center sculpture at origin

/* GRID CONFIG
  ------------------------------ */

static int GRID_COLS = 16;
static int GRID_ROWS = 5;
static int GRID_BORDER_MARGIN = 100;

// (16x5) rows: W->E, cols: N->S
// see: assets/tilemap.png
static int[][] TILE_ARRANGEMENT = {
    // a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p
    {  0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 }, // 1
    {  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0 }, // 2
    {  1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1 }, // 3
    {  0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1 }, // 4
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, // 5
};

/* TILE CONFIG
  ------------------------------ */
static int NUM_TILES  = 38;
static int COLS_PER_TILE = 4;
static int ROWS_PER_TILE = 4;

//int POINTS_PER_PLATFORM; //set dynamically

/* NETWORK & COMMS
  ------------------------------ */
UDP udp; //define the udp object
long lastUpdSendTime = 0;
int udpSendTimeDelay = 10;

//String LOCAL_IP = "192.168.1.10";
//int    LOCAL_PORT = 6000;
static int UDP_SEND_PORT = 8020;

static int UDP_PACKET_SIZE = NUM_TILES * COLS_PER_TILE * ROWS_PER_TILE / 8;
