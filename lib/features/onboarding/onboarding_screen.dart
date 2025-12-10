import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../ui/dashboard/dashboard_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _handleController = TextEditingController();
  final _nicheController = TextEditingController(); // e.g., Tech, Beauty
  final _followersController = TextEditingController();
  
  bool _isLoading = false;

  Future<void> _completeProfile() async {
    if (_handleController.text.isEmpty || _nicheController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final auth = context.read<AuthService>();
      
      await auth.updateProfile(
        handle: _handleController.text.trim(),
        niche: _nicheController.text.trim(),
        followers: int.tryParse(_followersController.text.replaceAll(',', '')) ?? 0,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.5, -0.3), // Spotlight effect
            radius: 0.8,
            colors: [const Color(0xFF2A2A2A), Colors.black],
          ),
        ),
        padding: const EdgeInsets.all(32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.rocket_launch, size: 64, color: Colors.amber).animate().scale(duration: 600.ms),
                const SizedBox(height: 32),
                Text(
                  "WELCOME TO THE CLUB",
                  style: GoogleFonts.bebasNeue(fontSize: 42, color: Colors.white, letterSpacing: 1),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Let's customize your AI Agent.\nAdd your details to generate personalized content.",
                  style: GoogleFonts.inter(fontSize: 14, color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                _buildTextField(
                  label: "YOUR HANDLE", 
                  hint: "@username", 
                  icon: Icons.alternate_email,
                  controller: _handleController
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "YOUR NICHE", 
                  hint: "e.g. Tech, Beauty, Fitness", 
                  icon: Icons.category,
                  controller: _nicheController
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: "FOLLOWERS", 
                  hint: "e.g. 10000", 
                  icon: Icons.groups,
                  controller: _followersController,
                  isNumber: true
                ),

                const SizedBox(height: 40),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _completeProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : Text(
                          "LAUNCH DASHBOARD", 
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, letterSpacing: 1)
                        ),
                  ),
                ),
              ].animate(interval: 100.ms).fadeIn().moveY(begin: 20, end: 0),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required String hint, 
    required IconData icon, 
    required TextEditingController controller,
    bool isNumber = false
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white12),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
