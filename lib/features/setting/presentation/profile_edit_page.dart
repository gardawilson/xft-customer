import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reactive_forms/reactive_forms.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xft/core/theme/app_colors.dart';
import 'package:xft/features/auth/presentation/auth_notifier.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarFile;
  bool _isAvatarRemoved = false;
  bool _isSaving = false;

  late final FormGroup form;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authProvider);
    final user = authState.value?.data?.user;

    form = FormGroup({
      'name': FormControl<String>(
        value: user?.fullName ?? '',
        validators: [Validators.required],
      ),
      'email': FormControl<String>(
        value: user?.email ?? '',
        validators: [Validators.required, Validators.email],
      ),
      'phone': FormControl<String>(
        value: user?.phoneNumber ?? '',
        validators: [Validators.required],
      ),
    });
  }

  Future<void> _pickImage() async {
    // maxWidth/maxHeight/imageQuality: image_picker otomatis resize +
    // kompres gambar sebelum dikembalikan, jadi ukuran file yang di-upload
    // jauh lebih kecil (biasanya di bawah 500KB) dan tidak akan melebihi
    // batas upload_max_filesize di PHP atau validasi max:2048 di Laravel.
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 70,
    );
    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
        _isAvatarRemoved = false;
      });
    }
  }

  void _removeImage() {
    setState(() {
      _avatarFile = null;
      _isAvatarRemoved = true;
    });
  }

  Future<void> _saveProfile() async {
    if (!form.valid) {
      form.markAllAsTouched();
      return;
    }

    // Pengaman tambahan: cek ukuran file di sisi Flutter dulu, supaya kalau
    // ada foto yang tetap kelewat besar, user dapat pesan error yang JELAS
    // -- bukan gagal diam-diam seperti sebelumnya (akibat PHP menolak file
    // di level upload_max_filesize sebelum sempat divalidasi Laravel).
    if (_avatarFile != null) {
      final fileSizeInMB = (await _avatarFile!.length()) / (1024 * 1024);
      if (fileSizeInMB > 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Ukuran foto terlalu besar (maksimal 2MB). Coba pilih foto lain.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await ref
          .read(authProvider.notifier)
          .updateProfile(
            name: form.control('name').value as String,
            phone: form.control('phone').value as String,
            avatarFile: _avatarFile,
            removeAvatar: _isAvatarRemoved,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profil berhasil diperbarui'),
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
    final authState = ref.watch(authProvider);
    final user = authState.value?.data?.user;

    final hasAvatar =
        _avatarFile != null || (user?.avatarUrl != null && !_isAvatarRemoved);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Edit Profil'),
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
            // Avatar form
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colorScheme.secondaryContainer,
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                          width: 2,
                        ),
                      ),
                      child: ClipOval(
                        child: _avatarFile != null
                            ? Image.file(_avatarFile!, fit: BoxFit.cover)
                            : (user?.avatarUrl != null && !_isAvatarRemoved
                                  ? Image.network(
                                      user!.avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              _fallbackAvatar(),
                                    )
                                  : _fallbackAvatar()),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: hasAvatar ? _removeImage : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: hasAvatar
                              ? colorScheme.error
                              : colorScheme.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          hasAvatar ? Icons.delete : Icons.camera_alt,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
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
                    formControlName: 'name',
                    decoration: _inputDecoration('Nama Lengkap', colorScheme),
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Nama tidak boleh kosong',
                    },
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'email',
                    readOnly: true,
                    decoration: _inputDecoration(
                      'Email',
                      colorScheme,
                    ).copyWith(
                      helperText: 'Email tidak dapat diubah',
                      fillColor: colorScheme.surfaceContainerHighest,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Email tidak boleh kosong',
                      ValidationMessage.email: (error) =>
                          'Format email tidak valid',
                    },
                  ),
                  const SizedBox(height: 20),
                  ReactiveTextField<String>(
                    formControlName: 'phone',
                    decoration: _inputDecoration('Nomor Telepon', colorScheme),
                    keyboardType: TextInputType.phone,
                    validationMessages: {
                      ValidationMessage.required: (error) =>
                          'Nomor Telepon tidak boleh kosong',
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _isSaving ? null : _saveProfile,
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

  Widget _fallbackAvatar() {
    return Icon(
      Icons.person_rounded,
      color: Theme.of(context).colorScheme.onSecondaryContainer,
      size: 48,
    );
  }

  InputDecoration _inputDecoration(String label, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
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
