import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/legal_service.dart';

class LegalHubScreen extends StatefulWidget {
  const LegalHubScreen({super.key});

  @override
  State<LegalHubScreen> createState() => _LegalHubScreenState();
}

class _LegalHubScreenState extends State<LegalHubScreen> {
  final _service = LegalService();
  List<ContractTemplate> _templates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    final templates = await _service.fetchTemplates();
    if (mounted) {
      setState(() {
        _templates = templates;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        title: Text(
          "LEGAL SHIELD",
          style: GoogleFonts.bebasNeue(fontSize: 28, letterSpacing: 2, color: Colors.white),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history, color: Colors.white54))
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 400,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: _templates.length,
              itemBuilder: (context, index) {
                final template = _templates[index];
                return _buildTemplateCard(template, index);
              },
            ),
    );
  }

  Widget _buildTemplateCard(ContractTemplate template, int index) {
    return Card(
      color: const Color(0xFF1E293B).withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: InkWell(
        onTap: () => _showGeneratorWizard(template),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.gavel, color: const Color(0xFF6366F1), size: 32),
                  const Spacer(),
                  if (template.isPro)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(4)),
                      child: const Text("PRO", style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
                    )
                ],
              ),
              const Spacer(),
              Text(
                template.name,
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                template.description,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideY(begin: 0.1);
  }

  void _showGeneratorWizard(ContractTemplate template) {
    final brandController = TextEditingController();
    final valueController = TextEditingController();
    bool exclusivity = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text("Draft: \${template.name}", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Fill in the details to generate a legally binding draft.", style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: "Brand Name", filled: true, fillColor: Colors.black26),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: "Contract Value", filled: true, fillColor: Colors.black26),
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text("Exclusivity Clause?", style: TextStyle(color: Colors.white)),
                activeColor: const Color(0xFF6366F1),
                value: exclusivity,
                onChanged: (val) => setState(() => exclusivity = val),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                _simulateGeneration();
              },
              icon: const Icon(Icons.print),
              label: const Text("GENERATE DRAFT"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _simulateGeneration() {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Color(0xFF6366F1)),
              const SizedBox(height: 20),
              Text("Analyzing Clauses...", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24))
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 1200.ms, color: const Color(0xFF6366F1)),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context); // Close loader
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            title: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 64),
            content: const Text(
              "Contract generated and saved to Drive!",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
            actions: [
               TextButton(onPressed: () => Navigator.pop(context), child: const Text("OPEN IN DOCS")),
            ],
          ),
        );
      }
    });
  }
}
