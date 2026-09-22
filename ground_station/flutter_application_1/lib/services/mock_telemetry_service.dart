import 'dart:async';
import 'dart:math';

import '../models/telemetry.dart';

class MockTelemetryService {
  final Random _random = Random();

  int _packetCount = 18392;

  double _voltage = 4.92;
  double _current = 238.0;
  double _temperature = 31.8;

  Stream<Telemetry> getTelemetryStream() {
    return Stream.periodic(
      const Duration(seconds: 2),
      (_) => _generateTelemetry(),
    );
  }

  Telemetry _generateTelemetry() {
    _packetCount++;

    // Small realistic fluctuations
    _voltage += (_random.nextDouble() - 0.5) * 0.04;
    _current += (_random.nextDouble() - 0.5) * 8.0;
    _temperature += (_random.nextDouble() - 0.5) * 0.2;

    // Keep mock values inside sensible demo ranges
    _voltage = _voltage.clamp(4.80, 5.05);
    _current = _current.clamp(220.0, 260.0);
    _temperature = _temperature.clamp(30.0, 34.0);

    final power = _voltage * (_current / 1000);

    final roll = 2.4 + (_random.nextDouble() - 0.5) * 1.0;
    final pitch = -1.7 + (_random.nextDouble() - 0.5) * 1.0;
    final yaw = 183.2 + (_random.nextDouble() - 0.5) * 2.0;

    final rssi = -72 + _random.nextInt(5) - 2;

    return Telemetry(
      busVoltage: _voltage,
      current: _current,
      power: power,
      temperature: _temperature,
      roll: roll,
      pitch: pitch,
      yaw: yaw,
      rssi: rssi,
      packetCount: _packetCount,
      timestamp: DateTime.now(),
    );
  }
}