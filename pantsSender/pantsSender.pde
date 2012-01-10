#include <Ports.h>
#include <RF12.h>

#define BUTTON_PIN1 4
#define BUTTON_PIN2 7

MilliTimer sendTimer;
typedef struct { byte data; } Payload;
Payload inData, outData;
byte pendingOutput;

void setup () {
    pinMode(BUTTON_PIN1, INPUT);
    digitalWrite(BUTTON_PIN1, HIGH);
    pinMode(BUTTON_PIN2, INPUT);
    digitalWrite(BUTTON_PIN2, HIGH);
    Serial.begin(9600);
    rf12_initialize(2, RF12_868MHZ);
}

static byte produceOutData () {

   // Get the status of each pin
   byte button_pin1_status = digitalRead( BUTTON_PIN1 );
   byte button_pin2_status = digitalRead( BUTTON_PIN2 );

   static byte button_pin1_was_pressed = 0;
   static byte button_pin2_was_pressed = 0;

   // If button 1 is pressed and was not pressed the last time we checked
   // then this is a new keypress and should be sent to the computer.
   // Otherwise, if it is not pressed and it was pressed the last time we checked
   // then it has been released and we need to update the 'pressed' variable to
   // indicate that.
   if( (button_pin1_status == 0) && (button_pin1_was_pressed == 0) )
   {
      outData.data = 1;
      button_pin1_was_pressed = 1;
      return 1;
   }
   else if( (button_pin1_status == 1) && (button_pin1_was_pressed == 1) )
   {
      button_pin1_was_pressed = 0;
   }


   // Same as above for button 2
   if( (button_pin2_status == 0) && (button_pin2_was_pressed == 0) )
   {
      outData.data = 2;
      button_pin2_was_pressed = 1;
      return 1;
   }
   else if( (button_pin2_status == 1) && (button_pin2_was_pressed == 1) )
   {
      button_pin2_was_pressed = 0;
   }

   // Otherwise nothing interesting happened
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
        //Serial.println(outData.data,DEC);
    }    
}

