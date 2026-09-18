// ============================================
// CubeSat Avionics Verification Platform
// Phase 1.1 - System Status Indicator
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
// Date: Sep-05, 2026
// ============================================

#define LED_GREEN  PA0
#define LED_YELLOW PA1
#define LED_RED    PA2

enum SystemState {
  NOMINAL,
  WARNING,
  FAULT
};

SystemState currentState = NOMINAL;

void setup() {

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

}

void setStatusLED(SystemState state) {

  // Turn everything off first
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);

  switch (state) {

    case NOMINAL:
      digitalWrite(LED_GREEN, HIGH);
      break;

    case WARNING:
      digitalWrite(LED_YELLOW, HIGH);
      break;

    case FAULT:
      digitalWrite(LED_RED, HIGH);
      break;
  }
}

void loop() {

  currentState = NOMINAL;
  setStatusLED(currentState);
  delay(2000);

  currentState = WARNING;
  setStatusLED(currentState);
  delay(2000);

  currentState = FAULT;
  setStatusLED(currentState);
  delay(2000);
}