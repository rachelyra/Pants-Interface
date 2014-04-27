/* Emulate a uskb keyboard and convert serial input to keypresses */

#include "UsbKeyboard.h"

// If the timer isr is corrected
// to not take so long change this to 0.
#define BYPASS_TIMER_ISR 1

void setup() {

#if BYPASS_TIMER_ISR
  // disable timer 0 overflow interrupt (used for millis)
  TIMSK0&=!(1<<TOIE0); // ++
#endif

  Serial.begin(9600);

}

#if BYPASS_TIMER_ISR
void delayMs(unsigned int ms) {
  /*
  */
  for (int i = 0; i < ms; i++) {
    delayMicroseconds(1000);
  }
}
#endif

void loop() {

  UsbKeyboard.update();

  if (Serial.available() > 0) {
   byte code = Serial.read();
if (code == 1) {
   UsbKeyboard.sendKeyStroke(KEY_A);
}
if (code == 2) {
   UsbKeyboard.sendKeyStroke(KEY_S);
}
if (code == 3) {
   UsbKeyboard.sendKeyStroke(KEY_D);
}
if (code == 4) {
   UsbKeyboard.sendKeyStroke(KEY_F);
}

 digitalWrite(13, !digitalRead(13));

  }

}


