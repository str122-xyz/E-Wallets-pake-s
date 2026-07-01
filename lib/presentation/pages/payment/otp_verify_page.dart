import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/deeplink/deep_link_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../injection/injection_container.dart';
import '../../../data/datasources/local/secure_storage_datasource.dart';
import '../../blocs/auth/otp_bloc.dart';
import '../../blocs/payment/payment_bloc.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_top_bar.dart';

/// Lapisan kedua 2FA, dijalankan SETELAH PIN (lapisan pertama) berhasil.
/// Mengirim/menampilkan OTP sesuai metode yang sudah disetup user (email,
/// totp, firebase), lalu meneruskan kode yang diinput ke PaymentBloc.
class OtpVerifyPage extends StatefulWidget {
  final Map<String, dynamic> flowData;
  const OtpVerifyPage({super.key, required this.flowData});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _codeCtrl = TextEditingController();
  String _method = AppConstants.twoFaTotp;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _loadMethodAndSend();
  }

  Future<void> _loadMethodAndSend() async {
    final storage = sl<SecureStorageDatasource>();
    final saved = await storage.get2faMethod();
    if (saved != null && saved.isNotEmpty) {
      setState(() => _method = saved);
    }
    if (!mounted) return;
    // TOTP tidak butuh "kirim" -- user buka authenticator sendiri.
    if (_method == AppConstants.twoFaTotp) {
      setState(() => _sent = true);
    } else if (_method == AppConstants.twoFaSmtp) {
      context.read<OtpBloc>().add(OtpSendEmail());
    } else {
      context.read<OtpBloc>().add(OtpSendFirebase());
    }
  }

  String get _otpType {
    switch (_method) {
      case AppConstants.twoFaSmtp:
        return AppConstants.otpTypeEmail;
      case AppConstants.twoFaNotif:
        return AppConstants.otpTypeFirebase;
      default:
        return AppConstants.otpTypeTotp;
    }
  }

  void _submit() {
    final code = _codeCtrl.text.trim();
    if (code.length != 6) return;

    final flow = widget.flowData;
    final kind = flow['kind'] as String? ?? '';

    if (kind == 'topup') {
      // Topup di backend tidak mewajibkan OTP, tapi tetap kita jaga di sisi
      // UX agar konsisten melewati lapisan 2FA yang sama.
      context
          .read<PaymentBloc>()
          .add(PaymentTopupRequested((flow['amount'] as num).toDouble()));
      return;
    }

    context.read<PaymentBloc>().add(PaymentTransferRequested(
          amount: (flow['amount'] as num).toDouble(),
          description:
              (flow['note'] ?? flow['description']) as String? ?? 'Transaksi',
          otpCode: code,
          otpType: _otpType,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OtpBloc, OtpState>(
          listener: (context, state) {
            if (state is OtpSent) setState(() => _sent = true);
            if (state is OtpError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.red),
              );
            }
          },
        ),
        BlocListener<PaymentBloc, PaymentState>(
          listener: (context, state) {
            if (state is PaymentTransferSuccess) {
              final result = state.result;
              final flow = widget.flowData;
              final callback = flow['callback'] as String?;

              if (flow['kind'] == 'deeplink' &&
                  callback != null &&
                  callback.isNotEmpty) {
                // Kirim hasil transaksi balik ke app E-Commerce(Ngopss-App) pemanggil
                // SEBELUM menampilkan halaman Success milik app ini sendiri,
                // supaya app pemanggil bisa langsung update status order-nya.
                DeepLinkService.sendResult(
                  callbackBase: callback,
                  success: true,
                  orderId: flow['orderId'] as String?,
                  transactionId: result.transactionId,
                );
              }

              context.go('/success', extra: {
                'title': 'Transfer berhasil',
                'subtitle': result.description,
                'amount': result.amount,
                'lines': [
                  ['Jumlah', CurrencyFormatter.format(result.amount)],
                  [
                    'Saldo setelah',
                    CurrencyFormatter.format(result.balanceAfter)
                  ],
                  ['Ref', 'E-MY${result.transactionId}'],
                ],
              });
            } else if (state is PaymentTopupSuccess) {
              context.go('/success', extra: {
                'title': 'Top up berhasil',
                'subtitle': 'Saldo kamu bertambah',
                'amount': state.amount,
                'lines': [
                  ['Jumlah', CurrencyFormatter.format(state.amount)],
                  ['Saldo sekarang', CurrencyFormatter.format(state.balance)],
                ],
              });
            } else if (state is PaymentInvalidOtp) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.red),
              );
            } else if (state is PaymentError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.red),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppTopBar(title: 'Verifikasi 2FA', onBack: () => context.pop()),
        body: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, paymentState) {
            if (paymentState is PaymentLoading) {
              return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary));
            }
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_methodLabel(),
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      )),
                  const SizedBox(height: 8),
                  Text(_methodHint(),
                      style: const TextStyle(
                          fontSize: 13.5, color: AppColors.slate500)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _codeCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                        fontSize: 24,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                      label: 'Konfirmasi',
                      onPressed: _sent ? _submit : null,
                      fullWidth: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _methodLabel() {
    switch (_method) {
      case AppConstants.twoFaSmtp:
        return 'Masukkan kode dari Email';
      case AppConstants.twoFaNotif:
        return 'Masukkan kode dari Notifikasi';
      default:
        return 'Masukkan kode dari Authenticator';
    }
  }

  String _methodHint() {
    switch (_method) {
      case AppConstants.twoFaSmtp:
        return 'Kode 6 digit sudah dikirim ke email kamu. Cek inbox (atau folder spam).';
      case AppConstants.twoFaNotif:
        return 'Kode 6 digit sudah dikirim via notifikasi push ke perangkat kamu.';
      default:
        return 'Buka ekstensi/aplikasi Authenticator kamu, cari akun "E-Money App", lalu salin 6 digit kode yang sedang tampil (berganti tiap 30 detik).';
    }
  }
}
