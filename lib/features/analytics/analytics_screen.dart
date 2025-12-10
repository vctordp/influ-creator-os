import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E),
      body: Stack(
        children: [
           // Ambient Orb
          Positioned(
            top: -200,
            left: 100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E1B4B).withValues(alpha: 0.2), 
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox(),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 60, color: const Color(0xFF6366F1).withValues(alpha: 0.5)),
                const SizedBox(height: 24),
                Text(
                  "ANALYTICS ENGINE",
                  style: GoogleFonts.inter(
                    fontSize: 12, 
                    fontWeight: FontWeight.w900, 
                    letterSpacing: 2.0, 
                    color: const Color(0xFF6366F1)
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Data Intelligence Coming Soon",
                  style: GoogleFonts.inter(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: const Color(0xFFEDEDED),
                    letterSpacing: -1.0
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "We are aggregating your cross-platform metrics\ninto a unified dashboard.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 15, 
                    color: const Color(0xFFA1A1AA), 
                    height: 1.5
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1C1E),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Text(
                    "ETA: Q1 2026",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, fontWeight: FontWeight.w600),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
