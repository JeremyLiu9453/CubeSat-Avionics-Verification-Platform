// ============================================
// CubeSat Avionics Verification Platform
// Phase 1.3 A. - Swith Four-State (FSM)
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
// Date: Sep-07, 2026
// ============================================

#define LED_GREEN   PA0
#define LED_YELLOW  PA1
#define LED_RED     PA2

#define BTN_WARNING PA3
#define BTN_FAULT   PA4

enum SystemState {
  BOOT,
  NOMINAL,
  WARNING,
  FAULT,
  RECOVERY
};

SystemState currentState = BOOT;

// 用來偵測「剛剛按下」
// 避免按住按鍵時重複觸發
bool lastWarning = HIGH;
bool lastFault = HIGH;

unsigned long recoveryStart = 0;


void setLED(bool green, bool yellow, bool red) {
  digitalWrite(LED_GREEN, green);
  digitalWrite(LED_YELLOW, yellow);
  digitalWrite(LED_RED, red);
}


void setup() {

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  pinMode(BTN_WARNING, INPUT_PULLUP);
  pinMode(BTN_FAULT, INPUT_PULLUP);

  // BOOT indication
  setLED(HIGH, HIGH, HIGH);

  delay(1000);

  currentState = NOMINAL;
}


void loop() {

  bool warningNow = digitalRead(BTN_WARNING);
  bool faultNow   = digitalRead(BTN_FAULT);

  // HIGH -> LOW 代表「剛按下」
  bool warningPressed =
      (lastWarning == HIGH && warningNow == LOW);

  bool faultPressed =
      (lastFault == HIGH && faultNow == LOW);


  // =========================
  // State transition logic
  // =========================

  switch (currentState) {

    case NOMINAL:

      if (faultPressed) {
        currentState = FAULT;
      }
      else if (warningPressed) {
        currentState = WARNING;
      }

      break;


    case WARNING:

      if (faultPressed) {
        currentState = FAULT;
      }

      break;


    case FAULT:

      // WARNING button acts as ACK / Recovery command
      if (warningPressed) {
        currentState = RECOVERY;
        recoveryStart = millis();
      }

      break;


    case RECOVERY:

      // 3 seconds recovery period
      if (millis() - recoveryStart >= 3000) {
        currentState = NOMINAL;
      }

      break;


    case BOOT:
      break;
  }


  // =========================
  // State output logic
  // =========================

  switch (currentState) {

    case NOMINAL:
      setLED(HIGH, LOW, LOW);
      break;

    case WARNING:
      setLED(LOW, HIGH, LOW);
      break;

    case FAULT:
      setLED(LOW, LOW, HIGH);
      break;

    case RECOVERY:

      // Yellow LED blink
      if ((millis() / 300) % 2 == 0) {
        setLED(LOW, HIGH, LOW);
      }
      else {
        setLED(LOW, LOW, LOW);
      }

      break;

    case BOOT:
      setLED(HIGH, HIGH, HIGH);
      break;
  }


  // 記住這一次按鍵狀態
  lastWarning = warningNow;
  lastFault = faultNow;

  delay(20);
}