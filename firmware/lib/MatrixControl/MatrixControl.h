// include once
#include <Arduino.h>
#pragma once

class MatrixControl {
    private:
        float ms_delay = 1;

        //array of 16 bools
        bool states[16];

        // 16 byte values (in decimal) are the 'addresses' for
        // activating each point in the multiplexed matrix        
        byte points[16] = {
            135, 139, 141, 142,
            71,   75,  77,  78,
            39,   43,  45,  46,
            23,   27,  29,  30
        };
        void _clear();
        void _show(uint8_t value);

    public:
        MatrixControl();
        ~MatrixControl();
        void setup(float ms_delay);
        void display(); //must be called to display changes from update fns

        //update functions:
        void update(unsigned char bytes[78], int n);
        void setAllHigh();
        void setAllLow();
};

MatrixControl::MatrixControl(/* args */) {}
MatrixControl::~MatrixControl() {}

void MatrixControl::setup(float ms_delay) {
    this->ms_delay = ms_delay;
    //use memset to fill states with 0s
    memset(states, 0, sizeof(states));
}

void MatrixControl::_clear() {
    this->_show(0b00000000);
}

void MatrixControl::setAllHigh() {
  for (int i = 0; i < 16; i++) {
    this->states[i] = 1;
  }
}
void MatrixControl::setAllLow() {
  for (int i = 0; i < 16; i++) {
    this->states[i] = 0;
  }
}

void MatrixControl::update(unsigned char bytes[78], int n) {
    //print byte in binary
    // Serial.print("byte: ");
    // Serial.println(bytes[n], BIN);
    // Serial.print("byte: ");
    // Serial.println(bytes[n+1], BIN);

    for(int i = 0; i < 16; i++) {
        // determine which byte to use: n or n+1
        int byteIndex = n + (i / 8);
        // calc the index within the byte
        int bitIndex = 7 - (i % 8); // reverse the bit index

        //print each bit in the byte with its index:
        // Serial.print("bit ");
        // Serial.print(i);
        // Serial.print(": ");
        // Serial.println((bytes[byteIndex] & (1 << bitIndex)) != 0);
        this->states[i] = (bytes[byteIndex] & (1 << bitIndex)) != 0;
    }

}
void MatrixControl::display() {
    //iterate over ledValues
    for (int i = 0; i < 16; i++) {
        if(this->states[i] == 1) {
            this->_show(this->points[i]);
        } else {
            delay(this->ms_delay);
        }
    }
    _clear();
//   delay(this->delay_after_all);
}

void MatrixControl::_show(uint8_t value) {
    // setlatch pin low so the LEDs don't change while showing in bits
    digitalWrite(LATCH_PIN, LOW);
    // shift out the bits of dataToSend to the shift register (SN74AHCT595N)
    shiftOut(DATA_PIN, CLOCK_PIN, LSBFIRST, value);
    // set latch pin high- this shows data to outputs so the LEDs will light up
    digitalWrite(LATCH_PIN, HIGH);
    delay(this->ms_delay);
}