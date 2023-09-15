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

/* PANEL CONFIG
  ------------------------------ */
int NUM_PANELS  = 39;
//int NUM_RINGS      = 10;
//int RING_SPACING   = 10;
//int INNER_DIAM     = 200;
//int OUTER_DIAM = SCREEN_WIDTH - 100;
//int PLATFORM_START_DEG   = 0;
//int PLATFORM_ARC_LENGTH  = 72;
//int PLATFORM_DEG_SPACING = 10;

int POINTS_PER_PLATFORM; //calculated
int COLS_PER_PANEL = 4;
int ROWS_PER_PANEL = 4;


/* NETWORK & COMMS
  ------------------------------ */
UDP udp; //define the udp object
int MTU = 13; //maximum transmission unit (i.e. max bytes per platform)
long lastUpdSendTime = 0;
int udpSendTimeDelay = 10;

String LOCAL_IP = "192.168.1.10";
int    LOCAL_PORT = 6000;

String[] PLATFORM_IPS = {
  "192.168.1.171",
  "192.168.1.172",
  "192.168.1.173",
  "192.168.1.174"
};

 // look into sending byte array data (buffer) - see send() in hypermedia.net lib
 //http://ubaa.net/shared/processing/udp/udp_class_udp.htm

 // byte array used for sending active motor status per platform
 // converted from unsigned char array
 byte[] byteArray = new byte[MTU];
 // character array used for storing active points in platform
 char[] charArr = new char[MTU];
 byte byteVal = -127;
