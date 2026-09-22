enum SatelliteStatus {
  online,
  offline,
}

enum SystemState {
  boot,
  nominal,
  warning,
  fault,
  recovery,
}

class Satellite {
  final String id;
  final String name;
  final SatelliteStatus status;
  final SystemState systemState;

  final double busVoltage;
  final double temperature;
  final int rssi;

  final DateTime lastContact;

  const Satellite({
    required this.id,
    required this.name,
    required this.status,
    required this.systemState,
    required this.busVoltage,
    required this.temperature,
    required this.rssi,
    required this.lastContact,
  });
}