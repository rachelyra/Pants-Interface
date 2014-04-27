#include <Ports.h>
#include <RF12.h>

MilliTimer sendTimer;
typedef struct { byte data; } Payload;
Payload inData, outData;
byte pendingOutput;

void setup () {
    Serial.begin(9600);
    rf12_initialize(1, RF12_868MHZ);
}

static void consumeInData () {
    if (inData.data == 1 || inData.data == 2 || inData.data == 3 || inData.data == 4){
      //Serial.print("recv ");
      //Serial.println(inData.data, HEX);
      Serial.write(inData.data);
    }
}

void loop () {
    if (rf12_recvDone() && rf12_crc == 0 && rf12_len == sizeof inData) {
        memcpy(&inData, (byte*) rf12_data, sizeof inData);
        // optional: rf12_recvDone(); // re-enable reception right away
        consumeInData();
    }

    
}

