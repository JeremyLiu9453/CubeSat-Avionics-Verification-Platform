import 'package:flutter/material.dart';

import '../../models/satellite.dart';
import '../../models/telemetry.dart';
import '../../theme/app_theme.dart';
import '../../widgets/telemetry_card.dart';

import '../../services/mock_telemetry_service.dart';

class DashboardScreen extends StatefulWidget {
  final Satellite satellite;

  const DashboardScreen({
    super.key,
    required this.satellite,
  });

  @override
  State<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockTelemetryService _telemetryService =
    MockTelemetryService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Telemetry>(
      stream: _telemetryService.getTelemetryStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final telemetry = snapshot.data!;

        return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Header
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.satellite.id,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            Text(
                              widget.satellite.name,
                              style: const TextStyle(
                                color: AppColors.textGray,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      _LiveBadge(),
                    ],
                  ),

                  const SizedBox(height: 44),

                  // System status
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.success,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.success,
                                blurRadius: 16,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'NOMINAL',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 3,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'All systems operating normally',
                          style: TextStyle(
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 42),

                  const Text(
                    'SYSTEM TELEMETRY',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns =
                          constraints.maxWidth < 600 ? 2 : 3;

                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          TelemetryCard(
                            title: 'Bus Voltage',
                            value:
                                '${telemetry.busVoltage.toStringAsFixed(2)} V',
                            icon:
                                Icons.battery_charging_full_rounded,
                          ),

                          TelemetryCard(
                            title: 'Current',
                            value:
                                '${telemetry.current.toStringAsFixed(0)} mA',
                            icon: Icons.bolt_rounded,
                          ),

                          TelemetryCard(
                            title: 'Power',
                            value:
                                '${telemetry.power.toStringAsFixed(2)} W',
                            icon: Icons.power_rounded,
                          ),

                          TelemetryCard(
                            title: 'OBC Temp',
                            value:
                                '${telemetry.temperature.toStringAsFixed(1)} °C',
                            icon: Icons.thermostat_rounded,
                          ),

                          TelemetryCard(
                            title: 'RSSI',
                            value: '${telemetry.rssi} dBm',
                            icon: Icons.wifi_rounded,
                          ),

                          TelemetryCard(
                            title: 'Packets RX',
                            value:
                                '${telemetry.packetCount}',
                            icon: Icons.data_usage_rounded,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'ATTITUDE',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 16),

                  _AttitudePanel(
                    roll: telemetry.roll,
                    pitch: telemetry.pitch,
                    yaw: telemetry.yaw,
                  ),

                  const SizedBox(height: 32),

                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 15,
                        color: AppColors.textGray,
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'Last contact: just now',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 12,
                        ),
                      ),

                      const Spacer(),

                      Text(
                        'PKT ${telemetry.packetCount}',
                        style: const TextStyle(
                          color: AppColors.textGray,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: const _GroundStationNavigation(),
        );
      },
    );
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.circle,
            size: 7,
            color: AppColors.success,
          ),
          SizedBox(width: 7),
          Text(
            'LIVE',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttitudePanel extends StatelessWidget {
  final double roll;
  final double pitch;
  final double yaw;

  const _AttitudePanel({
    required this.roll,
    required this.pitch,
    required this.yaw,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1B293A),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _AttitudeValue(
              label: 'ROLL',
              value: '${roll.toStringAsFixed(1)}°',
            ),
          ),
          Expanded(
            child: _AttitudeValue(
              label: 'PITCH',
              value: '${pitch.toStringAsFixed(1)}°',
            ),
          ),
          Expanded(
            child: _AttitudeValue(
              label: 'YAW',
              value: '${yaw.toStringAsFixed(1)}°',
            ),
          ),
        ],
      ),
    );
  }
}

class _AttitudeValue extends StatelessWidget {
  final String label;
  final String value;

  const _AttitudeValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textGray,
            fontSize: 9,
            letterSpacing: 1.3,
          ),
        ),
      ],
    );
  }
}

class _GroundStationNavigation extends StatelessWidget {
  const _GroundStationNavigation();

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: 0,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard_rounded),
          label: 'Dashboard',
        ),
        NavigationDestination(
          icon: Icon(Icons.monitor_heart_outlined),
          selectedIcon: Icon(Icons.monitor_heart_rounded),
          label: 'Telemetry',
        ),
        NavigationDestination(
          icon: Icon(Icons.list_alt_outlined),
          selectedIcon: Icon(Icons.list_alt_rounded),
          label: 'Events',
        ),
        NavigationDestination(
          icon: Icon(Icons.terminal_outlined),
          selectedIcon: Icon(Icons.terminal_rounded),
          label: 'Control',
        ),
      ],
    );
  }
}