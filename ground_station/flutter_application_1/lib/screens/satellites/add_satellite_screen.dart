import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AddSatelliteScreen extends StatefulWidget {
  const AddSatelliteScreen({super.key});

  @override
  State<AddSatelliteScreen> createState() => _AddSatelliteScreenState();
}

class _AddSatelliteScreenState extends State<AddSatelliteScreen> {
  final TextEditingController _deviceIdController = TextEditingController();

  bool _isConnecting = false;

  @override
  void dispose() {
    _deviceIdController.dispose();
    super.dispose();
  }

  Future<void> _connectDevice() async {
    final deviceId = _deviceIdController.text.trim();

    if (deviceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Device ID.'),
        ),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    // Mock connection for G1.6.
    await Future.delayed(
      const Duration(milliseconds: 1200),
    );

    if (!mounted) return;

    setState(() {
      _isConnecting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$deviceId connected successfully.'),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 560,
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

                      const Text(
                        'Add CubeSat',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  // Satellite / QR visual
                  Center(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: AppColors.spaceNavy,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: AppColors.accentCyan
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 70,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  const Center(
                    child: Text(
                      'Link your spacecraft',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Center(
                    child: Text(
                      'Scan the QR code on your CubeSat\nor enter its Device ID manually.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        height: 1.6,
                        color: AppColors.textGray,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // QR button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'QR Scanner will be added in a later phase.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                      ),
                      label: const Text(
                        'SCAN QR CODE',
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Color(0xFF1B293A),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: AppColors.textGray,
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Color(0xFF1B293A),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'DEVICE ID',
                    style: TextStyle(
                      color: AppColors.textGray,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _deviceIdController,
                    textCapitalization:
                        TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'e.g. DEJI-SAT-01',
                      prefixIcon: const Icon(
                        Icons.satellite_alt_rounded,
                      ),
                      filled: true,
                      fillColor: AppColors.cardBackground,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Color(0xFF1B293A),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.accentCyan,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton(
                      onPressed:
                          _isConnecting ? null : _connectDevice,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.accentBlue,
                        ),
                      ),
                      child: _isConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'CONNECT',
                            ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Information
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 19,
                          color: AppColors.accentCyan,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'The Device ID uniquely identifies your '
                            'FlatSat or CubeSat engineering model.',
                            style: TextStyle(
                              color: AppColors.textGray,
                              height: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
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