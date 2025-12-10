import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/gemini_service.dart';
import 'services/visual_audit_service.dart';

class VisualAuditScreen extends StatefulWidget {
  const VisualAuditScreen({super.key});

  @override
  State<VisualAuditScreen> createState() => _VisualAuditScreenState();
}

class _VisualAuditScreenState extends State<VisualAuditScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _analysisResult;
  bool _isAnalyzing = false;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _analysisResult = null; // Reset previous result
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_imageBytes == null) return;

    setState(() => _isAnalyzing = true);

    try {
      final gemini = context.read<GeminiService>();
      final prompt = """
      You are an expert Social Media Consultant and Brand Strategist. 
      Analyze this screenshot of a creator's profile (Instagram/TikTok/YouTube).
      Provide a "Visual Audit" with the following sections:
      
      1. **First Impression Score (0-10)**: Be honest.
      2. **The Vibe**: Describe the aesthetic and branding consistency.
      3. **Bio Roast**: Critique the bio. Is it clear? Does it have a CTA?
      4. **Content Strategy Audit**: Look at the thumbnails/posts. Are they clickable? Viral potential?
      5. **3 Quick Wins**: Specific actionable improvements they can make right now.
      
      Keep the tone professional yet punchy and slightly edgy (like a high-end consultant).
      """;

      final result = await gemini.analyzeImage(_imageBytes!, prompt);
      
      // Parse score from result (simple heuristic: look for "Score: X/10" or similar)
      int score = 0;
      final scoreMatch = RegExp(r'Score:?\s*(\d{1,2})/10').firstMatch(result); // Matches Score: 8/10
      if (scoreMatch != null) {
        score = int.parse(scoreMatch.group(1)!);
        score = score * 10; // Convert 8/10 to 80/100
      } else {
        // Fallback: try to find just a number near "Score"
         final scoreMatch2 = RegExp(r'Rating:?\s*(\d{1,2}\.?\d?)/10').firstMatch(result);
         if (scoreMatch2 != null) {
            double s = double.parse(scoreMatch2.group(1)!);
            score = (s * 10).toInt();
         }
      }

      // Save to Service
      if (mounted) {
         await context.read<VisualAuditService>().saveAuditResult(
           score: score, 
           report: result
         );
      }
      
      if (mounted) {
        setState(() {
          _analysisResult = result;
          _isAnalyzing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: \$e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text("VISUAL AUDIT", style: GoogleFonts.bebasNeue(fontSize: 28, letterSpacing: 2, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Upload Area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: _imageBytes == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 64, color: const Color(0xFF6366F1).withValues(alpha: 0.8))
                              .animate(onPlay: (c) => c.repeat(reverse: true))
                              .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
                          const SizedBox(height: 20),
                          Text("UPLOAD PROFILE SCREENSHOT", style: GoogleFonts.outfit(color: Colors.white70, fontWeight: FontWeight.bold)),
                          Text("Instagram, TikTok, or YouTube", style: GoogleFonts.outfit(color: Colors.white38, fontSize: 12)),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
              ),
            ),

            const SizedBox(height: 32),

            // Analyze Button
            if (_imageBytes != null && !_isAnalyzing)
              ElevatedButton.icon(
                onPressed: _analyzeImage,
                icon: const Icon(Icons.analytics_outlined),
                label: const Text("RUN AUDIT Protocol"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                  textStyle: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ).animate().fadeIn().slideY(begin: 0.5),

            if (_isAnalyzing)
              Column(
                children: [
                   const CircularProgressIndicator(color: Color(0xFF10B981)),
                   const SizedBox(height: 16),
                   Text("ANALYZING VISUAL DATA...", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 18))
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(color: const Color(0xFF10B981), duration: 1.5.seconds),
                ],
              ),

            const SizedBox(height: 32),

            // Results Area
            if (_analysisResult != null)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: Color(0xFF10B981)),
                        const SizedBox(width: 12),
                        Text("AUDIT REPORT", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 32),
                    Text(
                      _analysisResult!,
                      style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.9), fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.5),
          ],
        ),
      ),
    );
  }
}
