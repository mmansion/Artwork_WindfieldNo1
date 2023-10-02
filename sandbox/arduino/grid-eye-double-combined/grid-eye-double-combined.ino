#include <SparkFun_GridEYE_Arduino_Library.h>
#include <Wire.h>

// Use these values (in degrees C) to adjust the contrast
#define HOT 30
#define COLD 25

int combinedPixelTable[128]; // Combined pixel table for two sensors

GridEYE grideye1;
GridEYE grideye2;

void setup() {
  Wire.begin();

  // Initialize the two GridEYE objects with their addresses
  grideye1.begin(0x68);
  grideye2.begin(0x69);

  Serial.begin(115200);
}

void processGridEye(GridEYE &grideye, int startIndex) {
  for(unsigned char i = 0; i < 64; i++) {
    combinedPixelTable[startIndex + i] = map(grideye.getPixelTemperature(i), COLD, HOT, 0, 3);
  }
}

void displayCombinedGrid() {
  for(unsigned char i = 0; i < 128; i++) {
    if(combinedPixelTable[i] == 0) {
      Serial.print(".");
    } else if(combinedPixelTable[i] == 1) {
      Serial.print("*");
    } else if(combinedPixelTable[i] == 2) {
      Serial.print("o");
    } else if(combinedPixelTable[i] == 3) {
      Serial.print("X");
    }
    Serial.print(" ");
    if((i+1)%8==0){
      Serial.println();
    }
  }
  Serial.println();
  Serial.println();
}

void loop() {
  // Process the two GridEYE sensors and store the results in the combinedPixelTable
  processGridEye(grideye1, 0);   // first sensor fills indices 0 to 63
  processGridEye(grideye2, 64);  // second sensor fills indices 64 to 127

  // Display the combined grid
  displayCombinedGrid();

  // Delay between readings
  delay(100);
}
