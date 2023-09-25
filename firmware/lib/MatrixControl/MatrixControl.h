// include once
#include <Arduino.h>
#pragma once

class MatrixControl {
    private:
        float delay_after_show = 1;
        float delay_after_all = 50;

        //array of 16 bools
        bool states[16];

        //16 ints that represent the byte value for controlling the matrix
        byte points[16] = {
            135, 139, 141, 142,
            71,   75,  77,  78,
            39,   43,  45,  46,
            23,   27,  29,  30
        };
    public:
        MatrixControl();
        ~MatrixControl();
        void display();
        void update(unsigned char bytes[78], int n);
        void clear();
        void show(uint8_t value);
};

void MatrixControl::clear() {
    this->show(0b00000000);
}

MatrixControl::MatrixControl(/* args */) {
    //use memset to fill states with 0s
    memset(states, 0, sizeof(states));
}

MatrixControl::~MatrixControl() {}

void MatrixControl::update(unsigned char bytes[78], int n) {
    for(int i = 0; i < 16; i++) {
        // determine which byte to use: n or n+1
        int byteIndex = n + (i / 8);
        // calc the index within the byte
        int bitIndex = i % 8;
        this->states[i] = (bytes[byteIndex] & (1 << bitIndex)) != 0;
    }
}
void MatrixControl::display() {
    //iterate over ledValues
    for (int i = 0; i < 16; i++) {
        if(this->states[i] == 1) {
            this->show(this->points[i]);
        } else {
            delay(this->delay_after_show);
        }
    }
    clear();
//   delay(this->delay_after_all);
}
void MatrixControl::show(uint8_t value) {
    // setlatch pin low so the LEDs don't change while showing in bits
    digitalWrite(latchPin, LOW);
    // shift out the bits of dataToSend to the shift register (SN74AHCT595N)
    shiftOut(dataPin, clockPin, LSBFIRST, value);
    // set latch pin high- this shows data to outputs so the LEDs will light up
    digitalWrite(latchPin, HIGH);
    delay(this->delay_after_show);
}