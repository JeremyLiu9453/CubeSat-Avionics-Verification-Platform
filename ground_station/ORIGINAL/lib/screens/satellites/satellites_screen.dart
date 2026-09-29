import 'package:flutter/material.dart';

import '../../models/satellite.dart';
import '../../theme/app_theme.dart';
import '../../widgets/satellite_card.dart';

import 'add_satellite_screen.dart';

import '../dashboard/dashboard_screen.dart';

class SatellitesScreen extends StatelessWidget {
  const SatellitesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final demoSatellite = Satellite(
      id: 'DEJI-SAT-01',
      name: 'Avionics EM-01',
      status: SatelliteStatus.online,
      
      // 可以改變卡片中衛星的狀態
      // systemState: SystemState.nominal,
      // systemState: SystemState.warning,
      // systemState: SystemState.fault,
      systemState: SystemState.nominal,
      busVoltage: 4.92,
      temperature: 31.8,
      rssi: -72,
      lastContact: DateTime.now(),
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 900,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DEJI SAT',
                              style: TextStyle(
                                fontSize: 12,
                                letterSpacing: 3,
                                color: AppColors.accentCyan,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'My Satellites',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) {
                                return const AddSatelliteScreen();
                              },
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                        ),
                        tooltip: 'Add CubeSat',
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Monitor and manage your connected spacecraft.',
                    style: TextStyle(
                      color: AppColors.textGray,
                    ),
                  ),

                  const SizedBox(height: 36),

                  SatelliteCard(
                    satellite: demoSatellite,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return DashboardScreen(
                              satellite: demoSatellite,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}