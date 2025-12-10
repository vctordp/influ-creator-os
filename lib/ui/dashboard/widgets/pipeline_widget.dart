import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../features/crm/services/brand_deal_service.dart';

class PipelineWidget extends StatelessWidget {
  const PipelineWidget({super.key});

  @override
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
              const Icon(Icons.view_kanban_outlined, color: Colors.white, size: 18),
              Text("PIPELINE", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA1A1AA), letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          // Live Data
          Expanded(
            child: FutureBuilder<List<dynamic>>( // Using dynamic for now to avoid model import issues if any
              future: context.read<BrandDealService>().fetchDeals(), 
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2));
                }

                final deals = snapshot.data!;
                final prospecting = deals.where((d) => d.status == 'prospecting').length;
                final active = deals.where((d) => d.status == 'negotiation' || d.status == 'contract_sent').length;
                final closed = deals.where((d) => d.status == 'closed' || d.status == 'completed').length;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMinimalStatus("Ideias", "$prospecting", Colors.orange), // Mapping Prospecting to 'Idea/Roteiro' conceptually
                    _buildMinimalStatus("Negociação", "$active", Colors.blueAccent),
                    _buildMinimalStatus("Fechados", "$closed", Colors.green),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMinimalStatus(String label, String count, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(count, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w600, color: const Color(0xFFEDEDED))),
        Row(
           children: [
             Container(width: 4, height: 4, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
             const SizedBox(width: 6),
             Text(label, style: GoogleFonts.inter(color: const Color(0xFFA1A1AA), fontSize: 11)),
           ]
        ),
      ],
    );
  }
}
