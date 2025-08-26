import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _loading = false;
  String? _message;

  // Zelfde stijl als LoginPage
  static const backgroundColor = Color(0xFFF5F5F5);
  static const fieldColor = Color(0xFFE6E6FA);
  static const textColor = Color(0xFF580F41);
  static const buttonGradientStart = Color(0xFF8E2DE2);
  static const buttonGradientEnd = Color(0xFF4A00E0);
  static const buttonTextColor = Color(0xFFF5F5F5);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _message = 'Please enter your email.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(
        email,
        // 🔑 Link naar jouw HTML-resetpagina op Cloudflare
        redirectTo: 'https://swapaza.pages.dev/reset-password.html',
      );

      setState(() => _message = '📧 Check your email for the reset link.');
    } on AuthException catch (e) {
      setState(() => _message = e.message);
    } catch (e) {
      setState(() => _message = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: textColor),
      filled: true,
      fillColor: fieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _gradientButton({
    required String text,
    required VoidCallback onPressed,
    bool loading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [buttonGradientStart, buttonGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: buttonTextColor,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: buttonTextColor,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme =
        GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: textColor,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Theme(
              data: Theme.of(context).copyWith(textTheme: textTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your email to reset your password.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _inputDecoration('Email'),
                    style: GoogleFonts.poppins(color: textColor),
                  ),
                  const SizedBox(height: 28),
                  _gradientButton(
                    text: 'Send reset link',
                    onPressed: _resetPassword,
                    loading: _loading,
                  ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 14),
                      child: Text(
                        _message!,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: _message!.startsWith('📧')
                              ? Colors.green
                              : Colors.red,
                        ),
                        textAlign: TextAlign.center,
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
