import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';

class EditPasswordPage extends ConsumerStatefulWidget {
  const EditPasswordPage({super.key});

  @override
  ConsumerState<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends ConsumerState<EditPasswordPage> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSaving = false;

  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    form = FormGroup(
      {
        'currentPassword': FormControl<String>(
          validators: [Validators.required],
        ),
        'newPassword': FormControl<String>(
          validators: [Validators.required, Validators.minLength(6)],
        ),
        'confirmPassword': FormControl<String>(
          validators: [Validators.required],
        ),
      },
      validators: [Validators.mustMatch('newPassword', 'confirmPassword')],
    );
  }

  Future<void> _savePassword() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(authProvider.notifier)
          .changePassword(
            currentPassword: form.control('currentPassword').value as String,
            newPassword: form.control('newPassword').value as String,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Ubah Password'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            ReactiveForm(
              formGroup: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReactiveTextField<String>(
                    formControlName: 'currentPassword',
                    obscureText: _obscureCurrentPassword,
                    decoration: _passwordDecoration(
                      'Password Saat Ini',
                      colorScheme,
                      _obscureCurrentPassword,
                      () => setState(
                        () =>
                            _obscureCurrentPassword = !_obscureCurrentPassword,
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Password saat ini tidak boleh kosong',
                    },
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'newPassword',
                    obscureText: _obscureNewPassword,
                    decoration: _passwordDecoration(
                      'Password Baru',
                      colorScheme,
                      _obscureNewPassword,
                      () => setState(
                        () => _obscureNewPassword = !_obscureNewPassword,
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Password baru tidak boleh kosong',
                      ValidationMessage.minLength: (error) =>
                          'Password baru minimal 6 karakter',
                    },
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'confirmPassword',
                    obscureText: _obscureConfirmPassword,
                    decoration: _passwordDecoration(
                      'Konfirmasi Password Baru',
                      colorScheme,
                      _obscureConfirmPassword,
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                    ),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Konfirmasi password tidak boleh kosong',
                      ValidationMessage.mustMatch: (error) =>
                          'Password tidak cocok',
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _savePassword,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.xftSurface,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Simpan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _passwordDecoration(
    String label,
    ColorScheme colorScheme,
    bool obscureText,
    VoidCallback onToggleVisibility,
  ) {
    return InputDecoration(
      labelText: label,
      suffixIcon: IconButton(
        icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility),
        onPressed: onToggleVisibility,
      ),
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
  }
}
