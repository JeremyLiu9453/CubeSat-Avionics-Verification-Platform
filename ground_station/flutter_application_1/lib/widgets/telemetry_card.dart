import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TelemetryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const TelemetryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF1B293A),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.accentCyan,
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            title.toUpperCase(),
            style: const TextStyle(
              color: AppColors.textGray,
              fontSize: 9,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}