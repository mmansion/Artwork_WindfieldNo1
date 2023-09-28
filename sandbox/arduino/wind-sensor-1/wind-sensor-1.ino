const int NUM_READINGS = 10;
const int RECOVERY_TIME = 10;
const int SCALE_FACTOR = 2000;

int _raValues[NUM_READINGS];
int _raLen = NUM_READINGS;
int _raInc = 0;
int _raFinal = 0;


const int OutPin  = A0;   // wind sensor analog pin  hooked up to Wind P sensor "OUT" pin
const int TempPin = A2;   // temp sesnsor analog pin hooked up to Wind P sensor "TMP" pin

int calcRunningAverage() {
  // get sum of arr vals
  int arrSum = sumArray();
  int arrAvg = arrSum / _raLen;

  return arrAvg;
}
void setup() {
    Serial.begin(9600);
    memset(_raValues, 0, sizeof(_raValues));
}

int sumArray() {
  int arrSum  = 0;
  // sum all values
  for (int i = 0; i < _raLen; i++) {
    arrSum += _raValues[i];
    } 
  return arrSum;
}

float normalized(float x) {
  return x / 150.0;
}

float scaleValue(float x) {
  return (x / 150.0) * SCALE_FACTOR;
}

void loop() {

  // read wind
  int windADunits = analogRead(OutPin);
  // formula doesn't account for temp correction
  float windMPH =  pow((((float)windADunits - 264.0) / 85.6814), 3.36814);
  float scaled = scaleValue(windMPH);
   
  _raValues[_raInc] = scaled;   
  _raFinal = calcRunningAverage();

  //visualize
  String str = "";
  for(int i = 0; i < _raFinal; i++) {
//    Serial.print("*");
    str += "*";
  }
  Serial.println(str);
//  Serial.println(_raFinal);
  
  
  _raInc++;
  _raInc = _raInc % _raLen;
  
  delay(RECOVERY_TIME); // analog read recovery time

  
}
