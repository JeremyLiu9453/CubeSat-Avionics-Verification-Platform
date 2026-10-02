
// CubeSat OBC - Phase 1.5 Test Temperature FDIR (A part)
// FDIR =  Fault Detection, Isolation and Recovery (故障偵測、隔離與復原)
//
// FSM + USART1 Serial Event Log + Buzzer Alarmv + DHT22-Temperature 
//
// Date: Oct-01, 2026
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
//
// LEDs:
// PA0 = GREEN; PA1 = YELLOW; PA2 = RED
//
// Buttons:
// PA3 = WARNING; PA4 = FAULT
//
// UART:
// PA9 = USART1 TX; UPA10 = SART1 RX; Baud = 9600
// 
// Buzzer: PB0 = Sound Output
// DHT22: PB6 = Temperature Output
// ============================================

#include <Arduino.h>
#include <DHT.h>

// ============================================
// PIN DEFINITIONS
// ============================================

// Status LEDs
#define LED_GREEN       PA0
#define LED_YELLOW      PA1
#define LED_RED         PA2

// Manual fault injection buttons
#define BTN_WARNING     PA3
#define BTN_FAULT       PA4

// Alarm LED
#define ALARM_OUT       PB1

// DHT22
#define DHT_PIN         PB6
#define DHT_TYPE        DHT22

// UART
Uart DebugSerial(USART1);

// DHT22
DHT dht(DHT_PIN, DHT_TYPE);

// SYSTEM STATE
enum SystemState {
  BOOT,
  NOMINAL,
  WARNING,
  FAULT,
  RECOVERY
};

SystemState currentState = BOOT;

// ==========================================================
// TEMPERATURE THRESHOLDS
// ==========================================================

// ---------- Enter thresholds ----------
//    (1) 31.9°C -- WARNING -> (2) 32.0°C -- FAULT
// -> (3) 31.5°C -- FAULT -> (4) 30.5°C -- FAULT
// -> (5) 29.9°C -- RECOVERY
// ~~~~~~~~~ This Area is the NOMINAL-WARNING 2°C hysteresis zone. ~~~~~~~~~ 

const float TEMP_WARNING_ENTER = 28.0;
const float TEMP_FAULT_ENTER   = 32.0;

// ---------- HYSTERESIS SETTINGS ----------
// WARNING:
//   Enter WARNING >= 28°C
//   Return NOMINAL < 27°C
//
// FAULT:
//   Enter FAULT >= 32°C
//   Allow recovery < 30°C
//
// Notice:
// ENTER and EXIT thresholds are intentionally different.
// This prevents rapid state switching near a threshold.
// ==========================================================

//    (1) 27.9°C -- NOMINAL -> (2) 28.0°C -- WARNING
// -> (3) 27.9°C -- WARNING -> (4) 27.5°C -- WARNING
// -> (5) 26.9°C -- NOMINAL
// ~~~~~~~~~ This Area is the NOMINAL-WARNING 1°C hysteresis zone. ~~~~~~~~~ 

const float TEMP_WARNING_EXIT = 27.0;   // ★ HYSTERESIS
const float TEMP_FAULT_EXIT   = 30.0;   // ★ HYSTERESIS

// SENSOR DATA
float temperature = 0.0;
float humidity    = 0.0;
bool sensorValid = false;

// Read sensor every 2 seconds
unsigned long lastSensorRead = 0;
const unsigned long SENSOR_INTERVAL = 2000;

// BUTTON EDGE DETECTION
int lastWarningButton = HIGH;
int lastFaultButton   = HIGH;

// ALARM TIMING
unsigned long lastAlarmToggle = 0;
bool alarmState = false;

// RECOVERY
unsigned long recoveryStart = 0;
unsigned long lastRecoveryBlink = 0;

bool recoveryLedState = false;
const unsigned long RECOVERY_TIME = 3000;

// STATE NAME
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

// CHANGE STATE
void changeState(SystemState newState) {

  // Don't log duplicate transitions
  if (newState == currentState) {
    return;
  }

  DebugSerial.print("[EVENT] ");
  DebugSerial.print(stateName(currentState));
  DebugSerial.print(" -> ");
  DebugSerial.println(stateName(newState));

  currentState = newState;

  // Reset alarm timer whenever state changes
  alarmState = false;

  digitalWrite(ALARM_OUT, LOW);

  lastAlarmToggle = millis();
}

