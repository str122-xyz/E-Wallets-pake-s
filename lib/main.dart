import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'core/deeplink/deep_link_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_bloc_observer.dart';
import 'firebase_options.dart';
import 'injection/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Bloc.observer = const AppBlocObserver();

  // Initialize Firebase dengan konfigurasi dari FlutterFire CLI
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize dependency injection
  await di.init();

  // Deep Link: dengarkan permintaan pembayaran dari app E-Commerce eksternal.
  // Navigasi sesungguhnya ditangani oleh DompetKampusApp
  await DeepLinkService.instance.init();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const DompetKampusApp());
}

class DompetKampusApp extends StatefulWidget {
  const DompetKampusApp({super.key});

  @override
  State<DompetKampusApp> createState() => _DompetKampusAppState();
}

class _DompetKampusAppState extends State<DompetKampusApp> {
  @override
  void initState() {
    super.initState();
    // untuk menangkap link saat aplikasi berjalan di background
    DeepLinkService.pendingPayment.addListener(_onPendingPayment);

    // pengecekan saat aplikasi baru (Cold Start)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (DeepLinkService.pendingPayment.value != null) {
        _onPendingPayment();
      }
    });
  }

  @override
  void dispose() {
    DeepLinkService.pendingPayment.removeListener(_onPendingPayment);
    super.dispose();
  }

  void _onPendingPayment() {
    final data = DeepLinkService.pendingPayment.value;
    if (data == null) return;

    // Memantau pergerakan rute aplikasi
    _tryPushToMerchant(data);
  }

  void _tryPushToMerchant(Map<String, dynamic> data) {
    // Ambil posisi URL/Route aplikasi saat ini secara realtime
    final currentPath =
        AppRouter.router.routerDelegate.currentConfiguration.uri.path;

    // if app masih di splashpage ('/')
    if (currentPath == '/' || currentPath.isEmpty) {
      debugPrint(
          '[DeepLink] Masih di Splash Screen, nunggu mendarat di /home...');
      Future.delayed(const Duration(milliseconds: 400), () {
        _tryPushToMerchant(data);
      });
      return;
    }

    // jika bkn di splash
    DeepLinkService.pendingPayment.value =
        null; // Kosongin datanya biar ga kepanggil 2x
    debugPrint('[DeepLink] Rute aman ($currentPath), sikat push ke /merchant!');

    // Kasih jeda dikit buat animasi transisi Home
    Future.delayed(const Duration(milliseconds: 300), () {
      AppRouter.router.go('/merchant', extra: data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dompet Kampus Global',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
    );
  }
}
