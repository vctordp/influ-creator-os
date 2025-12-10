import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/auth_service.dart';

class ViralHubScreen extends StatefulWidget {
  const ViralHubScreen({super.key});

  @override
  State<ViralHubScreen> createState() => _ViralHubScreenState();
}

class _ViralHubScreenState extends State<ViralHubScreen> {
  final _topicController = TextEditingController();
  late final GeminiService _geminiService;
  
  String? _scripts;
  bool _isGenerating = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(ApiConstants.geminiApiKey);
  }

  Future<void> _generateScripts() async {
    if (_topicController.text.isEmpty) return;
    FocusScope.of(context).unfocus();

    setState(() {
      _isGenerating = true;
      _scripts = null;
    });

    try {
      final auth = context.read<AuthService>();
      final contextString = "Context: I create content in the ${auth.userNiche} niche. Hande: ${auth.userHandle}.";
      final prompt = "$contextString Trending Topic: ${_topicController.text}";

      final results = await _geminiService.generateViralScripts(prompt);

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _scripts = results;
        });
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
         setState(() => _isGenerating = false);
       }
    }
  }

  Future<void> _saveScripts() async {
    if (_scripts == null) return;
    
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
        'content_type': 'script',
        'content_body': _scripts,
        'meta_data': {
          'topic': _topicController.text,
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Scripts saved to history!")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Save failed: \$e")));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("VIRAL WRITER")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "TOKEN 6: TREND JACKING",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
             const SizedBox(height: 10),
            Text(
              "Turn a trending topic into 3 ready-to-shoot scripts.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.white54),
            ),
            const SizedBox(height: 30),
            
            TextField(
              controller: _topicController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "What's trending? (Topic)",
                hintText: "e.g., AI replacing coders, Travel hacks",
                prefixIcon: const Icon(Icons.trending_up, color: Color(0xFFFFD700)),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _isGenerating ? null : _generateScripts,
              icon: _isGenerating ? const SizedBox() : const Icon(Icons.movie_creation, color: Colors.black),
              label: _isGenerating 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)) 
                : const Text("GENERATE SCRIPTS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
            ),
            
            if (_scripts != null) ...[
              const SizedBox(height: 40),
               Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurpleAccent.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("VIRAL SCRIPTS", style: GoogleFonts.montserrat(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                             IconButton(
                              icon: _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_alt, color: Colors.white),
                              onPressed: _isSaving ? null : _saveScripts,
                              tooltip: "Save to History",
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white54),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _scripts!));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Scripts copied!")));
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(color: Colors.white10),
                    Text(_scripts!, style: GoogleFonts.roboto(height: 1.5, fontSize: 14)),
                  ],
                ),
              ).animate().slideY(begin: 0.1, end: 0),
            ]
          ],
        ),
      ),
    );
  }
}
