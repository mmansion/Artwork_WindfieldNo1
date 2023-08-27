// SETTINGS

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

static int GRID_COLS = 16;
static int GRID_ROWS = 5;

 // (16x5) rows: W->E, cols: N->S
static int[][] TILE_ARRANGEMENT = {
    // a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p
    {  0, 0, 0, 1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 1, 0, 0 }, // 1
    {  1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 0, 0, 0, 1, 0, 0 }, // 2
    {  1, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 1, 0, 1 }, // 3
    {  0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 1 }, // 4
    {  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1 }, // 5
};
