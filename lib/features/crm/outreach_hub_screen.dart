import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/services/gemini_service.dart';
import '../../core/services/auth_service.dart';
import 'services/brand_deal_service.dart';
import 'models/brand_deal.dart';

class OutreachHubScreen extends StatefulWidget {
  const OutreachHubScreen({super.key});

  @override
  State<OutreachHubScreen> createState() => _OutreachHubScreenState();
}

class _OutreachHubScreenState extends State<OutreachHubScreen> {
  final _service = BrandDealService();
  List<BrandDeal> _deals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeals();
  }

  Future<void> _loadDeals() async {
    final deals = await _service.fetchDeals();
    if (mounted) {
      setState(() {
        _deals = deals;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter deals by status category
    final prospecting = _deals.where((d) => d.status == 'prospecting').toList();
    final negotiation = _deals.where((d) => ['negotiation', 'contract_sent'].contains(d.status)).toList();
    final closed = _deals.where((d) => ['active', 'completed'].contains(d.status)).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A), // Slate 900
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F172A),
          title: Text(
            "OUTREACH PIPELINE",
            style: GoogleFonts.bebasNeue(
              fontSize: 28,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          bottom: TabBar(
            indicatorColor: const Color(0xFF6366F1), // Indigo
            labelColor: const Color(0xFF6366F1),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: "PROSPECTS (\${prospecting.length})"),
              Tab(text: "ACTIVE (\${negotiation.length})"),
              Tab(text: "CLOSED (\${closed.length})"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDealDialog,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("NEW DEAL", style: TextStyle(color: Colors.white)),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildDealList(prospecting, Colors.blueGrey),
                  _buildDealList(negotiation, Colors.orangeAccent),
                  _buildDealList(closed, const Color(0xFF10B981)), // Emerald
                ],
              ),
      ),
    );
  }

  Widget _buildDealList(List<BrandDeal> deals, Color accentColor) {
    if (deals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.white10),
            const SizedBox(height: 16),
            Text("No deals in this stage", style: TextStyle(color: Colors.white24)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deals.length,
      itemBuilder: (context, index) {
        final deal = deals[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: accentColor.withValues(alpha: 0.2),
              child: Text(
                deal.brandName[0].toUpperCase(),
                style: TextStyle(color: accentColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              deal.brandName,
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(deal.contactEmail ?? "No contact info", style: const TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        deal.status.toUpperCase().replaceAll('_', ' '),
                        style: TextStyle(color: accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    if (deal.value > 0)
                      Text(
                        "R\$ \${deal.value.toStringAsFixed(0)}",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)),
              onPressed: () => _showEmailGenerator(deal),
              tooltip: "Generate Cold Mail",
            ),
            onTap: () {
              // TODO: Open Deal Detail / Edit
            },
          ),
        ).animate().fadeIn(delay: (index * 100).ms).slideX();
      },
    );
  }

  void _showEmailGenerator(BrandDeal deal) async {
    final auth = context.read<AuthService>();
    final gemini = context.read<GeminiService>();
    
    // Show Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    
    // Generate
    final emailContent = await gemini.generateColdMail(
      deal.brandName, 
      auth.userNiche, 
      "\${auth.userFollowers}"
    );
    
    // Hide Loading
    if (mounted) Navigator.pop(context);

    // Show Result & Edit
    final bodyController = TextEditingController(text: emailContent);
    final subjectController = TextEditingController(text: "Partnership Opportunity: \${auth.userHandle} x \${deal.brandName}");
    
    if (!mounted) return;

    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Row(children: [
          Icon(Icons.auto_awesome, color: Color(0xFF6366F1)), 
          SizedBox(width: 8), 
          Text("AI COLD MAIL", style: TextStyle(color: Colors.white))
        ]),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: "Subject", labelStyle: TextStyle(color: Colors.white54)),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                 controller: bodyController,
                 maxLines: 8,
                 decoration: const InputDecoration(labelText: "Body", filled: true, fillColor: Colors.black12),
                 style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton.icon(
            onPressed: () async {
               await _service.queueEmail(
                 dealId: deal.id,
                 recipientEmail: deal.contactEmail ?? "change@me.com",
                 subject: subjectController.text,
                 body: bodyController.text,
               );
               if (mounted) {
                 Navigator.pop(context);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                   content: Text("Email Queued for Sending! 🚀"),
                   backgroundColor: Color(0xFF10B981),
                 ));
                 _loadDeals(); // Refresh to see status change
               }
            },
            icon: const Icon(Icons.send),
            label: const Text("QUEUE SEND"),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          )
        ],
      )
    );
  }

  void _showAddDealDialog() {
    final brandController = TextEditingController();
    final emailController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: Text("Add New Prospect", style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: brandController,
              decoration: const InputDecoration(labelText: "Brand Name", filled: true, fillColor: Colors.black26),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Contact Email", filled: true, fillColor: Colors.black26),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: valueController,
              decoration: const InputDecoration(labelText: "Est. Value (Optional)", filled: true, fillColor: Colors.black26),
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCEL")),
          ElevatedButton(
            onPressed: () async {
              if (brandController.text.isNotEmpty) {
                await _service.createDeal(
                  brandName: brandController.text,
                  contactEmail: emailController.text.isEmpty ? null : emailController.text,
                  value: double.tryParse(valueController.text) ?? 0,
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadDeals();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6366F1), foregroundColor: Colors.white),
            child: const Text("ADD DEAL"),
          ),
        ],
      ),
    );
  }
}
