import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _agreedToTerms = false;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  static const backgroundColor = Color(0xFFF5F5F5);
  static const fieldColor = Color(0xFFE6E6FA);
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
    _fadeAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _agreedToTerms) {
      print('✅ Account aangemaakt voor $_email');
      Navigator.pop(context);
    } else if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je moet akkoord gaan met de voorwaarden')),
      );
    }
  }

  InputDecoration _inputDecoration(String label, {bool isPassword = false, VoidCallback? toggleVisibility, bool? obscure}) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: textColor),
      filled: true,
      fillColor: fieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      suffixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscure! ? Icons.visibility_off : Icons.visibility,
                color: textColor,
              ),
              onPressed: toggleVisibility,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      Theme.of(context).textTheme,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Form(
                    key: _formKey,
                    child: Theme(
                      data: Theme.of(context).copyWith(textTheme: textTheme),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 12),
                          TextFormField(
                            decoration: _inputDecoration('Username or email'),
                            style: GoogleFonts.poppins(color: textColor),
                            onChanged: (val) => _email = val,
                            validator: (val) =>
                                val!.isEmpty ? 'Vul je email in' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: _inputDecoration(
                              'Password',
                              isPassword: true,
                              obscure: _obscurePassword,
                              toggleVisibility: () => setState(() {
                                _obscurePassword = !_obscurePassword;
                              }),
                            ),
                            style: GoogleFonts.poppins(color: textColor),
                            obscureText: _obscurePassword,
                            onChanged: (val) => _password = val,
                            validator: (val) =>
                                val!.length < 6 ? 'Minimaal 6 tekens' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: _inputDecoration(
                              'Confirm password',
                              isPassword: true,
                              obscure: _obscureConfirmPassword,
                              toggleVisibility: () => setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              }),
                            ),
                            style: GoogleFonts.poppins(color: textColor),
                            obscureText: _obscureConfirmPassword,
                            onChanged: (val) => _confirmPassword = val,
                            validator: (val) => val != _password
                                ? 'Wachtwoorden komen niet overeen'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _agreedToTerms,
                                onChanged: (val) =>
                                    setState(() => _agreedToTerms = val!),
                                fillColor:
                                    MaterialStateProperty.all(fieldColor),
                                checkColor: buttonGradientEnd,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'I agree to the terms of service and privacy policy',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  buttonGradientStart,
                                  buttonGradientEnd
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 4),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Create Account',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: buttonTextColor,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black26,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
