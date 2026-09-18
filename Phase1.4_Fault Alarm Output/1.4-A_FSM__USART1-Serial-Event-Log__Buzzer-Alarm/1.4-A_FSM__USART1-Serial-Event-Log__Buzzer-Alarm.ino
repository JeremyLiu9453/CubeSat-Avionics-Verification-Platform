// ============================================
// CubeSat OBC - Phase 1.4
// FSM + USART1 Serial Event Log + Buzzer Alarm
//
// Date: Sep-11, 2026
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
// 
// LEDs:
// PA0 = GREEN
// PA1 = YELLOW
// PA2 = RED
//
// Buttons:
// PA3 = WARNING
// PA4 = FAULT
//
// UART:
// PA9 = USART1 TX
// UPA10 = SART1 RX
// Baud = 9600
// 
// Buzzer: 
// PB0 = Sound Output
// ============================================

#include "Arduino.h"

// LEDs
#define LED_GREEN    PA0
#define LED_YELLOW   PA1
#define LED_RED      PA2

// Buttons
#define BTN_WARNING  PA3
#define BTN_FAULT    PA4

// Active Buzzer
#define BUZZER       PB0

// UART
Uart DebugSerial(USART1);


// ============================================
// FSM
// ============================================

enum SystemState {
  BOOT,
  NOMINAL,
  WARNING,
  FAULT,
  RECOVERY
};

SystemState currentState = BOOT;


// Button edge detection
int lastWarning = HIGH;
int lastFault   = HIGH;


// Recovery
unsigned long recoveryStart = 0;


// LED blink
unsigned long lastLedBlink = 0;
bool yellowBlinkState = false;


// Buzzer
unsigned long lastBuzzerToggle = 0;
bool buzzerState = false;


// ============================================
// State Name
// ============================================

const char* stateName(SystemState state) {

  switch (state) {
    case BOOT:     return "BOOT";
    case NOMINAL:  return "NOMINAL";
    case WARNING:  return "WARNING";
    case FAULT:    return "FAULT";
    case RECOVERY: return "RECOVERY";

    default:       return "UNKNOWN";
  }
}


// ============================================
// State Change + Log
// ============================================

void changeState(SystemState newState) {

  DebugSerial.print("[EVENT] ");
  DebugSerial.print(stateName(currentState));
  DebugSerial.print(" -> ");
  DebugSerial.println(stateName(newState));

  currentState = newState;

  // Reset alarm timing when state changes
  lastBuzzerToggle = millis();
  buzzerState = false;
  digitalWrite(BUZZER, LOW);
}


// ============================================
// LED Control
// ============================================

void updateLED() {

  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);

  switch (currentState) {

    case BOOT:

      digitalWrite(LED_GREEN, HIGH);
      digitalWrite(LED_YELLOW, HIGH);
      digitalWrite(LED_RED, HIGH);

      break;


    case NOMINAL:

      digitalWrite(LED_GREEN, HIGH);

      break;


    case WARNING:

      digitalWrite(LED_YELLOW, HIGH);

      break;


    case FAULT:

      digitalWrite(LED_RED, HIGH);

      break;


    case RECOVERY:

      if (millis() - lastLedBlink >= 300) {

        lastLedBlink = millis();
        yellowBlinkState = !yellowBlinkState;
      }

      digitalWrite(
        LED_YELLOW,
        yellowBlinkState ? HIGH : LOW
      );

      break;
  }
}


// ============================================
// Buzzer Control
// ============================================

void updateBuzzer() {

  switch (currentState) {

    case BOOT:
    case NOMINAL:
    case RECOVERY:

      digitalWrite(BUZZER, LOW);
      buzzerState = false;

      break;


    // WARNING:
    // 500 ms ON / 500 ms OFF
    case WARNING:

      if (millis() - lastBuzzerToggle >= 500) {

        lastBuzzerToggle = millis();
        buzzerState = !buzzerState;

        digitalWrite(
          BUZZER,
          buzzerState ? HIGH : LOW
        );
      }

      break;


    // FAULT:
    // 150 ms ON / 150 ms OFF
    case FAULT:

      if (millis() - lastBuzzerToggle >= 150) {

        lastBuzzerToggle = millis();
        buzzerState = !buzzerState;

        digitalWrite(
          BUZZER,
          buzzerState ? HIGH : LOW
        );
      }

      break;
  }
}


// ============================================
// Setup
// ============================================

void setup() {

  // LEDs
  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  // Buttons
  pinMode(BTN_WARNING, INPUT_PULLUP);
  pinMode(BTN_FAULT, INPUT_PULLUP);

  // Buzzer
  pinMode(BUZZER, OUTPUT);
  digitalWrite(BUZZER, LOW);


  // UART
  DebugSerial.setTx(PA9);
  DebugSerial.setRx(PA10);
  DebugSerial.begin(9600);

  delay(500);


  // Boot log
  DebugSerial.println();
  DebugSerial.println("============================");
  DebugSerial.println("CubeSat OBC v0.1");
  DebugSerial.println("Phase 1.4 Fault Alarm");
  DebugSerial.println("============================");

  DebugSerial.println("[EVENT] SYSTEM BOOT");


  // BOOT
  currentState = BOOT;

  updateLED();

  delay(1000);


  // BOOT -> NOMINAL
  changeState(NOMINAL);

  updateLED();
}


// ============================================
// Main Loop
// ============================================

void loop() {

  int warningNow = digitalRead(BTN_WARNING);
  int faultNow   = digitalRead(BTN_FAULT);


  bool warningPressed =
    (lastWarning == HIGH &&
     warningNow == LOW);

  bool faultPressed =
    (lastFault == HIGH &&
     faultNow == LOW);


  // ==========================================
  // State Machine
  // ==========================================

  switch (currentState) {

    case NOMINAL:

      if (faultPressed) {

        changeState(FAULT);
      }

      else if (warningPressed) {

        changeState(WARNING);
      }

      break;


    case WARNING:

      if (faultPressed) {

        changeState(FAULT);
      }

      break;


    case FAULT:

      // WARNING button = ACK / Recovery
      if (warningPressed) {

        recoveryStart = millis();

        yellowBlinkState = false;
        lastLedBlink = millis();

        changeState(RECOVERY);
      }

      break;


    case RECOVERY:

      if (millis() - recoveryStart >= 3000) {

        changeState(NOMINAL);
      }

      break;


    case BOOT:

      break;
  }


  updateLED();
  updateBuzzer();


  lastWarning = warningNow;
  lastFault   = faultNow;


  delay(10);
}