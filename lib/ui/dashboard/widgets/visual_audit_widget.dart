import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../features/visual_audit/services/visual_audit_service.dart';
import '../../../../features/visual_audit/visual_audit_screen.dart';

class VisualAuditWidget extends StatelessWidget {
  const VisualAuditWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ideally fetch from 'generated_content' where type = 'audit' and order by created_at desc 

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualAuditScreen())),
      child: Container(
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
                const Icon(Icons.policy_outlined, color: Colors.white, size: 18),
                Text("NOTA", style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFFA1A1AA), letterSpacing: 0.5)),
              ],
            ),
            const Spacer(),
            Center(
               child: FutureBuilder<int?>(
                 future: context.read<VisualAuditService>().getLatestScore(),
                 builder: (context, snapshot) {
                   if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24));
                   }
                   
                   final score = snapshot.data ?? 0;
                   // If 0 or null, maybe show "N/A" or 0
                   
                   return Stack(
                      alignment: Alignment.center,
                      children: [
                         SizedBox(
                           width: 70, 
                           height: 70,
                           child: CircularProgressIndicator(
                             value: score > 0 ? score / 100 : 0,
                             backgroundColor: Colors.white.withValues(alpha: 0.02),
                             color: const Color(0xFF00FF94), // Neon Mint
                             strokeWidth: 3, 
                           ),
                         ),
                         Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             Text(score > 0 ? "$score" : "--", style: GoogleFonts.inter(fontSize: 20, color: const Color(0xFFEDEDED), fontWeight: FontWeight.bold)),
                           ],
                         )
                      ],
                    );
                 }
               ),
            )
          ],
        ),
      ),
    );
  }
}
