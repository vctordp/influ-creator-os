import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/crm/outreach_hub_screen.dart';
import '../../features/vault/vault_screen.dart';
import '../../features/media_kit/media_kit_screen.dart';
import '../../features/analytics/analytics_screen.dart';
import '../../features/settings/settings_screen.dart';
import 'widgets/dashboard_sidebar.dart';
import 'widgets/financial_widget.dart';
import 'widgets/pipeline_widget.dart';
import 'widgets/quick_idea_widget.dart';
import 'widgets/visual_audit_widget.dart';
import 'widgets/viral_hub_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  // Screens for navigation
  final List<Widget> _screens = [
    const _DashboardHome(),
    const VaultScreen(),   // Mapped to "Content Pipeline"
    const OutreachHubScreen(), // Mapped to "CRM"
    const MediaKitScreen(), // Mapped to "Media Kit"
    const AnalyticsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0C0E), // High-End Charcoal
      body: Stack(
        children: [
          // Ambient Mesh Gradient Orb
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1E1B4B).withValues(alpha: 0.3), // Deep Blue/Purple
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
          
          Row(
            children: [
              // Sidebar
              if (isDesktop) 
                DashboardSidebar(
                  selectedIndex: _selectedIndex,
                  onItemSelected: (index) => setState(() => _selectedIndex = index),
                ),
              
              // Main Content
              Expanded(
                child: _selectedIndex == 0 
                  ? const _DashboardHome()
                  : _screens[_selectedIndex],
              ),
            ],
          ),
        ],
      ),
      drawer: !isDesktop 
        ? Drawer(
            child: DashboardSidebar(
              selectedIndex: _selectedIndex,
              onItemSelected: (index) {
                setState(() => _selectedIndex = index);
                Navigator.pop(context);
              },
            ),
          )
        : null,
      appBar: !isDesktop ? AppBar(backgroundColor: const Color(0xFF0B0C0E)) : null,
    );
  }
}

class _DashboardHome extends StatelessWidget {
  const _DashboardHome();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bem-vindo, Criador.", 
            style: GoogleFonts.inter(
              color: const Color(0xFFEDEDED), 
              fontSize: 24, 
              letterSpacing: -0.5, 
              fontWeight: FontWeight.w600
            )
          ),
          const SizedBox(height: 32),
          
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final isWide = width > 800;

              if (isWide) {
                return Column(
                  children: [
                    // Row 1
                    SizedBox(
                      height: 200,
                      child: Row(
                        children: [
                           Expanded(flex: 3, child: FinancialWidget()),
                           const SizedBox(width: 16),
                           Expanded(flex: 2, child: ViralHubWidget()),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Row 2
                    SizedBox(
                      height: 180,
                      child: Row(
                        children: [
                          Expanded(flex: 2, child: PipelineWidget()),
                          const SizedBox(width: 16),
                          Expanded(flex: 2, child: QuickIdeaWidget()),
                          const SizedBox(width: 16),
                          Expanded(flex: 1, child: VisualAuditWidget()),
                        ],
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: const [
                    FinancialWidget(), SizedBox(height: 16),
                    ViralHubWidget(), SizedBox(height: 16),
                    PipelineWidget(), SizedBox(height: 16),
                    QuickIdeaWidget(), SizedBox(height: 16),
                    VisualAuditWidget(),
                  ],
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
