import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  bool get _isOnline => satellite.status == SatelliteStatus.online;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isOnline
        ? AppColors.success.withValues(alpha: 0.90)
        : AppColors.offlineBorder;
    final backgroundColor =
        _isOnline ? AppColors.onlineCard : AppColors.offlineCard;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 182,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 90,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        width: 42.67,
                        height: 46.67,
                        decoration: BoxDecoration(
                          color: _isOnline
                              ? const Color(0xFF112B21)
                              : const Color(0xFF0F1B25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.view_in_ar_rounded,
                          size: 27,
                          color: _isOnline
                              ? AppColors.success
                              : AppColors.accentBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              satellite.id,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                color: AppColors.primaryText,
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              satellite.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textGray,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _isOnline
                                  ? 'Last contact 2 sec ago'
                                  : 'Last contact 3 hour ago',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.rajdhani(
                                color: AppColors.textGray,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _StatusBadge(online: _isOnline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _TelemetryValue(
                        value: _isOnline
                            ? '${satellite.busVoltage.toStringAsFixed(2)} V'
                            : '-- V',
                        label: 'Bus Voltage',
                        online: _isOnline,
                        highlight: true,
                      ),
                      const SizedBox(width: 40),
                      _TelemetryValue(
                        value: _isOnline
                            ? '${satellite.temperature.toStringAsFixed(1)} °C'
                            : '-- °C',
                        label: 'Temperature',
                        online: _isOnline,
                      ),
                    ],
                  ),
                ),
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
  final bool online;
  final bool highlight;

  const _TelemetryValue({
    required this.value,
    required this.label,
    required this.online,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = !online
        ? AppColors.textGray.withValues(alpha: 0.60)
        : highlight
            ? AppColors.success
            : AppColors.pureWhite;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.rajdhani(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: color.withValues(alpha: 0.90),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool online;

  const _StatusBadge({required this.online});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 74,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: online ? AppColors.success : AppColors.offlineBadge,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        online ? 'Online' : 'Offline',
        style: GoogleFonts.inter(
          color: online ? Colors.black : AppColors.textGray,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1,
        ),
      ),
    );
  }
}
