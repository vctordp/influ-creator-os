import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../features/crm/models/brand_deal.dart';
import '../../../features/crm/services/brand_deal_service.dart';

class FinancialWidget extends StatefulWidget {
  const FinancialWidget({super.key});

  @override
  State<FinancialWidget> createState() => _FinancialWidgetState();
}

class _FinancialWidgetState extends State<FinancialWidget> {
  final _service = BrandDealService();
  double _potentialRevenue = 0;
  int _activeDeals = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final deals = await _service.fetchDeals();
    double potential = 0;
    int active = 0;
    for (var deal in deals) {
      if (deal.status != 'completed' && deal.status != 'lost') {
        potential += deal.value;
        active++;
      }
    }
    if (mounted) {
      setState(() {
        _potentialRevenue = potential;
        _activeDeals = active;
        _loading = false;
      });
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
              const Icon(Icons.monetization_on_outlined, color: Colors.white, size: 18),
              Text(
                "RESUMO FINANCEIRO", 
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA1A1AA), letterSpacing: 0.5)
              ),
            ],
          ),
          const Spacer(),
          _loading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24))
            : _activeDeals == 0 && _potentialRevenue == 0 
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.show_chart, color: Colors.white24, size: 32),
                        const SizedBox(height: 8),
                        Text("Sem dados recentes", style: GoogleFonts.inter(color: Colors.white24, fontSize: 12)),
                      ],
                    )
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("\$${_potentialRevenue.toStringAsFixed(0)}", style: GoogleFonts.inter(fontSize: 42, color: const Color(0xFFEDEDED), fontWeight: FontWeight.w600, letterSpacing: -1.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text("$_activeDeals negócios ativos", style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 12)),
                        ],
                      ),
                    ],
                  )
        ],
      ),
    );
  }
}
