import 'package:flutter/material.dart';

import '../models/satellite.dart';
import '../theme/app_theme.dart';

class SatelliteCard extends StatelessWidget {
  final Satellite satellite;
  final VoidCallback? onTap;

  const SatelliteCard({
    super.key,
    required this.satellite,
    this.onTap,
  });

  Color _getStateColor() {
    switch (satellite.systemState) {
      case SystemState.nominal:
        return AppColors.success;

      case SystemState.warning:
        return AppColors.warning;

      case SystemState.fault:
        return AppColors.fault;

      case SystemState.recovery:
        return AppColors.accentBlue;

      case SystemState.boot:
        return AppColors.textGray;
    }
  }

  String _getStateText() {
    return satellite.systemState.name.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final stateColor = _getStateColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: stateColor.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.spaceNavy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.satellite_alt_rounded,
                      color: AppColors.pureWhite,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          satellite.id,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          satellite.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(
                    online:
                        satellite.status == SatelliteStatus.online,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // System State
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: stateColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: stateColor.withValues(alpha: 0.55),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    _getStateText(),
                    style: TextStyle(
                      color: stateColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // Telemetry
              Row(
                children: [
                  Expanded(
                    child: _TelemetryValue(
                      value:
                          '${satellite.busVoltage.toStringAsFixed(2)} V',
                      label: 'BUS VOLTAGE',
                    ),
                  ),
                  Expanded(
                    child: _TelemetryValue(
                      value:
                          '${satellite.temperature.toStringAsFixed(1)} °C',
                      label: 'OBC TEMP',
                    ),
                  ),
                  Expanded(
                    child: _TelemetryValue(
                      value: '${satellite.rssi} dBm',
                      label: 'RSSI',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Divider(
                color: Color(0xFF1B293A),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textGray,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    satellite.status == SatelliteStatus.online
                        ? 'Last contact: just now'
                        : 'Last contact unavailable',
                    style: const TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: AppColors.textGray,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelemetryValue extends StatelessWidget {
  final String value;
  final String label;

  const _TelemetryValue({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 9,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool online;

  const _StatusBadge({
    required this.online,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        online ? AppColors.success : AppColors.textGray;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        online ? 'ONLINE' : 'OFFLINE',
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}