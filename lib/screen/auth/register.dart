import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Password dan Konfirmasi Password tidak cocok');
      return;
    }

    setState(() => _isLoading = true);

    // TODO: Ganti dengan logika register API kamu
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);

    if (mounted) {
      _showSuccess('Pendaftaran berhasil! Silakan login.');
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1A6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ✅ Popup info
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFFF1ECE2),
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: Color(0xFF1A6B6B)),
            SizedBox(width: 8),
            Text(
              'Informasi',
              style: TextStyle(
                color: Color(0xFF0D4A4A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Daftarkan akun kamu untuk mulai perjalanan ibadah bersama MuslimNoob. Daftar menggunakan email yang valid dan buat password yang kuat untuk keamanan akun kamu. Setelah mendaftar, kamu bisa langsung login dan menikmati fitur-fitur yang kami sediakan untuk membantu ibadahmu lebih mudah dan menyenangkan.',
          style: TextStyle(
            color: Color(0xFF0D4A4A),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1A6B6B),
              minimumSize: const Size(double.infinity, 48), // ← tambah ini
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.white.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF0D4A4A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              child: IconTheme(
                data: const IconThemeData(
                  color: Color(0xFF0D4A4A),
                  size: 16,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1ECE2),
      body: SafeArea(
        child: Column(
          children: [
            // === HEADER ===
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Button Kembali (kiri)
                  _buildGlassButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Kembali',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // Button Info (kanan) ✅
                  _buildGlassButton(
                    onPressed: () => _showInfoDialog(),
                    child: const Icon(Icons.info_outline, size: 20),
                  ),
                ],
              ),
            ),

            // === FORM ===
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),

                      // Title
                      const Text(
                        'Daftar',
                        style: TextStyle(
                          fontSize: 46,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D4A4A),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nama Lengkap
                      _buildTextField(
                        controller: _nameController,
                        hint: 'Nama Lengkap',
                        capitalization: TextCapitalization.words,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Nama tidak boleh kosong';
                          if (val.trim().length < 3)
                            return 'Nama minimal 3 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Email
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Email tidak boleh kosong';
                          if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                              .hasMatch(val.trim()))
                            return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        hint: 'Password',
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF1A6B6B),
                            size: 20,
                          ),
                          onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Password tidak boleh kosong';
                          if (val.length < 6)
                            return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Konfirmasi Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hint: 'Konfirmasi Password',
                        obscureText: _obscureConfirmPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: const Color(0xFF1A6B6B),
                            size: 20,
                          ),
                          onPressed: () => setState(() =>
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Konfirmasi password tidak boleh kosong';
                          if (val != _passwordController.text)
                            return 'Password tidak cocok';
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Daftar Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1A6B6B),
                            disabledBackgroundColor: Colors.grey[300],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap:
                              _isLoading ? null : () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: 'Sudah memiliki Akun? ',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: _isLoading
                                        ? Colors.grey
                                        : const Color(0xFF1A6B6B),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalization,
      obscureText: obscureText,
      enabled: !_isLoading,
      inputFormatters: inputFormatters,
      style: const TextStyle(color: Color(0xFF0D4A4A), fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A6B6B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      validator: validator,
    );
  }
}