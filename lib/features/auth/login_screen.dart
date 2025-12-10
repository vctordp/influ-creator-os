import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/localization_service.dart';
import '../onboarding/onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _handleAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    final authService = context.read<AuthService>();
    String? error;

    if (_isSignUp) {
      error = await authService.signUp(email, password);
    } else {
      error = await authService.login(email, password);
    }

    if (mounted) {
      setState(() => _isLoading = false);
      
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (_isSignUp) {
           if (authService.isLoggedIn) {
             Navigator.of(context).pushReplacement(
               MaterialPageRoute(builder: (_) => const OnboardingScreen()),
             );
           } else {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Account created! Verify email to login.")),
             );
             setState(() => _isSignUp = false);
           }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = context.watch<LocalizationService>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0057FF), width: 2), // UNICO Blue
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF0057FF).withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
                  ],
                ),
                child: Image.asset('assets/images/logo_symbol.png', width: 64, height: 64),
              ).animate().fadeIn(duration: 800.ms).scale(),
              
              const SizedBox(height: 40),
              
              Text(
                i18n.getString('app_title'),
                style: GoogleFonts.bebasNeue(
                  fontSize: 48, 
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              
              Text(
                _isSignUp ? "CREATE VIP ACCOUNT" : i18n.getString('login_title'),
                style: GoogleFonts.montserrat(
                  color: const Color(0xFF0057FF), // UNICO Blue
                  letterSpacing: 4, 
                  fontSize: 12, 
                  fontWeight: FontWeight.bold
                ),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 60),

              _buildTextField(_emailController, i18n.getString('email_label'), Icons.email),
              const SizedBox(height: 20),
              _buildTextField(_passwordController, i18n.getString('password_label'), Icons.lock, isPassword: true),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleAuth,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0057FF), // UNICO Blue
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    : Text(
                        _isSignUp ? "CREATE ACCOUNT" : i18n.getString('login_btn'), 
                        style: GoogleFonts.montserrat(fontWeight: FontWeight.bold)
                      ),
                ),
              ).animate().fadeIn(delay: 600.ms),
              
              const SizedBox(height: 20),

              TextButton(
                onPressed: () => setState(() => _isSignUp = !_isSignUp),
                child: Text(
                  _isSignUp ? "Already have an account? Login" : "Don't have an account? Sign Up",
                  style: GoogleFonts.montserrat(color: Colors.white70),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: i18n.toggleLanguage, 
                child: Text(
                  i18n.locale.languageCode == 'pt' ? "Mudar para Inglês 🇺🇸" : "Switch to Portuguese 🇧🇷",
                  style: const TextStyle(color: Colors.white54),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFFD700)),
        ),
      ),
    );
  }
}
