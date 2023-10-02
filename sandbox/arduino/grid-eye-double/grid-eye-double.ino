#include <SparkFun_GridEYE_Arduino_Library.h>
#include <Wire.h>

// Use these values (in degrees C) to adjust the contrast
#define HOT 40
#define COLD 20

int pixelTable1[64];
int pixelTable2[64];

GridEYE grideye1;
GridEYE grideye2;

void setup() {

  Wire.begin();

  // Initialize the two GridEYE objects with their addresses
  grideye1.begin(0x68);
  grideye2.begin(0x69);

  Serial.begin(115200);
}

void processGridEye(GridEYE &grideye, int pixelTable[]) {
  for(unsigned char i = 0; i < 64; i++) {
    pixelTable[i] = map(grideye.getPixelTemperature(i), COLD, HOT, 0, 3);
  }

  for(unsigned char i = 0; i < 64; i++) {
    if(pixelTable[i]==0){Serial.print(".");}
    else if(pixelTable[i]==1){Serial.print("o");}
    else if(pixelTable[i]==2){Serial.print("0");}
    else if(pixelTable[i]==3){Serial.print("O");}
    Serial.print(" ");
    if((i+1)%8==0){
      Serial.println();
    }
  }

  Serial.println();
}

void loop() {

  // Process the first GridEYE
  Serial.println("GridEYE 1:");
  processGridEye(grideye1, pixelTable1);

  // Delay between readings
  delay(100);

//  // Process the second GridEYE
//  Serial.println("GridEYE 2:");
//  processGridEye(grideye2, pixelTable2);
//
//  // Delay between readings
//  delay(100);
}
