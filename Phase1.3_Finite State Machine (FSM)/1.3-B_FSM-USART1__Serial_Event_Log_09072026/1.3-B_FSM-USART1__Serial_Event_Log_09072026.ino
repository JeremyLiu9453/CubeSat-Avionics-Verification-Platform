// ============================================
// CubeSat OBC - Phase 1.3-B
// FSM + USART1 Serial Event Log
//
// Date: Sep-10, 2026
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
// ============================================

#include "Arduino.h"

// ----------------------------
// Pin Definition
// ----------------------------

#define LED_GREEN   PA0
#define LED_YELLOW  PA1
#define LED_RED     PA2

#define BTN_WARNING PA3
#define BTN_FAULT   PA4


// ----------------------------
// UART
// ----------------------------

Uart DebugSerial(USART1);


// ----------------------------
// State Machine
// ----------------------------

enum SystemState {
  BOOT,
  NOMINAL,
  WARNING,
  FAULT,
  RECOVERY
};

SystemState currentState = BOOT;


// ----------------------------
// Button Edge Detection
// ----------------------------

int lastWarning = HIGH;
int lastFault   = HIGH;


// ----------------------------
// Recovery Timer
// ----------------------------

unsigned long recoveryStart = 0;


// ----------------------------
// Recovery LED Blink
// ----------------------------

unsigned long lastBlink = 0;
bool yellowBlinkState = false;


// ============================================
// State Name
// ============================================

const char* stateName(SystemState state) {

  switch (state) {

    case BOOT:
      return "BOOT";

    case NOMINAL:
      return "NOMINAL";

    case WARNING:
      return "WARNING";

    case FAULT:
      return "FAULT";

    case RECOVERY:
      return "RECOVERY";

    default:
      return "UNKNOWN";
  }
}


// ============================================
// Change State + Event Log
// ============================================

void changeState(SystemState newState) {

  DebugSerial.print("[EVENT] ");
  DebugSerial.print(stateName(currentState));
  DebugSerial.print(" -> ");
  DebugSerial.println(stateName(newState));

  currentState = newState;
}


// ============================================
// LED Control
// ============================================

void updateLED() {

  // Default OFF
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

      if (millis() - lastBlink >= 300) {

        lastBlink = millis();

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
// Setup
// ============================================

void setup() {

  // ----------------------------
  // GPIO
  // ----------------------------

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  pinMode(BTN_WARNING, INPUT_PULLUP);
  pinMode(BTN_FAULT, INPUT_PULLUP);


  // ----------------------------
  // UART USART1
  // ----------------------------

  DebugSerial.setTx(PA9);
  DebugSerial.setRx(PA10);

  DebugSerial.begin(9600);

  delay(500);


  // ----------------------------
  // Boot Log
  // ----------------------------

  DebugSerial.println();
  DebugSerial.println("============================");
  DebugSerial.println("CubeSat OBC v0.1");
  DebugSerial.println("Phase 1.3-B Event Logger");
  DebugSerial.println("============================");

  DebugSerial.println("[EVENT] SYSTEM BOOT");


  // ----------------------------
  // BOOT State
  // ----------------------------

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

  // Read buttons

  int warningNow = digitalRead(BTN_WARNING);
  int faultNow   = digitalRead(BTN_FAULT);


  // Falling Edge:
  // HIGH -> LOW = button pressed

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


    // --------------------------
    // NOMINAL
    // --------------------------

    case NOMINAL:

      // FAULT has higher priority

      if (faultPressed) {

        changeState(FAULT);
      }

      else if (warningPressed) {

        changeState(WARNING);
      }

      break;


    // --------------------------
    // WARNING
    // --------------------------

    case WARNING:

      if (faultPressed) {

        changeState(FAULT);
      }

      break;


    // --------------------------
    // FAULT
    // --------------------------

    case FAULT:

      // WARNING button acts as ACK
      // and starts recovery

      if (warningPressed) {

        recoveryStart = millis();

        yellowBlinkState = false;

        lastBlink = millis();

        changeState(RECOVERY);
      }

      break;


    // --------------------------
    // RECOVERY
    // --------------------------

    case RECOVERY:

      if (millis() - recoveryStart >= 3000) {

        changeState(NOMINAL);
      }

      break;


    // --------------------------
    // BOOT
    // --------------------------

    case BOOT:

      break;
  }


  // ----------------------------
  // Update LEDs
  // ----------------------------

  updateLED();


  // ----------------------------
  // Save button states
  // ----------------------------

  lastWarning = warningNow;
  lastFault   = faultNow;


  delay(10);
}