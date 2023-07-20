//SerialDriver.cpp 
#include "SerialEbyteDriver.h"   

#include <Arduino.h>

HardwareSerial * _HardSerial; // member within class

#define BAUDRATE 115200

const int8_t sID0 = 0;
const int8_t sID1 = 1;
const int8_t sID2 = 2;
const int8_t sID3 = 3;

extern "C" void SerialEbyteDriver_Init(int8_t serialID)
{ 
    if(serialID == sID0) {
        Serial.begin(BAUDRATE);
        _HardSerial = &Serial;
    }
    if(serialID == sID1) {
        Serial1.begin(BAUDRATE);
        _HardSerial = &Serial1;
    }
    if(serialID == sID2) {
        Serial2.begin(BAUDRATE);
        _HardSerial = &Serial2;
    }
    if(serialID == sID3) {
        Serial3.begin(BAUDRATE);
        _HardSerial = &Serial3;
    }    

    pinMode(A0, OUTPUT);
    pinMode(A1, OUTPUT);
    digitalWrite(A0, LOW);
    digitalWrite(A1, LOW);
} 
extern "C" void SerialEbyteDriver_Step_Send(int8_t data_length, int8_t* data, int8_t enSend) 
{ 
    if (enSend > 0) for(int i = 0; i < data_length; i++) _HardSerial->write(data[i]);
} 
extern "C" void SerialEbyteDriver_Step_Recv(int8_t data_length, uint8_t* data, int8_t* status) 
{ 
    *status = 0;
    if(_HardSerial->available() >= data_length){
        *status = 1;
        for(int i = 0; i < data_length; i++) *(data + i) = _HardSerial->read();
    }
}