import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../satellites/satellites_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(milliseconds: 1500),
      () {
        if (!mounted) return;

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration:
                const Duration(milliseconds: 500),
            pageBuilder: (
              context,
              animation,
              secondaryAnimation,
            ) {
              return const SatellitesScreen();
            },
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/backgrounds/earth_horizon_bg.png',
            fit: BoxFit.cover,
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.25),
                  AppColors.deepSpace.withValues(alpha: 0.80),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 32,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: AppColors.accentCyan
                            .withValues(alpha: 0.45),
                      ),
                      color: AppColors.spaceNavy
                          .withValues(alpha: 0.65),
                    ),
                    child: const Icon(
                      Icons.satellite_alt_rounded,
                      size: 48,
                      color: AppColors.pureWhite,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'DEJI SAT',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 7,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'PERSONAL GROUND STATION',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 3,
                      color: AppColors.textGray,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Your spacecraft.\nIn your pocket.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),

                  const Spacer(),

                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accentCyan,
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'INITIALIZING GROUND STATION',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 2,
                      color: AppColors.textGray,
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}