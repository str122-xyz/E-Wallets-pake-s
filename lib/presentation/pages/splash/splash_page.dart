import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // engecekan auth pas app baru dibuka
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          // Kalau udah login, langsung ke home
          context.go('/home');
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative circles
                Positioned(
                  top: -120,
                  right: -90,
                  child: Container(
                    width: 320,
                    height: 320,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 120,
                  left: -100,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.07),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const Spacer(),

                      const AppLogo(size: 150, light: true),
                      const SizedBox(height: 10),

                      // judul
                      const Text(
                        'Eh-MyWallets',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),

                      // sub judul
                      const Text(
                        'Eh Ada MyWallets',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // sub judul
                      const Text(
                        'Kelola dompet digital dan transaksi\nlangsung dari genggamanmu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 15,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      // logic button dissapear
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          // cuma muncul jika sistem udah yakin user belum login
                          if (state is AuthUnauthenticated) {
                            return Column(
                              children: [
                                AppButton(
                                  label: 'Buat Akun Baru',
                                  variant: AppButtonVariant.white,
                                  onPressed: () => context.push('/register'),
                                ),
                                const SizedBox(height: 11),
                                AppButton(
                                  label: 'Masuk ke Akun',
                                  variant: AppButtonVariant.outlineWhite,
                                  onPressed: () => context.push('/login'),
                                ),
                                const SizedBox(height: 30),
                              ],
                            );
                          }

                          return const Padding(
                            padding: EdgeInsets.only(bottom: 50.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
