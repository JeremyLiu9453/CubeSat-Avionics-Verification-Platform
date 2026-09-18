// ============================================
// CubeSat Avionics Verification Platform
// Phase 1.2 B. - Dual-Button Input Status Indicator
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
// Date: Sep-07, 2026
// ============================================

#define LED_GREEN  PA0
#define LED_YELLOW PA1
#define LED_RED    PA2

#define BUTTON_WARNING PA3
#define BUTTON_FAULT   PA4

void setup() {

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  pinMode(BUTTON_WARNING, INPUT_PULLUP);
  pinMode(BUTTON_FAULT, INPUT_PULLUP);
}

void loop() {

  bool warningPressed =
      digitalRead(BUTTON_WARNING) == LOW;

  bool faultPressed =
      digitalRead(BUTTON_FAULT) == LOW;


  if (faultPressed) {

    // FAULT 具有最高優先權被解決
    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_YELLOW, LOW);
    digitalWrite(LED_RED, HIGH);

  }
  // WARNING 為次等優先順序
  else if (warningPressed) {

    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_YELLOW, HIGH);
    digitalWrite(LED_RED, LOW);

  }
  else {
		// 假設兩個按鍵同時被按下
    digitalWrite(LED_GREEN, LOW);
    digitalWrite(LED_YELLOW, LOW);
    digitalWrite(LED_RED, HIGH);
  }
}