#include <Arduino.h>

Uart debugPort(PA10, PA9);  // RX, TX

const uint32_t BUZZER_PIN = PB0;
const bool SOUND_ENABLED = true;  // 覺得太吵就改成 false，只看 UART

struct Button {
  uint32_t pin;
  const char* name;
  bool lastRaw;
  bool stable;
  uint32_t changedAt;
};

Button buttons[] = {
  {PA3, "WARNING", HIGH, HIGH, 0},
  {PA4, "FAULT",   HIGH, HIGH, 0}
};

uint32_t lastReportTime = 0;

void setup() {
  pinMode(PA3, INPUT_PULLUP);
  pinMode(PA4, INPUT_PULLUP);
  pinMode(BUZZER_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);

  debugPort.begin(9600);
  delay(300);
  debugPort.println("Button test ready: press PA3 or PA4");
}

void loop() {
  uint32_t now = millis();

  for (Button &button : buttons) {
    bool raw = digitalRead(button.pin);

    if (raw != button.lastRaw) {
      button.lastRaw = raw;
      button.changedAt = now;
    }

    // 狀態保持 30 ms 才確認，避免按鍵彈跳重複觸發
    if (raw != button.stable && now - button.changedAt >= 30) {
      button.stable = raw;

      if (button.stable == LOW) {
        debugPort.print(button.name);
        debugPort.println(" PRESSED");

        if (SOUND_ENABLED) {
          tone(BUZZER_PIN, 2000, 40);  // 只短響 40 ms
        }
      }
    }
  }

  // 即使沒聽清楚蜂鳴器，也能從 UART 看按鍵電位
  if (now - lastReportTime >= 500) {
    debugPort.print("PA3=");
    debugPort.print(digitalRead(PA3));
    debugPort.print(" | PA4=");
    debugPort.println(digitalRead(PA4));
    lastReportTime = now;
  }
}