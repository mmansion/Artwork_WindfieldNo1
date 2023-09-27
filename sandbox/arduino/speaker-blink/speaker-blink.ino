#define SPEAKER_PIN 4
#define LED_PIN 2

const int BPM = 120; //beats per minute
long last_tick = 0;

const float n_32nd = 0.125;
const float n_16th = 0.25;
const float n_8th  = 0.5;
const float n_4th  = 1.0;

float  note_len; //4th, 8th, 16th or 32nd
double bpms = 0.0;

void setup() {
  
  Serial.begin(115200);
  
  pinMode(SPEAKER_PIN, OUTPUT);
  digitalWrite(SPEAKER_PIN, LOW);
  
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  bpms = float(1000/(BPM/60));
  
  note_len = n_32nd;
}

void loop() {

  digitalWrite(SPEAKER_PIN, LOW);
  digitalWrite(LED_PIN, LOW);
  
  if(millis() - last_tick > float(bpms * note_len) ) {
    last_tick = millis();
    digitalWrite(SPEAKER_PIN, HIGH);
    digitalWrite(LED_PIN, HIGH);
    delay(10);    
  }
  
}
