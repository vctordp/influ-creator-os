import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/services/gemini_service.dart';
import '../../core/constants/api_constants.dart';

class ContractScannerScreen extends StatefulWidget {
  const ContractScannerScreen({super.key});

  @override
  State<ContractScannerScreen> createState() => _ContractScannerScreenState();
}

class _ContractScannerScreenState extends State<ContractScannerScreen> {
  final _textController = TextEditingController();
  final _geminiService = GeminiService(ApiConstants.geminiApiKey);
  
  Map<String, dynamic>? _analysisResult;
  bool _isLoading = false;

  Future<void> _scanContract() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    final analysis = await _geminiService.analyzeContract(_textController.text);

    if (mounted) {
      setState(() {
        _isLoading = false;
        _analysisResult = analysis;
      });
    }
  }

  void _showEmailSheet() {
    if (_analysisResult == null || _analysisResult!['negotiation_email'] == null) return;

    final emailData = _analysisResult!['negotiation_email'];
    final subject = emailData['subject'] ?? "";
    final body = emailData['body'] ?? "";
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EmailBottomSheet(subject: subject, body: body),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show FAB only when we have a result
    return Scaffold(
      appBar: AppBar(title: const Text("CONTRACT SCANNER")),
      floatingActionButton: _analysisResult != null 
        ? FloatingActionButton.extended(
            onPressed: _showEmailSheet,
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: Colors.black,
            icon: const Icon(Icons.email_outlined),
            label: const Text("GET NEGOTIATION EMAIL"),
          ).animate().scale()
        : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
             Text(
              "TOKEN 3: THE LEGAL SHIELD",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Text(
              "Paste your contract text below. AI will find the traps.",
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(color: Colors.white70),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _textController,
              maxLines: 8,
              style: GoogleFonts.sourceCodePro(fontSize: 12),
              decoration: InputDecoration(
                hintText: "Paste contract clauses here...",
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _scanContract,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
              ),
              child: _isLoading 
                  ? const SizedBox(
                      height: 20, 
                      width: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                    )
                  : const Text("SCAN FOR RED FLAGS 🚩"),
            ),
            const SizedBox(height: 40),
            
            // ANALYSIS RESULTS
            if (_analysisResult != null) ...[
              _buildSafetyScore(_analysisResult!['safety_score']),
              const SizedBox(height: 24),
              ...(_analysisResult!['risks'] as List).map((risk) => _buildRiskCard(risk)),
              const SizedBox(height: 80), // Space for FAB
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyScore(dynamic score) {
    final int safeScore = (score is int) ? score : 0;
    Color scoreColor = safeScore > 80 ? Colors.green : (safeScore > 50 ? Colors.orange : Colors.red);

    return Column(
      children: [
        Text("SAFETY SCORE", style: GoogleFonts.montserrat(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Text(
          "\$safeScore/100", 
          style: GoogleFonts.bebasNeue(fontSize: 56, color: scoreColor),
        ).animate().fadeIn().scale(),
      ],
    );
  }

  Widget _buildRiskCard(Map<String, dynamic> risk) {
    bool isHighRisk = risk['severity'] == 'HIGH';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isHighRisk ? const Color(0xFF2A0000) : const Color(0xFF1E1E1E),
        border: Border.all(color: isHighRisk ? Colors.redAccent : Colors.white12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isHighRisk ? Icons.warning_amber : Icons.info_outline, color: isHighRisk ? Colors.red : Colors.amber),
              const SizedBox(width: 8),
              Text(
                "RISK: \${risk['severity']}",
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: isHighRisk ? Colors.redAccent : Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\"...\${risk['clause']}...\"",
            style: GoogleFonts.sourceCodePro(color: Colors.white70, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 12),
          Text(
            risk['explanation'] ?? "",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text("Fix: \${risk['fix']}", style: const TextStyle(color: Colors.greenAccent, fontSize: 13))),
              ],
            ),
          )
        ],
      ),
    ).animate().slideX();
  }
}

class _EmailBottomSheet extends StatelessWidget {
  final String subject;
  final String body;

  const _EmailBottomSheet({required this.subject, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4, 
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "NEGOTIATION EMAIL DRAFT",
            style: GoogleFonts.bebasNeue(fontSize: 24, letterSpacing: 1),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Subject: \$subject", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                    const Divider(),
                    Text(body, style: const TextStyle(color: Colors.black87, height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: "Subject: \$subject\n\n\$body"));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Email copied to clipboard!"))
              );
            },
            icon: const Icon(Icons.copy),
            label: const Text("COPY TO CLIPBOARD"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          )
        ],
      ),
    );
  }
}
