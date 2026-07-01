import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../injection/injection_container.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/pin_pad.dart';

class PinPage extends StatefulWidget {
  final Map<String, dynamic> flowData;
  const PinPage({super.key, required this.flowData});

  @override
  State<PinPage> createState() => _PinPageState();
}

class _PinPageState extends State<PinPage> {
  String _pin = '';
  bool _busy = false;
  bool _hasError = false;

  void _onComplete(String pin) async {
    setState(() => _busy = true);

    final storage = sl<SecureStorageDatasource>();
    final savedPin = await storage.getPin();

    if (savedPin == null || savedPin.isEmpty) {
      // Belum pernah set PIN -> simpan PIN ini sebagai PIN baru, lanjut.
      await storage.savePin(pin);
    } else if (pin != savedPin) {
      setState(() {
        _busy = false;
        _hasError = true;
        _pin = '';
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) setState(() => _hasError = false);
      });
      return;
    }

    if (!mounted) return;
    setState(() => _busy = false);
    // PIN benar -> lanjut ke lapisan kedua 2FA (OTP/TOTP asli).
    context.go('/otp-verify', extra: widget.flowData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.ink),
                onPressed: () => context.go('/home'),
              ),
            ),
            if (_busy) ...[
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 18),
                    Text('Memeriksa PIN…',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate600,
                        )),
                  ],
                ),
              ),
            ] else ...[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                  child: Column(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                            child: Icon(Icons.lock_outline_rounded,
                                size: 26, color: AppColors.primary)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Masukkan PIN',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          )),
                      const SizedBox(height: 6),
                      const Text('Masukkan 6 digit PIN keamanan kamu',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13.5, color: AppColors.slate500)),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        transform: _hasError
                            ? (Matrix4.identity()..translate(10.0))
                            : Matrix4.identity(),
                        child: PinPad(
                          value: _pin,
                          onChanged: (v) => setState(() => _pin = v),
                          onComplete: _onComplete,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text.rich(TextSpan(
                        text: 'Lupa PIN? ',
                        style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12.5,
                            color: AppColors.slate400),
                        children: [
                          TextSpan(
                            text: 'Reset',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
