import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../features/auth/subscription_screen.dart';

class PricingSectionV2 extends StatefulWidget {
  const PricingSectionV2({super.key});

  @override
  State<PricingSectionV2> createState() => _PricingSectionV2State();
}

class _PricingSectionV2State extends State<PricingSectionV2> {
  String _billingCycle = 'monthly'; // 'monthly' or 'annual'

  // Colors
  final Color _acidGreen = const Color(0xFFCCFF00);
  final Color _darkBg = Colors.black;
  final Color _cardBg = const Color(0xFF111827); // Gray-900ish

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _darkBg,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Column(
        children: [
          // HEADER
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _acidGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: _acidGreen.withOpacity(0.3)),
            ),
            child: Text(
              "ESCOLHA SUA ARMA",
              style: GoogleFonts.sora(
                color: _acidGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "PRICING PLANS",
            style: GoogleFonts.poppins(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            "Planos flexíveis para criadores de todos os tamanhos.\nComece grátis e escale conforme sua audiência cresce.",
            style: GoogleFonts.sora(
              fontSize: 18,
              color: Colors.white54,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // BILLING TOGGLE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildToggleButton('Mensal', 'monthly'),
              const SizedBox(width: 16),
              _buildToggleButton('Anual', 'annual', badge: 'Economize 17%'),
            ],
          ),
          const SizedBox(height: 64),

          // PRICING CARDS
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPlanCard('creator')),
                    const SizedBox(width: 24),
                    Expanded(child: _buildPlanCard('pro', isHighlighted: true)),
                    const SizedBox(width: 24),
                    Expanded(child: _buildPlanCard('agency')),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildPlanCard('creator'),
                    const SizedBox(height: 24),
                    _buildPlanCard('pro', isHighlighted: true),
                    const SizedBox(height: 24),
                    _buildPlanCard('agency'),
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 80),

          // FAQ
          Text(
            "Dúvidas Frequentes",
            style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, constraints) {
             return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildFaqItem("Posso mudar de plano a qualquer momento?", "Sim! Você pode fazer upgrade ou downgrade do seu plano a qualquer momento."),
                  _buildFaqItem("Existe período de teste gratuito?", "O plano CREATOR é completamente gratuito para sempre."),
                  _buildFaqItem("Vocês oferecem descontos anuais?", "Sim! Planos anuais têm 17% de desconto."),
                  _buildFaqItem("Como funciona o suporte?", "CREATOR tem email. PRO tem prioridade. AGENCY tem suporte 24/7."),
                ],
             );
          }),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value, {String? badge}) {
    final isSelected = _billingCycle == value;
    return GestureDetector(
      onTap: () => setState(() => _billingCycle = value),
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _acidGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? _acidGreen : Colors.white24),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.sora(
                color: isSelected ? Colors.black : Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 8),
              Text(
                badge,
                style: GoogleFonts.sora(
                  color: isSelected ? Colors.black87 : _acidGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String id, {bool isHighlighted = false}) {
    final isPro = id == 'pro';
    final isAgency = id == 'agency';

    final name = isPro ? "PRO" : (isAgency ? "AGENCY" : "CREATOR");
    // Prices based on react component
    final monthlyPrice = isPro ? 39 : (isAgency ? 129 : 0);
    final annualPrice = isPro ? 390 : (isAgency ? 1290 : 0);
    final price = _billingCycle == 'monthly' ? monthlyPrice : annualPrice;
    final period = _billingCycle == 'monthly' ? '/mês' : '/ano';
    
    final description = isPro 
      ? 'Para criadores sérios que querem crescer rápido' 
      : (isAgency ? 'Para agências e equipes em crescimento' : 'Perfeito para começar sua jornada');
    
    final features = isPro 
      ? ['Audits Ilimitados', 'Viral Prediction', 'Deal Flow CRM', 'Suporte Prioritário', 'Stripe Integration'] 
      : (isAgency 
          ? ['5 Assentos', 'White Label', 'API Access', 'Gerente Dedicado', 'Suporte 24/7'] 
          : ['3 AI Audits/mês', 'Analytics Básico', 'Script Generator', 'Comunidade']);

    final cta = isPro || isAgency ? "COMEÇAR AGORA" : "COMEÇAR GRÁTIS";

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: isHighlighted ? _cardBg.withOpacity(0.9) : _cardBg.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isHighlighted ? _acidGreen : Colors.white12,
              width: isHighlighted ? 2 : 1,
            ),
            boxShadow: isHighlighted ? [BoxShadow(color: _acidGreen.withOpacity(0.2), blurRadius: 32)] : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICON PLACEHOLDER (Using Material Icons as close match)
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isHighlighted ? _acidGreen.withOpacity(0.2) : Colors.white10,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPro ? Icons.trending_up : (isAgency ? Icons.groups : Icons.bolt),
                  color: isHighlighted ? _acidGreen : Colors.white54,
                ),
              ),
              const SizedBox(height: 24),
              Text(name, style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 8),
              Text(description, style: GoogleFonts.sora(fontSize: 14, color: Colors.white54)),
              const SizedBox(height: 32),
              
              // PRICE
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text("\$$price", style: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(width: 4),
                  Text(period, style: GoogleFonts.sora(fontSize: 16, color: Colors.white54)),
                ],
              ),
              const SizedBox(height: 32),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                     // Keep existing navigation
                     Navigator.push(context, MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isHighlighted ? _acidGreen : const Color(0xFF1F2937),
                    foregroundColor: isHighlighted ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    side: isHighlighted ? BorderSide.none : const BorderSide(color: Colors.white24),
                  ),
                  child: Text(cta, style: GoogleFonts.sora(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              Text("INCLUSO:", style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white38, letterSpacing: 1)),
              const SizedBox(height: 16),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: isHighlighted ? _acidGreen : Colors.white38),
                    const SizedBox(width: 12),
                    Expanded(child: Text(f, style: GoogleFonts.sora(color: Colors.white70, fontSize: 14))),
                  ],
                ),
              )),
            ],
          ),
        ),
        if (isHighlighted)
          Positioned(
            top: -12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: _acidGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "MAIS POPULAR",
                style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          )
      ],
    );
  }

  Widget _buildFaqItem(String q, String a) {
    return Container(
      width: 400,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Text(a, style: GoogleFonts.sora(fontSize: 14, color: Colors.white54, height: 1.5)),
        ],
      )
    );
  }
}
