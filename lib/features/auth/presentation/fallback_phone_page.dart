import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/presentation/widgets/back_button_app_bar.dart';

class FallbackPhonePage extends ConsumerStatefulWidget {
  const FallbackPhonePage({super.key});

  @override
  ConsumerState<FallbackPhonePage> createState() => _FallbackPhonePageState();
}

class _FallbackPhonePageState extends ConsumerState<FallbackPhonePage> {

  final form = FormGroup({
    'phone': FormControl<String>(
      validators: [Validators.required, Validators.pattern(r'^[0-9]+$')],
    ),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final inputDecorationTheme = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: Colors.black.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const BackButtonAppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        'Masukkan No. Handphone',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tambahkan nomor handphone agar pesanan lebih lancar dan kamu nggak ketinggalan promo terbaru.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ReactiveForm(
                  formGroup: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReactiveTextField<String>(
                        formControlName: 'phone',
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'No. Handphone',
                        ),
                        keyboardType: TextInputType.phone,
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                              'Nomor handphone tidak boleh kosong',
                          ValidationMessage.pattern: (error) =>
                              'Nomor handphone hanya boleh berisi angka',
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () async {
                            if (form.valid) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Nomor handphone berhasil disimpan',
                                  ),
                                  backgroundColor: colorScheme.primary,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              context.pop();
                            } else {
                              form.markAllAsTouched();
                            }
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF262626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: Icon(Icons.chevron_right, size: 24),
                              ),
                              Text(
                                'Kirim',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.chevron_right, size: 24),
                            ],
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
    );
  }
}
