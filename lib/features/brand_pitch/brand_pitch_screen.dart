import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/auth_service.dart';

class BrandPitchScreen extends StatefulWidget {
  const BrandPitchScreen({super.key});

  @override
  State<BrandPitchScreen> createState() => _BrandPitchScreenState();
}

class _BrandPitchScreenState extends State<BrandPitchScreen> {
  final _brandController = TextEditingController();
  final _nicheController = TextEditingController();
  late final GeminiService _geminiService;
  
  String? _generatedPitch;
  bool _isGenerating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(ApiConstants.geminiApiKey);
  }

  Future<void> _generatePitch() async {
    if (_brandController.text.isEmpty || _nicheController.text.isEmpty) return;
    
    FocusScope.of(context).unfocus();

    setState(() {
      _isGenerating = true;
      _generatedPitch = null;
    });

    try {
      final auth = context.read<AuthService>();
      
      // Inject User Profile Context into the prompt
      final contextString = "Context: I am a creator in the ${auth.userNiche} niche with ${auth.userFollowers} followers. My Handle is ${auth.userHandle}.";
      final promptContext = "$contextString Target Objective: ${_nicheController.text}";

      final pitch = await _geminiService.generateBrandPitch(
        _brandController.text, 
        promptContext
      );

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _generatedPitch = pitch;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
        setState(() => _isGenerating = false);
      }
    }
  }

  Future<void> _savePitch() async {
    if (_generatedPitch == null) return;
    
    setState(() => _isSaving = true);
    
    final auth = context.read<AuthService>();
    final uid = auth.currentUser?.id;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You must be logged in to save.")));
      setState(() => _isSaving = false);
      return;
    }

    try {
      await Supabase.instance.client.from('generated_content').insert({
        'user_id': uid,
        'content_type': 'pitch',
        'content_body': _generatedPitch,
        'meta_data': {
          'brand': _brandController.text,
          'goal': _nicheController.text
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Pitch saved to history!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: \$e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _copyToClipboard() {
    if (_generatedPitch != null) {
      Clipboard.setData(ClipboardData(text: _generatedPitch!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pitch copied! Ready to send. 🚀")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("BRAND HUNTER")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "TOKEN 4: ACTIVE INCOME",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              "Generate a high-converting cold pitch in seconds.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.white54),
            ),
            const SizedBox(height: 40),
            
            _buildTextField(
              controller: _brandController,
              label: "Target Brand",
              hint: "e.g., Nike, Coca-Cola",
              icon: Icons.business,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nicheController,
              label: "The Brand's Goal",
              hint: "e.g., Launching new running shoes",
              icon: Icons.flag,
            ),
            const SizedBox(height: 30),
            
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generatePitch,
              icon: _isGenerating 
                  ? const SizedBox() 
                  : const Icon(Icons.rocket_launch, color: Colors.black),
              label: _isGenerating 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                  : const Text("GENERATE PITCH"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
            ),

            if (_generatedPitch != null) ...[
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("YOUR PITCH", style: TextStyle(color: Colors.white54, fontSize: 12)),
                        Row(
                          children: [
                            IconButton(
                              icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_alt, color: Colors.white),
                              onPressed: _isSaving ? null : _savePitch,
                              tooltip: "Save to History",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white),
                              onPressed: _copyToClipboard,
                              tooltip: "Copy Text",
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    const SizedBox(height: 10),
                    SelectableText(
                      _generatedPitch!,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 14, 
                        height: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.1, end: 0),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFFFFD700)),
        filled: true,
        fillColor: const Color(0xFF111111),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
