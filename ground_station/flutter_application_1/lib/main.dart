import 'package:flutter/material.dart';

import 'screens/splash/splash_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const FlatSatGroundStation());
}

class FlatSatGroundStation extends StatelessWidget {
  const FlatSatGroundStation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlatSat Ground Station',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}