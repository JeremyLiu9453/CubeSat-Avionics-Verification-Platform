import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/satellite.dart';
import '../../theme/app_theme.dart';
import '../../widgets/satellite_card.dart';
import '../dashboard/dashboard_screen.dart';
import 'add_satellite_screen.dart';

class SatellitesScreen extends StatefulWidget {
  const SatellitesScreen({super.key});

  @override
  State<SatellitesScreen> createState() => _SatellitesScreenState();
}

class _SatellitesScreenState extends State<SatellitesScreen> {
  int _selectedFilter = 0;

  late final Satellite _onlineSatellite = Satellite(
    id: 'DEJI-SAT-01',
    name: 'Avionics EM-01',
    status: SatelliteStatus.online,
    systemState: SystemState.nominal,
    busVoltage: 4.92,
    temperature: 31.8,
    rssi: -72,
    lastContact: DateTime.now(),
  );

  late final Satellite _offlineSatellite = Satellite(
    id: 'DEJI-SAT-02',
    name: 'Payload Test',
    status: SatelliteStatus.offline,
    systemState: SystemState.boot,
    busVoltage: 0,
    temperature: 0,
    rssi: 0,
    lastContact: DateTime.now().subtract(const Duration(hours: 3)),
  );

  List<Satellite> get _visibleSatellites {
    switch (_selectedFilter) {
      case 1:
        return [_onlineSatellite];
      case 2:
        return [_offlineSatellite];
      default:
        return [_onlineSatellite, _offlineSatellite];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(23, 12, 26.4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Satellites',
                      style: GoogleFonts.rajdhani(
                        color: AppColors.primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 35.6,
                    height: 35.6,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AddSatelliteScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_rounded,
                        size: 35.6,
                      ),
                      color: AppColors.primaryText,
                      tooltip: 'Add CubeSat',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All (2)',
                    selected: _selectedFilter == 0,
                    onTap: () => setState(() => _selectedFilter = 0),
                  ),
                  const SizedBox(width: 26),
                  _FilterChip(
                    label: 'Online (1)',
                    selected: _selectedFilter == 1,
                    onTap: () => setState(() => _selectedFilter = 1),
                  ),
                  const SizedBox(width: 26),
                  _FilterChip(
                    label: 'Offline (1)',
                    selected: _selectedFilter == 2,
                    onTap: () => setState(() => _selectedFilter = 2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                itemCount: _visibleSatellites.length,
                separatorBuilder: (_, __) => const SizedBox(height: 22),
                itemBuilder: (context, index) {
                  final satellite = _visibleSatellites[index];

                  return SatelliteCard(
                    satellite: satellite,
                    onTap: satellite.status == SatelliteStatus.online
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DashboardScreen(
                                  satellite: satellite,
                                ),
                              ),
                            );
                          }
                        : null,
                  );
                },
              ),
            ),
            const _ExploreBanner(),
          ],
        ),
      ),
      bottomNavigationBar: const _MainBottomNavigation(),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.orbitalBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: AppColors.accentBlue,
                      offset: Offset(0, 4),
                      blurRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: selected
                  ? AppColors.primaryText
                  : const Color(0xFF7A7A7A),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _ExploreBanner extends StatelessWidget {
  const _ExploreBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/earth_horizon_bg.png',
            fit: BoxFit.cover,
            alignment: const Alignment(0, 0.22),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xCC010B15),
                  Color(0x22010B15),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore More',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'A smaller step for you,\na brighter tomorrow.',
                  style: GoogleFonts.rajdhani(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MainBottomNavigation extends StatelessWidget {
  const _MainBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.appBackground,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: true,
              ),
              _NavItem(
                icon: Icons.notifications_rounded,
                label: 'Alerts',
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _NavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.accentBlue
        : AppColors.textGray.withValues(alpha: 0.60);

    return SizedBox(
      width: 64,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
