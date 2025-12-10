import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ViralHubWidget extends StatelessWidget {
  const ViralHubWidget({super.key});

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
              const Icon(Icons.auto_graph, color: Colors.white, size: 18),
              Text("TENDÊNCIAS VIRAIS", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA1A1AA), letterSpacing: 0.5)),
            ],
          ),
          const Spacer(),
          // Mock Sparkline
          SizedBox(
            height: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(12, (index) { 
                final height = [20.0, 35.0, 15.0, 25.0, 45.0, 30.0, 50.0, 40.0, 55.0, 45.0, 60.0, 50.0][index];
                return Container(
                  width: 4,
                  height: height * 0.6, 
                  decoration: BoxDecoration(
                    color: index >= 9 ? const Color(0xFF9D00FF) : const Color(0xFF27272A), // Purple accent for recent
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          )
        ],
      ),
    );
  }
}
