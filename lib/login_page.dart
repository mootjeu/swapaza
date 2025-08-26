import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_account_page.dart';
import 'dashboard_page.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _passwordVisible = false;
  bool _loading = false;
  String? _errorMessage;

  // Kleuren
  static const backgroundColor = Color(0xFFF5F5F5);
  static const fieldColor = Color(0xFFE6E6FA); // lavendel, duidelijk zichtbaar
  static const textColor = Color(0xFF580F41);
  static const buttonGradientStart = Color(0xFF8E2DE2);
  static const buttonGradientEnd = Color(0xFF4A00E0);
  static const buttonTextColor = Color(0xFFF5F5F5);

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    var identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Please fill in both fields.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      // Username -> email lookup
      if (!identifier.contains('@')) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('email')
            .eq('username', identifier)
            .maybeSingle();

        if (profile == null) {
          setState(() => _errorMessage = 'No account found for this username.');
          return;
        }
        identifier = profile['email'] as String;
      }

      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: identifier,
        password: password,
      );

      if (!mounted) return;

      if (res.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardPage(
              username: res.user!.userMetadata?['username'] ?? identifier,
            ),
          ),
        );
      } else {
        setState(() => _errorMessage = 'Login failed. Please check your credentials.');
      }
    } on AuthException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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

  Widget _gradientButton(String text, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [buttonGradientStart, buttonGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
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

  Widget _animatedLogo(double logoHeight) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Image.asset(
          'assets/swapaza_logo.png',
          height: logoHeight,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme);
    final mq = MediaQuery.of(context);
    final bottomInset = mq.viewInsets.bottom;
    final keyboardOpen = bottomInset > 0;
    final screenH = mq.size.height;
    final compact = screenH < 700;

    // Groter logo bij gesloten toetsenbord
    final double logoHeight = keyboardOpen
        ? (compact ? 70.0 : 78.0)
        : (compact ? 110.0 : 130.0);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          toolbarHeight: 0,
        ),
        body: SafeArea(
          child: Theme(
            data: Theme.of(context).copyWith(textTheme: textTheme),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo strak tegen bovenkant met minimale ruimte
                Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 6),
                  child: _animatedLogo(logoHeight),
                ),
                // Form-blok, geen kleur/schaduw zodat er geen “rechthoek” zichtbaar is
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: bottomInset + 12,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              // Geen decoration-kleur en geen boxShadow => blok is onzichtbaar
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextField(
                                    controller: _identifierController,
                                    textInputAction: TextInputAction.next,
                                    decoration: _inputDecoration('Username or Email'),
                                    style: GoogleFonts.poppins(color: textColor),
                                  ),
                                  const SizedBox(height: 10),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: !_passwordVisible,
                                    decoration: _inputDecoration(
                                      'Password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _passwordVisible ? Icons.visibility_off : Icons.visibility,
                                          color: textColor,
                                        ),
                                        onPressed: () => setState(() {
                                          _passwordVisible = !_passwordVisible;
                                        }),
                                      ),
                                    ),
                                    style: GoogleFonts.poppins(color: textColor),
                                    onSubmitted: (_) => _handleLogin(),
                                  ),
                                  const SizedBox(height: 6),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const ForgotPasswordPage(),
                                          ),
                                        );
                                      },
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8),
                                        minimumSize: const Size(0, 32),
                                      ),
                                      child: Text(
                                        'Forgot password?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: buttonGradientEnd,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  _gradientButton('Login', _handleLogin),
                                  if (_errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(color: Colors.red, fontSize: 14),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Text(
                                      'or',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _gradientButton(
                                    'Create Account',
                                    () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const CreateAccountPage(),
                                        ),
                                      );
                                      _identifierController.clear();
                                      _passwordController.clear();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
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
