import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:go_router/go_router.dart';
import 'package:xft/core/api/api_client.dart';
import 'package:xft/core/presentation/widgets/back_button_app_bar.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final form = FormGroup(
    {
      'fullName': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(
        validators: [Validators.required, Validators.email],
      ),
      'phone': FormControl<String>(
        validators: [Validators.required, Validators.pattern(r'^[0-9]+$')],
      ),
      'password': FormControl<String>(
        validators: [Validators.required, Validators.minLength(6)],
      ),
      'passwordConfirmation': FormControl<String>(
        validators: [Validators.required],
      ),
    },
    validators: [Validators.mustMatch('password', 'passwordConfirmation')],
  );

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ref.listen(authProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString().replaceAll('Exception: ', '')),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        data: (auth) {
          if (auth != null && auth.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(auth.message),
                backgroundColor: colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.go('/');
          }
        },
      );
    });

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
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      Text(
                        'Bringing you a cup of Happiness',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bikin akun dulu, terus langsung eksplor menu favoritmu.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ReactiveForm(
                  formGroup: form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ReactiveTextField<String>(
                        formControlName: 'fullName',
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Nama Lengkap',
                        ),
                        keyboardType: TextInputType.name,
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                          'Nama lengkap tidak boleh kosong',
                        },
                      ),
                      const SizedBox(height: 16),
                      ReactiveTextField<String>(
                        formControlName: 'email',
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                          'Email tidak boleh kosong',
                          ValidationMessage.email: (error) =>
                          'Format email tidak valid',
                        },
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      ReactiveTextField<String>(
                        formControlName: 'password',
                        obscureText: _obscurePassword,
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                          'Password tidak boleh kosong',
                          ValidationMessage.minLength: (error) =>
                          'Password minimal harus 6 karakter',
                        },
                      ),
                      const SizedBox(height: 16),
                      ReactiveTextField<String>(
                        formControlName: 'passwordConfirmation',
                        obscureText: _obscureConfirmPassword,
                        decoration: inputDecorationTheme.copyWith(
                          labelText: 'Konfirmasi Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validationMessages: {
                          ValidationMessage.required: (error) =>
                          'Konfirmasi password tidak boleh kosong',
                          ValidationMessage.mustMatch: (error) =>
                          'Konfirmasi password harus sama dengan password',
                        },
                      ),
                      const SizedBox(height: 32),
                      authState.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            if (form.valid) {
                              ref
                                  .read(authProvider.notifier)
                                  .register(
                                form.control('fullName').value
                                as String,
                                form.control('email').value as String,
                                form.control('phone').value as String,
                                form.control('password').value
                                as String,
                              );
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
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              Opacity(
                                opacity: 0,
                                child: Icon(
                                  Icons.chevron_right,
                                  size: 24,
                                ),
                              ),
                              Text(
                                'Daftar',
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
                const SizedBox(height: 32),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dengan mendaftar Kamu menyetujui",
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            final baseUrl = ref.read(apiBaseUrlProvider);
                            final url = Uri.encodeComponent(
                              '$baseUrl/terms-and-conditions',
                            );
                            final title = Uri.encodeComponent(
                              'Syarat & Ketentuan',
                            );
                            context.push('/web-view?url=$url&title=$title');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Syarat Ketentuan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "-",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () {
                            final baseUrl = ref.read(apiBaseUrlProvider);
                            final url = Uri.encodeComponent(
                              '$baseUrl/privacy-policy',
                            );
                            final title = Uri.encodeComponent(
                              'Kebijakan Privasi',
                            );
                            context.push('/web-view?url=$url&title=$title');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Kebijakan Privasi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}