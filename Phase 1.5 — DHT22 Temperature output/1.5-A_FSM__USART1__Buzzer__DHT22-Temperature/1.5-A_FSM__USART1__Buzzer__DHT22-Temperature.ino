// ============================================
// CubeSat OBC - Phase 1.5
// FSM + USART1 Serial Event Log + DHT22-Temperature 
//
// Date: Sep-28, 2026
// MCU: STM32F103C8T6
// Author: Deji Liu (劉永鈞)
//
// UART:
// PA9 = USART1 TX
// UPA10 = SART1 RX
// Baud = 9600
// 
// DHT22: 
// PB6 = Temperature Output
// ============================================

#include <Arduino.h>
#include <DHT.h>

#define DHT_PIN   PB6
#define DHT_TYPE  DHT22

DHT dht(DHT_PIN, DHT_TYPE);

// USART1
Uart DebugSerial(USART1);

void setup() {

  // USART1 pin assignment
  DebugSerial.setTx(PA9);
  DebugSerial.setRx(PA10);
  DebugSerial.begin(9600);

  delay(500);

  DebugSerial.println();
  DebugSerial.println("==============================");
  DebugSerial.println("CubeSat OBC");
  DebugSerial.println("Phase 1.5-A Sensor Telemetry");
  DebugSerial.println("==============================");

  // Start DHT22
  dht.begin();

  DebugSerial.println("[INIT] DHT22 initialized");
}

void loop() {

  // DHT22 doesn't need fast polling.
  delay(2000);

  float humidity = dht.readHumidity();
  float temperature = dht.readTemperature();

  // Check sensor read
  if (isnan(humidity) || isnan(temperature)) {

    DebugSerial.println(
      "[ERROR] DHT22 SENSOR READ FAILED"
    );

    return;
  }

  // Telemetry output
  DebugSerial.print("[TLM] TEMP=");
  DebugSerial.print(temperature, 1);

  DebugSerial.print(" C, HUM=");
  DebugSerial.print(humidity, 1);

  DebugSerial.println(" %");
}