// STATUS LED
void updateStatusLED() {

  // Default OFF
  digitalWrite(LED_GREEN, LOW);
  digitalWrite(LED_YELLOW, LOW);
  digitalWrite(LED_RED, LOW);


  switch (currentState) {

    // ------------------------------------------------------
    // BOOT
    // ------------------------------------------------------

    case BOOT:

      digitalWrite(LED_GREEN, HIGH);
      digitalWrite(LED_YELLOW, HIGH);
      digitalWrite(LED_RED, HIGH);

      break;


    // ------------------------------------------------------
    // NOMINAL
    // ------------------------------------------------------

    case NOMINAL:

      digitalWrite(LED_GREEN, HIGH);

      break;


    // ------------------------------------------------------
    // WARNING
    // ------------------------------------------------------

    case WARNING:

      digitalWrite(LED_YELLOW, HIGH);

      break;


    // ------------------------------------------------------
    // FAULT
    // ------------------------------------------------------

    case FAULT:

      digitalWrite(LED_RED, HIGH);

      break;


    // ------------------------------------------------------
    // RECOVERY
    // ------------------------------------------------------

    case RECOVERY:

      if (millis() - lastRecoveryBlink >= 300) {

        lastRecoveryBlink = millis();

        recoveryLedState = !recoveryLedState;
      }

      digitalWrite(
        LED_YELLOW,
        recoveryLedState ? HIGH : LOW
      );

      break;
  }
}

// ALARM OUTPUT
void updateAlarm() {

  switch (currentState) {

    // ------------------------------------------------------
    // No alarm
    // ------------------------------------------------------

    case BOOT:
    case NOMINAL:
    case RECOVERY:

      digitalWrite(ALARM_OUT, LOW);

      alarmState = false;

      break;


    // ------------------------------------------------------
    // WARNING
    // Slow blink
    // 500 ms ON / 500 ms OFF
    // ------------------------------------------------------

    case WARNING:

      if (millis() - lastAlarmToggle >= 500) {

        lastAlarmToggle = millis();

        alarmState = !alarmState;

        digitalWrite(
          ALARM_OUT,
          alarmState ? HIGH : LOW
        );
      }

      break;


    // ------------------------------------------------------
    // FAULT
    // Fast blink
    // 150 ms ON / 150 ms OFF
    // ------------------------------------------------------

    case FAULT:

      if (millis() - lastAlarmToggle >= 150) {

        lastAlarmToggle = millis();

        alarmState = !alarmState;

        digitalWrite(
          ALARM_OUT,
          alarmState ? HIGH : LOW
        );
      }

      break;
  }
}

// SENSOR READ + TELEMETRY
void readSensor() {

  // Only read every SENSOR_INTERVAL
  if (millis() - lastSensorRead < SENSOR_INTERVAL) {
    return;
  }

  lastSensorRead = millis();


  float newHumidity =
    dht.readHumidity();

  float newTemperature =
    dht.readTemperature();


  // --------------------------------------------------------
  // Sensor validation
  // --------------------------------------------------------

  if (
    isnan(newHumidity) ||
    isnan(newTemperature)
  ) {

    sensorValid = false;

    DebugSerial.println(
      "[ERROR] DHT22 SENSOR READ FAILED"
    );

    return;
  }


  sensorValid = true;

  temperature = newTemperature;
  humidity    = newHumidity;


  // --------------------------------------------------------
  // Telemetry
  // --------------------------------------------------------

  DebugSerial.print("[TLM] TEMP=");
  DebugSerial.print(temperature, 1);

  DebugSerial.print(" C, HUM=");
  DebugSerial.print(humidity, 1);

  DebugSerial.print(" %, STATE=");

  DebugSerial.println(
    stateName(currentState)
  );
}

// AUTOMATIC TEMPERATURE FAULT DETECTION
void evaluateTemperature() {

  if (!sensorValid) {
    return;
  }


  switch (currentState) {


    // ======================================================
    // NOMINAL
    // ======================================================

    case NOMINAL:

      // Critical temperature has highest priority
      if (temperature >= TEMP_FAULT_ENTER) {

        DebugSerial.println(
          "[FAULT DETECTION] CRITICAL TEMPERATURE"
        );

        changeState(FAULT);
      }

      else if (temperature >= TEMP_WARNING_ENTER) {

        DebugSerial.println(
          "[FAULT DETECTION] HIGH TEMPERATURE"
        );

        changeState(WARNING);
      }

      break;


    // ======================================================
    // WARNING
    // ======================================================

    case WARNING:

      // Escalate WARNING -> FAULT
      if (temperature >= TEMP_FAULT_ENTER) {

        DebugSerial.println(
          "[FAULT DETECTION] TEMPERATURE ESCALATED"
        );

        changeState(FAULT);
      }


      // ====================================================
      // ★ HYSTERESIS #1 ★
      //
      // We entered WARNING at >= 28°C.
      //
      // We DO NOT return to NOMINAL when temp drops
      // just below 28°C.
      //
      // Temperature must drop BELOW 27°C.
      //
      // Example:
      //
      // 28.1 -> WARNING
      // 27.9 -> still WARNING
      // 27.5 -> still WARNING
      // 26.9 -> NOMINAL
      //
      // ====================================================

      else if (temperature < TEMP_WARNING_EXIT) {

        DebugSerial.println(
          "[RECOVERY] TEMPERATURE RETURNED TO NORMAL"
        );

        changeState(NOMINAL);
      }

      break;


    // ======================================================
    // FAULT
    // ======================================================

    case FAULT:

      // ====================================================
      // ★ HYSTERESIS #2 ★
      //
      // FAULT begins at >= 32°C.
      //
      // Temperature must fall BELOW 30°C before
      // automatic recovery is allowed.
      //
      // Example:
      //
      // 32.1 -> FAULT
      // 31.5 -> still FAULT
      // 30.4 -> still FAULT
      // 29.9 -> RECOVERY
      //
      // ====================================================

      if (temperature < TEMP_FAULT_EXIT) {

        DebugSerial.println(
          "[RECOVERY] CRITICAL TEMPERATURE CLEARED"
        );

        recoveryStart = millis();

        recoveryLedState = false;

        lastRecoveryBlink = millis();

        changeState(RECOVERY);
      }

      break;


    case BOOT:
    case RECOVERY:

      break;
  }
}

