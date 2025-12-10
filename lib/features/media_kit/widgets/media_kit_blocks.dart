import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/media_kit_block.dart';

// --- WRAPPER ---
class MediaKitBlockWrapper extends StatelessWidget {
  final Widget child;
  const MediaKitBlockWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}

// --- 1. HERO HEADER ---
class HeroHeaderBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const HeroHeaderBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [const Color(0xFF1A1A1A), Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        image: DecorationImage(
          image: NetworkImage("https://source.unsplash.com/1600x900/?${data['backgroundImageKeyword'] ?? 'abstract'}"),
          fit: BoxFit.cover,
          onError: (_, __) {}, // Fallback to gradient
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (data['title'] ?? '').toUpperCase(),
            style: GoogleFonts.bebasNeue(fontSize: 64, color: Colors.white, letterSpacing: 2),
            textAlign: TextAlign.center,
          ).animate().fadeIn().slideY(begin: 0.3, end: 0),
          const SizedBox(height: 16),
          Text(
            data['subtitle'] ?? '',
            style: GoogleFonts.montserrat(fontSize: 18, color: const Color(0xFFFFD700)),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
}

// --- 2. STATS GRID ---
class StatsGridBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const StatsGridBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final metrics = (data['metrics'] as List<dynamic>? ?? []);
    
    // Responsive layout: Row on desktop, Wrap on mobile
    return LayoutBuilder(
      builder: (context, constraints) {
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: metrics.map((m) {
            return Container(
              width: constraints.maxWidth > 600 ? (constraints.maxWidth - 48) / 3 : (constraints.maxWidth - 16) / 2,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  Icon(_getIcon(m['icon']), color: const Color(0xFFFFD700), size: 32),
                  const SizedBox(height: 12),
                  Text(
                    m['value'] ?? '0',
                    style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (m['label'] ?? '').toUpperCase(),
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white54, letterSpacing: 1),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      }
    );
  }

  IconData _getIcon(String? iconName) {
    switch(iconName) {
      case 'users': return Icons.people_outline;
      case 'eye': return Icons.visibility_outlined;
      case 'heart': return Icons.favorite_border;
      case 'camera': return Icons.camera_alt_outlined;
      case 'click': return Icons.ads_click;
      default: return Icons.analytics_outlined;
    }
  }
}

// --- 3. BRAND LOGOS ---
class BrandLogosBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const BrandLogosBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final brands = (data['brands'] as List<dynamic>? ?? []);
    
    return MediaKitBlockWrapper(
      child: Column(
        children: [
          Text(
            (data['title'] ?? 'TRUSTED BY').toUpperCase(),
            style: GoogleFonts.montserrat(fontSize: 14, color: Colors.white54, letterSpacing: 2),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: brands.map((b) => Chip(
              label: Text(b.toString(), style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              side: BorderSide.none,
              padding: const EdgeInsets.all(12),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

// --- 4. ABOUT SECTION ---
class AboutSectionBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const AboutSectionBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return MediaKitBlockWrapper(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data['title'] ?? 'ABOUT ME').toUpperCase(),
                  style: GoogleFonts.bebasNeue(fontSize: 32, color: const Color(0xFFFFD700)),
                ),
                const SizedBox(height: 16),
                Text(
                  data['content'] ?? '',
                  style: GoogleFonts.inter(fontSize: 16, color: Colors.white70, height: 1.6),
                ),
              ],
            ),
          ),
          if (data['highlight'] != null) ...[
            const SizedBox(width: 32),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: const Color(0xFFFFD700), width: 4)),
                  color: Colors.white.withValues(alpha: 0.02),
                ),
                child: Text(
                  "\"${data['highlight']}\"",
                  style: GoogleFonts.sora(fontSize: 20, fontStyle: FontStyle.italic, color: Colors.white),
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}

// --- 5. PRICING TABLE ---
class PricingTableBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const PricingTableBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final packages = (data['packages'] as List<dynamic>? ?? []);

    return Column(
      children: [
        Text(
          (data['title'] ?? 'SERVICES').toUpperCase(),
          style: GoogleFonts.bebasNeue(fontSize: 40, color: Colors.white),
        ),
        const SizedBox(height: 32),
        LayoutBuilder(
          builder: (context, constraints) {
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: packages.map((p) {
                final features = (p['features'] as List<dynamic>? ?? []);
                return Container(
                  width: constraints.maxWidth > 800 ? 300 : double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.05), blurRadius: 40, spreadRadius: 0)
                    ]
                  ),
                  child: Column(
                    children: [
                      Text(p['name'] ?? '', style: GoogleFonts.montserrat(fontSize: 18, color: Colors.white70)),
                      const SizedBox(height: 16),
                      Text(p['price'] ?? '', style: GoogleFonts.sora(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 24),
                      Divider(color: Colors.white10),
                      const SizedBox(height: 24),
                      ...features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(children: [
                          Icon(Icons.check, color: const Color(0xFFFFD700), size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(f.toString(), style: const TextStyle(color: Colors.white70))),
                        ]),
                      )),
                      const SizedBox(height: 32),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFFD700),
                          side: const BorderSide(color: Color(0xFFFFD700)),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                        child: const Text("SELECT"),
                      )
                    ],
                  ),
                );
              }).toList(),
            );
          }
        ),
      ],
    );
  }
}

// --- 6. CONTACT SECTION ---
class ContactSectionBlock extends StatelessWidget {
  final Map<String, dynamic> data;
  const ContactSectionBlock({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Text(
              data['email'] ?? '',
              style: GoogleFonts.sora(fontSize: 24, color: Colors.white),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              child: Text(
                (data['ctaText'] ?? 'CONTACT').toUpperCase(),
                style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
