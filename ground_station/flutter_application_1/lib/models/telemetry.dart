class Telemetry {
  final double busVoltage;
  final double current;
  final double power;
  final double temperature;

  final double roll;
  final double pitch;
  final double yaw;

  final int rssi;
  final int packetCount;

  final DateTime timestamp;

  const Telemetry({
    required this.busVoltage,
    required this.current,
    required this.power,
    required this.temperature,
    required this.roll,
    required this.pitch,
    required this.yaw,
    required this.rssi,
    required this.packetCount,
    required this.timestamp,
  });
}