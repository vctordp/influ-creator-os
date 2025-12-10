import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../payment/payment_service.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("SELECT PLAN", style: GoogleFonts.bebasNeue(fontSize: 28, color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text("Unlock your potential", style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 48),
            
            _buildPlanCard("CREATOR", "\$0", ["3 Audits", "Basic Stats"], "creator"),
            const SizedBox(height: 24),
            _buildPlanCard("PRO", "\$39/mo", ["Unlimited Audits", "Viral AI", "Deal CRM"], "pro", isPopular: true),
            const SizedBox(height: 24),
            _buildPlanCard("AGENCY", "\$129/mo", ["Team Seats", "API Access", "White Label"], "agency"),
            
            const SizedBox(height: 48),
            
            if (_selectedPlan != null)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedPlan != null) {
                       PaymentService().launchCheckout(_selectedPlan!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFCCFF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                  ),
                  child: Text("CHECKOUT WITH STRIPE", style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ).animate().shimmer(duration: 2.seconds),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, List<String> features, String planId, {bool isPopular = false}) {
    final isSelected = _selectedPlan == planId;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlan = planId);
      },
      child: AnimatedContainer(
        duration: 300.ms,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E1E1E) : Colors.black,
          border: Border.all(
            color: isSelected ? const Color(0xFFCCFF00) : Colors.white12, 
            width: isSelected ? 2 : 1
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPopular)
                     Padding(
                       padding: const EdgeInsets.only(bottom: 8.0),
                       child: Text("MOST POPULAR", style: GoogleFonts.montserrat(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFCCFF00))),
                     ),
                  Text(title, style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(price, style: GoogleFonts.outfit(fontSize: 20, color: Colors.white70)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: features.map((f) => Chip(
                      label: Text(f, style: GoogleFonts.outfit(fontSize: 10, color: Colors.white)),
                      backgroundColor: Colors.white10,
                      padding: EdgeInsets.zero,
                    )).toList(),
                  )
                ],
              ),
            ),
            Radio<String>(
              value: planId, 
              groupValue: _selectedPlan, 
              onChanged: (val) => setState(() => _selectedPlan = val),
              activeColor: const Color(0xFFCCFF00),
            )
          ],
        ),
      ),
    );
  }
}
