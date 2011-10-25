#include <Ports.h>
#include <RF12.h>

#define BUTTON_PIN1 12
#define BUTTON_PIN2 13

MilliTimer sendTimer;
typedef struct { byte data; } Payload;
Payload inData, outData;
byte pendingOutput;

void setup () {
    pinMode(BUTTON_PIN1, INPUT);
    digitalWrite(BUTTON_PIN1, HIGH);
    Serial.begin(9600);
    rf12_initialize(2, RF12_868MHZ);
}

static byte produceOutData () {

    if (digitalRead(BUTTON_PIN1) == 0){
      outData = 1;
      return 1;
    }
    if (digitalRead(BUTTON_PIN2) == 0){
      outData = 2;
      return 1;
    }
    return 0;
}

void loop () {
    
    if (rf12_recvDone() && rf12_crc == 0 && rf12_len == sizeof inData) {
        //memcpy(&inData, (byte*) rf12_data, sizeof inData);
        // optional: rf12_recvDone(); // re-enable reception right away
        //consumeInData();
    }

    if (sendTimer.poll(100))
        pendingOutput = produceOutData();

    if (pendingOutput && rf12_canSend()) {
        rf12_sendStart(0, &outData, sizeof outData, 2);
        // optional: rf12_sendWait(2); // wait for send to finish
        pendingOutput = 0;
    }    
}