// ==========================================================
// SETUP
// ==========================================================

void setup() {

  // ----------------- GPIO ----------------- 

  pinMode(LED_GREEN, OUTPUT);
  pinMode(LED_YELLOW, OUTPUT);
  pinMode(LED_RED, OUTPUT);

  pinMode(ALARM_OUT, OUTPUT);

  pinMode(BTN_WARNING, INPUT_PULLUP);
  pinMode(BTN_FAULT, INPUT_PULLUP);


  digitalWrite(ALARM_OUT, LOW);

  // ----------------- UART ----------------- 

  DebugSerial.setTx(PA9);
  DebugSerial.setRx(PA10);
  DebugSerial.begin(9600);

  // ----------------- DHT22 ----------------- 

  dht.begin();
  delay(500);

  // ----------------- Boot Message -----------------

  DebugSerial.println();
  DebugSerial.println(
    "======================================"
  );

  DebugSerial.println(
    "CubeSat OBC Prototype"
  );

  DebugSerial.println(
    "Phase 1.5-B Automatic Fault Detection"
  );

  DebugSerial.println(
    "======================================"
  );

  DebugSerial.println(
    "[INIT] USART1 OK"
  );

  DebugSerial.println(
    "[INIT] DHT22 OK"
  );

  DebugSerial.println(
    "[INIT] Temperature FDIR enabled"
  );

  // ----------------- Print thresholds -----------------

  DebugSerial.println();
  DebugSerial.println("[CONFIG]");

  DebugSerial.print(
    "WARNING ENTER = "
  );
  DebugSerial.println(
    TEMP_WARNING_ENTER
  );

  DebugSerial.print(
    "WARNING EXIT  = "
  );
  DebugSerial.println(
    TEMP_WARNING_EXIT
  );

  DebugSerial.print(
    "FAULT ENTER   = "
  );
  DebugSerial.println(
    TEMP_FAULT_ENTER
  );

  DebugSerial.print(
    "FAULT EXIT    = "
  );
  DebugSerial.println(
    TEMP_FAULT_EXIT
  );

  // ----------------- BOOT ----------------- 

  DebugSerial.println();
  DebugSerial.println(
    "[EVENT] SYSTEM BOOT"
  );

  currentState = BOOT;

  updateStatusLED();

  delay(1000);


  changeState(NOMINAL);
}

// ==========================================================
// MAIN LOOP
// ==========================================================

void loop() {

  // ----------------
  // 1. Read Buttons
  // ----------------

  int warningNow =
    digitalRead(BTN_WARNING);

  int faultNow =
    digitalRead(BTN_FAULT);


  bool warningPressed =
    (
      lastWarningButton == HIGH &&
      warningNow == LOW
    );


  bool faultPressed =
    (
      lastFaultButton == HIGH &&
      faultNow == LOW
    );


  // ----------------
  // 2. Manual Fault Injection
  // ----------------

  // PA4 always has FAULT priority
  if (
    faultPressed &&
    currentState != FAULT
  ) {

    DebugSerial.println(
      "[MANUAL] FAULT INJECTION"
    );

    changeState(FAULT);
  }

  // PA3 generates WARNING when NOMINAL
  else if (
    warningPressed &&
    currentState == NOMINAL
  ) {

    DebugSerial.println(
      "[MANUAL] WARNING INJECTION"
    );

    changeState(WARNING);
  }


  // ----------------
  // 3. Sensor Telemetry
  // ----------------

  readSensor();

  // ----------------
  // 4. Automatic Fault Detection
  // ----------------

  evaluateTemperature();

  // ----------------
  // 5. Recovery State
  // ----------------

  if (currentState == RECOVERY) {

    if (
      millis() - recoveryStart
      >= RECOVERY_TIME
    ) {

      // ----------------------------------------------------
      // Before NOMINAL, check temperature again.
      // ----------------------------------------------------

      if (
        sensorValid &&
        temperature < TEMP_WARNING_ENTER
      ) {

        DebugSerial.println(
          "[INFO] SYSTEM RECOVERY COMPLETE"
        );

        changeState(NOMINAL);
      }

      else {

        DebugSerial.println(
          "[RECOVERY] TEMPERATURE STILL HIGH"
        );

        changeState(WARNING);
      }
    }
  }

  // ----------------
  // 6. Outputs
  // ----------------

  updateStatusLED();
  updateAlarm();

  // ----------------
  // 7. Save button states
  // ----------------

  lastWarningButton = warningNow;
  lastFaultButton = faultNow;

  delay(10);
}
