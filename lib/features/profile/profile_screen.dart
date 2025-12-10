import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _handleController = TextEditingController();
  final _nicheController = TextEditingController();
  final _followersController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final auth = context.read<AuthService>();
    _handleController.text = auth.userHandle;
    _nicheController.text = auth.userNiche;
    _followersController.text = auth.userFollowers.toString();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().updateProfile(
        handle: _handleController.text,
        niche: _nicheController.text,
        followers: int.tryParse(_followersController.text) ?? 0,
      );
      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated!")));
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
      appBar: AppBar(
        title: Text("MY PROFILE", style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 2)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            }, 
            icon: _isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : Icon(_isEditing ? Icons.check : Icons.edit, color: const Color(0xFFFFD700))
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
             const CircleAvatar(
               radius: 50,
               backgroundColor: Color(0xFF1E1E1E),
               child: Icon(Icons.person, size: 50, color: Colors.white54),
             ),
             const SizedBox(height: 32),
             
             _buildTextField("HANDLE", _handleController, Icons.alternate_email),
             const SizedBox(height: 24),
             _buildTextField("NICHE", _nicheController, Icons.category),
             const SizedBox(height: 24),
             _buildTextField("FOLLOWERS", _followersController, Icons.groups, isNumber: true),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.montserrat(fontSize: 12, color: const Color(0xFFFFD700), fontWeight: FontWeight.bold, letterSpacing: 1)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: _isEditing,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: TextStyle(color: _isEditing ? Colors.white : Colors.white70),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white38),
            filled: true,
            fillColor: _isEditing ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFFD700))),
          ),
        ),
      ],
    );
  }
}
