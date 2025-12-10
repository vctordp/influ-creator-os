import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardSidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const DashboardSidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // Clip for blur
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 250,
          height: double.infinity,
          color: const Color(0xFF0B0C0E).withValues(alpha: 0.7), // Semi-transparent charcoal
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               // Brand
               Padding(
                 padding: const EdgeInsets.only(left: 0, bottom: 40, top: 10),
                 child: Row(
                   children: [
                     Image.asset(
                       'assets/images/logo_symbol.png',
                       height: 32,
                       width: 32,
                       fit: BoxFit.contain,
                     ),
                     const SizedBox(width: 12),
                     Text(
                       "UNICO", 
                       style: GoogleFonts.inter(
                         fontSize: 16, 
                         color: Colors.white, 
                         letterSpacing: 1.5, 
                         fontWeight: FontWeight.w900
                       )
                     ),
                   ],
                 ),
               ),

               // Navigation
               _buildNavItem(0, "Visão Geral", Icons.dashboard_outlined),
               _buildNavItem(1, "Pipeline", Icons.view_kanban_outlined),
               _buildNavItem(2, "Negócios & CRM", Icons.handshake_outlined),
               _buildNavItem(3, "Mídia Kit", Icons.perm_media_outlined),
               _buildNavItem(4, "Analytics", Icons.analytics_outlined),
               const Spacer(),
               _buildNavItem(5, "Configurações", Icons.settings_outlined),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = selectedIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: () => onItemSelected(index),
          selected: isSelected,
          selectedTileColor: Colors.white.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Icon(icon, color: isSelected ? Colors.white : const Color(0xFFA1A1AA), size: 20),
          title: Text(
            label, 
            style: GoogleFonts.inter(
              color: isSelected ? Colors.white : const Color(0xFFA1A1AA),
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              fontSize: 13
            )
          ),
        ),
      ),
    );
  }
}
