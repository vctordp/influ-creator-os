import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';
import '../../features/auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("SETTINGS", style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 2)),
        backgroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSectionTitle("ACCOUNT"),
          _buildSettingsTile(
            context, 
            icon: Icons.logout, 
            title: "Sign Out", 
            textColor: Colors.redAccent,
            onTap: () async {
              await context.read<AuthService>().logout();
              if (context.mounted) {
                 Navigator.of(context).pushAndRemoveUntil(
                   MaterialPageRoute(builder: (_) => const LoginScreen()),
                   (route) => false
                 );
              }
            }
          ),
          
          const SizedBox(height: 32),
          _buildSectionTitle("APP INFO"),
           _buildSettingsTile(context, icon: Icons.info_outline, title: "Version", subtitle: "1.0.0 (Beta)"),
           _buildSettingsTile(context, icon: Icons.privacy_tip_outlined, title: "Privacy Policy"),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title, 
        style: GoogleFonts.montserrat(
          fontSize: 12, 
          color: Colors.white54, 
          letterSpacing: 2, 
          fontWeight: FontWeight.bold
        )
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon, 
    required String title, 
    String? subtitle,
    VoidCallback? onTap,
    Color textColor = Colors.white
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white10)),
      leading: Icon(icon, color: textColor == Colors.white ? Colors.white70 : textColor),
      title: Text(title, style: GoogleFonts.outfit(color: textColor, fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.white38)) : null,
      trailing: onTap != null ? const Icon(Icons.chevron_right, color: Colors.white24) : null,
    );
  }
}
