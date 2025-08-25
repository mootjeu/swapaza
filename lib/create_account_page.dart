import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  String? _errorMessage;

  static const backgroundColor = Color(0xFFF5F5F5);
  static const fieldColor = Color(0xFFE6E6FA);
  static const textColor = Color(0xFF580F41);
  static const buttonGradientStart = Color(0xFF8E2DE2);
  static const buttonGradientEnd = Color(0xFF4A00E0);
  static const buttonTextColor = Color(0xFFF5F5F5);

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || username.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Check of username al bestaat
      final existing = await Supabase.instance.client
          .from('profiles')
          .select('username')
          .eq('username', username)
          .maybeSingle();

      if (existing != null) {
        setState(() => _errorMessage = 'Username is already taken.');
        return;
      }

      // Sign up in Supabase
      final res = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      if (res.user != null) {
        // Opslaan in profiles tabel
        await Supabase.instance.client.from('profiles').insert({
          'id': res.user!.id,
          'username': username,
          'email': email,
        });

        _showSnack('✅ Account created! Please check your email to verify.');
        if (mounted) Navigator.pop(context);
      } else {
        setState(() => _errorMessage = 'Sign up failed. Please try again.');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  InputDecoration _inputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: textColor),
      filled: true,
      fillColor: fieldColor,
      suffixIcon: suffixIcon,
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
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);

    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: true, // laat achtergrondkleur doorlopen tot boven
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Theme(
                data: Theme.of(context).copyWith(textTheme: textTheme),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Email'),
                      style: GoogleFonts.poppins(color: textColor),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration('Username (unique)'),
                      style: GoogleFonts.poppins(color: textColor),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: textColor,
                          ),
                          onPressed: () => setState(
                              () => _passwordVisible = !_passwordVisible),
                        ),
                      ),
                      style: GoogleFonts.poppins(color: textColor),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        'Confirm password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: textColor,
                          ),
                          onPressed: () => setState(
                              () => _confirmPasswordVisible =
                                  !_confirmPasswordVisible),
                        ),
                      ),
                      style: GoogleFonts.poppins(color: textColor),
                    ),
                    const SizedBox(height: 28),
                    _gradientButton(
                      text: 'Create account',
                      onPressed: _createAccount,
                      loading: _loading,
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
