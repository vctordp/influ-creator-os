import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../core/services/auth_service.dart';

class QuickIdeaWidget extends StatefulWidget {
  const QuickIdeaWidget({super.key});

  @override
  State<QuickIdeaWidget> createState() => _QuickIdeaWidgetState();
}

class _QuickIdeaWidgetState extends State<QuickIdeaWidget> {
  final _controller = TextEditingController();
  bool _saving = false;

  Future<void> _saveIdea() async {
    if (_controller.text.isEmpty) return;
    setState(() => _saving = true);

    try {
      final uid = context.read<AuthService>().currentUser?.id;
      if (uid != null) {
        await Supabase.instance.client.from('generated_content').insert({
          'user_id': uid,
          'content_type': 'video_idea',
          'content_body': _controller.text,
          'meta_data': {'source': 'dashboard_widget'}
        });
        if (mounted) {
           _controller.clear();
           ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Idea saved to Vault!")));
        }
      }
    } catch (_) {
      // Silent error for widget
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.white, size: 18),
              Text("IDEIA RÁPIDA", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA1A1AA), letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF27272A), // Input background
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 14),
                    child: Icon(Icons.edit_note, color: Colors.white24, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      style: GoogleFonts.inter(color: const Color(0xFFEDEDED), fontSize: 13, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: "Digite uma ideia...",
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: _saving ? null : _saveIdea,
              icon: _saving 
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))
                : const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 20),
            ),
          )
        ],
      ),
    );
  }
}
