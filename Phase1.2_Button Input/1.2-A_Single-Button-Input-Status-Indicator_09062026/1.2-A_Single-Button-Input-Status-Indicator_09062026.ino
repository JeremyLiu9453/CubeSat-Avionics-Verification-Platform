// ============================================
// CubeSat Avionics Verification Platform
// Phase 1.2 A. - Single Button Input Status Indicator
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
// Date: Sep-06, 2026
// ============================================

#define LED_GREEN  PA0
#define LED_YELLOW PA1
#define LED_RED    PA2

#define BUTTON_1   PA3

void setup() {

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  pinMode(BUTTON_1, INPUT_PULLUP);

  // Initial state
  digitalWrite(LED_GREEN, HIGH);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);
}

void loop() {

  if (digitalRead(BUTTON_1) == LOW) {

    // Button pressed → WARNING
    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_YELLOW, HIGH);

  } else {

    // Button released → NOMINAL
    digitalWrite(LED_GREEN, HIGH);
    digitalWrite(LED_YELLOW, LOW);
  }
}