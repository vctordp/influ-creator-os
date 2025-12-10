import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/login_screen.dart';
import 'widgets/pricing_section_v2.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Dark Mode Professional
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHero(context),
            _buildBentoTeaser(context),
            _buildValueProp(context),
            _buildValueProp(context),
            const PricingSectionV2(), // Added Pricing Section V2
            _buildFinalCTA(context),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    return Container(
      height: 900, // Full viewport height ideally, but fixed for scroll
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        image: DecorationImage(
          image: const NetworkImage("https://grainy-gradients.vercel.app/noise.svg"), // Subtle noise if available, else ignored
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.9), BlendMode.darken),
        ),
      ),
      child: Stack(
        children: [
          // Ambient Glows
          Positioned(top: -100, left: -100, child: _buildGlow(const Color(0xFFCCFF00))), // Acid Green
          Positioned(bottom: -100, right: -100, child: _buildGlow(const Color(0xFF9D00FF))), // Electric Purple

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Text("CREATOR OS", style: GoogleFonts.montserrat(color: const Color(0xFFCCFF00), letterSpacing: 4, fontWeight: FontWeight.bold, fontSize: 14)),
                  Image.asset(
                    'assets/images/logo_full.png', // Logo Full
                    height: 80,
                    fit: BoxFit.contain,
                  ).animate().fadeIn().slideY(begin: -0.2),
                  const SizedBox(height: 24),
                  // Removed redundant "Stop Guessing" title if logo has text, or keep as slogan?
                  // Keeping slogan as it's the value prop
                  Text(
                    "Stop Guessing.\nStart Scaling.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.bebasNeue(
                      fontSize: 72, 
                      height: 0.9,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn().slideY(begin: 0.3, end: 0),
                  const SizedBox(height: 24),
                  Text(
                    "The all-in-one operating system for high-performance influencers.\nManage deals, audit content, and generate scripts in seconds.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 18, 
                      color: Colors.white70,
                      height: 1.5
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPrimaryButton(context, "Get Started Free", () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }),
                      const SizedBox(width: 24),
                      _buildGhostButton(context, "Login", () {
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                      }),
                    ],
                  ).animate().fadeIn(delay: 400.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color) {
    return Container(
      width: 400,
      height: 400,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.15),
        // boxFilter: null, // Removed invalid param
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 150, spreadRadius: 50)],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, String text, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCCFF00), // Acid Green
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)), // Sharp edges
        elevation: 0,
      ),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildGhostButton(BuildContext context, String text, VoidCallback onTap) {
    return OutlinedButton(
      onPressed: onTap,
       style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white24),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),
      child: Text(text, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildBentoTeaser(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: const Color(0xFF1E1E1E),
      child: Column(
        children: [
          Text("YOUR NEW COMMAND CENTER", style: GoogleFonts.montserrat(color: Colors.white54, letterSpacing: 2)),
          const SizedBox(height: 40),
          // Simple visualization of Bento Grid
          Wrap(
            spacing: 20,
            runSpacing: 20,
            alignment: WrapAlignment.center,
            children: [
              _buildBentoCard(width: 300, height: 300, color: Colors.purple.shade900, title: "Viral Hub", icon: Icons.trending_up),
              Column(
                children: [
                   _buildBentoCard(width: 300, height: 140, color: Colors.blueGrey.shade800, title: "Revenue", icon: Icons.attach_money),
                   const SizedBox(height: 20),
                   _buildBentoCard(width: 300, height: 140, color: Colors.teal.shade900, title: "Pipeline", icon: Icons.view_kanban),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBentoCard({required double width, required double height, required Color color, required String title, required IconData icon}) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        border: Border.all(color: Colors.white10),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          Text(title, style: GoogleFonts.bebasNeue(color: Colors.white, fontSize: 24)),
        ],
      ),
    );
  }

  Widget _buildValueProp(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Wrap(
        spacing: 40,
        runSpacing: 40,
        alignment: WrapAlignment.center,
        children: [
          _buildPropItem("Organize Production", "Never lose a script idea again. Track every video from concept to posted."),
          _buildPropItem("Maximize Deals", "CRM built for creators. Manage brands, generate cold emails, and track revenue."),
          _buildPropItem("Track Growth", "AI-powered audits for your profile visuals and viral trends."),
        ],
      ),
    );
  }

  Widget _buildPropItem(String title, String desc) {
    return SizedBox(
      width: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 2, width: 40, color: const Color(0xFFCCFF00)),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.bebasNeue(fontSize: 32, color: Colors.white)),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildFinalCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF9D00FF).withOpacity(0.2), Colors.black],
        )
      ),
      child: Column(
        children: [
          Text("Ready to go pro?", style: GoogleFonts.bebasNeue(fontSize: 56, color: Colors.white)),
          const SizedBox(height: 32),
          _buildPrimaryButton(context, "Join the Club", () {
             Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          }),
        ],
      ),
    );
  }

  // Pricing logic moved to PricingSectionV2

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.black,
      child: Center(child: Text("© 2025 UNICO Soluções Tecnológicas", style: GoogleFonts.montserrat(color: Colors.white24, fontSize: 12))),
    );
  }
}
