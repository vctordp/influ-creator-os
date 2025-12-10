import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/auth_service.dart';
import '../../features/gamification/services/gamification_service.dart';
import '../../features/gamification/widgets/gamification_widgets.dart';
import '../../features/notifications/widgets/notification_widgets.dart';
import '../../features/visual_audit/visual_audit_screen.dart';

// ============================================
// DASHBOARD V2 SCREEN
// ============================================

class DashboardScreenV2 extends StatefulWidget {
  const DashboardScreenV2({super.key});

  @override
  State<DashboardScreenV2> createState() => _DashboardScreenV2State();
}

class _DashboardScreenV2State extends State<DashboardScreenV2> {
  String _selectedTab = 'overview'; // overview, pipeline, deals, mediakit, analytics
  final Color _acidGreen = const Color(0xFFCCFF00);

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final userName = auth.userName;
    final followers = auth.userFollowers;
    // final revenue = auth.potentialRevenue; // Unused

    return Scaffold(
      backgroundColor: Colors.black,
      body: Row(
        children: [
          // SIDEBAR (Desktop)
          if (MediaQuery.of(context).size.width > 800)
            _buildSidebar(),

          // MAIN CONTENT
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DashboardHeader(
                    userName: userName,
                    totalFollowers: followers,
                    followerGrowth: 12, // Still mock or need explicit field
                    showMenu: MediaQuery.of(context).size.width <= 800,
                    onMenuTap: () => _openDrawer(context),
                  ),
                  
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width <= 800 ? _buildDrawer() : null,
    );
  }

  void _openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF0F0F11),
      child: _buildSidebar(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: const Color(0xFF0F0F11), // Dark sidebar bg
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LOGO
          Row(
            children: [
              Icon(Icons.all_inclusive, color: Colors.blueAccent[700], size: 28), // Placeholder Logo
              const SizedBox(width: 12),
              Text("UNICO", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
            ],
          ),
          const SizedBox(height: 48),

          // NAV ITEMS
          _buildNavItem("Visão Geral", "overview", Icons.grid_view),
          _buildNavItem("Pipeline", "pipeline", Icons.view_kanban_outlined),
          _buildNavItem("Negócios & CRM", "deals", Icons.handshake_outlined),
          _buildNavItem("Mídia Kit", "mediakit", Icons.collections_bookmark_outlined),
          _buildNavItem("Analytics", "analytics", Icons.bar_chart),
        ],
      ),
    );
  }

  Widget _buildNavItem(String label, String id, IconData icon) {
    final isSelected = _selectedTab == id;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = id);
        if (MediaQuery.of(context).size.width <= 800) Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F1F22) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.sora(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'overview':
        return _buildOverviewTab();
      case 'pipeline':
        return _buildPipelineTab();
      case 'deals':
        return _buildDealsTab();
      case 'mediakit':
        return _buildMediaKitTab();
      case 'analytics':
        return _buildAnalyticsTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    return Column(
      children: [
        // Gamification Dashboard (Top)
        const GamificationDashboard(),
        const SizedBox(height: 32),

        // Metric Cards Grid
        LayoutBuilder(builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(width: isDesktop ? (constraints.maxWidth - 48)/4 : (constraints.maxWidth - 16)/2, child: 
                MetricCard(title: "Receita Total", value: "\$${Provider.of<AuthService>(context).potentialRevenue.toStringAsFixed(0)}", growth: 24, icon: Icons.attach_money, color: Colors.lime)),
              
              SizedBox(width: isDesktop ? (constraints.maxWidth - 48)/4 : (constraints.maxWidth - 16)/2, child: 
                const MetricCard(title: "Engajamento", value: "8.5%", growth: 5, icon: Icons.trending_up, color: Colors.blue)),
              
              SizedBox(width: isDesktop ? (constraints.maxWidth - 48)/4 : (constraints.maxWidth - 16)/2, child: 
                const MetricCard(title: "Conteúdo Viral", value: "3", unit: "posts", growth: -2, icon: Icons.bolt, color: Colors.purple)),
              
              SizedBox(width: isDesktop ? (constraints.maxWidth - 48)/4 : (constraints.maxWidth - 16)/2, child: 
                const MetricCard(title: "Oportunidades", value: "7", unit: "abertas", growth: 15, icon: Icons.ads_click, color: Colors.pink)),
            ],
          );
        }),

        const SizedBox(height: 24),

        // Quick Actions
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: "Nova Ideia",
                description: "Crie um rascunho rápido para seu conteúdo",
                icon: Icons.lightbulb_outline,
                onTap: () {},
                isPrimary: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: QuickActionCard(
                title: "Analisar Conteúdo",
                description: "Use IA para auditar seu último post",
                icon: Icons.analytics_outlined,
                onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const VisualAuditScreen()));
                },
                isPrimary: false,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Financial & Trends Row
        LayoutBuilder(builder: (context, constraints) {
           return constraints.maxWidth > 800 
           ? Row(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Expanded(child: _buildFinancialSummary()),
               const SizedBox(width: 24),
               Expanded(child: _buildViralTrends()),
             ],
           )
           : Column(
             children: [
               _buildFinancialSummary(),
               const SizedBox(height: 16),
               _buildViralTrends(),
             ],
           );
        })
      ],
    );
  }
  
  Widget _buildPipelineTab() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
          Text("Pipeline de Negócios", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 24),
          Text("Deals em Aberto", style: GoogleFonts.sora(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          const DealCard(title: "Parceria YouTube", status: "Aberto", value: 5000, date: "15 de Dez", color: Colors.blue),
          const SizedBox(height: 8),
          const DealCard(title: "Sponsorship TikTok", status: "Aberto", value: 3000, date: "20 de Dez", color: Colors.blue),
       ],
     );
  }

  Widget _buildDealsTab() {
    return Center(child: Text("CRM Completo em Breve", style: GoogleFonts.sora(color: Colors.white54)));
  }

  Widget _buildMediaKitTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Seu Mídia Kit", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            OutlinedButton.icon(
              onPressed: () {}, 
              icon: const Icon(Icons.share, size: 16), 
              label: const Text("Compartilhar"),
              style: OutlinedButton.styleFrom(foregroundColor: _acidGreen, side: BorderSide(color: _acidGreen)),
            )
          ],
        ),
        const SizedBox(height: 32),
        // MOCK MEDIA KIT PREVIEW
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
               // Header
               Row(
                 children: [
                   const CircleAvatar(radius: 40, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white, size: 40)),
                   const SizedBox(width: 24),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text("João Creator", style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                       Text("@joaocreator • Tech & Lifestyle", style: GoogleFonts.sora(fontSize: 16, color: Colors.grey[600])),
                     ],
                   )
                 ],
               ),
               const SizedBox(height: 48),
               // Stats
               Row(
                 mainAxisAlignment: MainAxisAlignment.spaceAround,
                 children: [
                   _buildMediaKitStat("45.2K", "Seguidores"),
                   _buildMediaKitStat("8.5%", "Engajamento"),
                   _buildMediaKitStat("120K", "Alcance Mensal"),
                 ],
               ),
               const SizedBox(height: 48),
               // About
               Text(
                 "Criador focado em trazer as últimas novidades de tecnologia e estilo de vida para uma audiência engajada e curiosa.",
                 textAlign: TextAlign.center,
                 style: GoogleFonts.sora(fontSize: 18, color: Colors.black87, height: 1.5),
               ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMediaKitStat(String value, String label) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.bebasNeue(fontSize: 48, color: Colors.black)),
        Text(label, style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600], letterSpacing: 1)),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return Container(
      padding: const EdgeInsets.all(48),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Text("Gráficos e analytics detalhados virão em breve", style: GoogleFonts.sora(color: Colors.white54)),
    );
  }

  Widget _buildFinancialSummary() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Resumo Financeiro", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildFinancialRow("Receita Mensal", "\$${Provider.of<AuthService>(context).potentialRevenue.toStringAsFixed(0)}", _acidGreen),
          _buildFinancialRow("Comissões Pendentes", "\$2,340", Colors.white70),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text("Próximo Pagamento", style: GoogleFonts.sora(color: Colors.white54)),
                 Text("15 de Dezembro", style: GoogleFonts.sora(color: Colors.white30, fontSize: 12)),
              ],
            ),
          )
        ],
      )
    );
  }
  
  Widget _buildFinancialRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.sora(color: Colors.white54)),
          Text(value, style: GoogleFonts.sora(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildViralTrends() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Tendências Virais", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildTrendRow("#AICreators", "↑ 45%"),
          _buildTrendRow("#ContentMarketing", "↑ 32%"),
          _buildTrendRow("#CreatorEconomy", "↑ 28%"),
        ],
      ),
    );
  }

  Widget _buildTrendRow(String tag, String growth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tag, style: GoogleFonts.sora(color: _acidGreen, fontWeight: FontWeight.w600)),
          Text(growth, style: GoogleFonts.sora(color: Colors.greenAccent, fontSize: 12)),
        ],
      ),
    );
  }
}

// ============================================
// COMPONENTS
// ============================================

class _DashboardHeader extends StatelessWidget {
  final String userName;
  final int totalFollowers;
  final int followerGrowth;
  final bool showMenu;
  final VoidCallback? onMenuTap;

  const _DashboardHeader({required this.userName, required this.totalFollowers, required this.followerGrowth, this.showMenu = false, this.onMenuTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.grey[900]!, Colors.black],
        ),
        border: const Border(bottom: BorderSide(color: Colors.white12)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (showMenu) IconButton(onPressed: onMenuTap, icon: const Icon(Icons.menu, color: Colors.white)),
                    if (showMenu) const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Bem-vindo de volta, $userName!", style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text("Aqui está seu resumo de hoje", style: GoogleFonts.sora(color: Colors.white54)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10), 
                      decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(12)), 
                      child: const NotificationBell()
                    ),
                    const SizedBox(width: 12),
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFCCFF00), Color(0xFFAACC00)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.person, color: Colors.black, size: 20)),
                  ],
                )
              ],
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFFCCFF00).withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Crescimento de Seguidores", style: GoogleFonts.sora(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text("45,230", style: GoogleFonts.sora(fontSize: 40, fontWeight: FontWeight.bold, color: const Color(0xFFCCFF00))),
                      const SizedBox(width: 12),
                      Text("+$followerGrowth%", style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFFCCFF00))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Comparado à semana anterior", style: GoogleFonts.sora(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? unit;
  final int growth;
  final IconData icon;
  final MaterialColor color;

  const MetricCard({super.key, required this.title, required this.value, required this.growth, required this.icon, required this.color, this.unit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                 padding: const EdgeInsets.all(12),
                 decoration: BoxDecoration(
                   color: color.withOpacity(0.1),
                   borderRadius: BorderRadius.circular(12),
                   border: Border.all(color: color.withOpacity(0.3)),
                 ),
                 child: Icon(icon, color: color[400], size: 20),
               ),
               Text(
                 growth >= 0 ? "+$growth%" : "$growth%",
                 style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: growth >= 0 ? const Color(0xFFCCFF00) : Colors.redAccent, fontSize: 12),
               )
             ],
           ),
           const SizedBox(height: 16),
           Text(title, style: GoogleFonts.sora(color: Colors.white54, fontSize: 12)),
           const SizedBox(height: 4),
           Row(
             crossAxisAlignment: CrossAxisAlignment.baseline,
             textBaseline: TextBaseline.alphabetic,
             children: [
               Text(value, style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
               if (unit != null) ...[const SizedBox(width: 4), Text(unit!, style: GoogleFonts.sora(color: Colors.white30, fontSize: 12))],
             ],
           )
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const QuickActionCard({super.key, required this.title, required this.description, required this.icon, required this.onTap, this.isPrimary = true});

  @override
  Widget build(BuildContext context) {
    final acidGreen = const Color(0xFFCCFF00);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isPrimary ? acidGreen.withOpacity(0.05) : const Color(0xFF111827).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isPrimary ? acidGreen.withOpacity(0.3) : Colors.white12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.sora(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                const SizedBox(height: 4),
                Text(description, style: GoogleFonts.sora(color: Colors.white54, fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPrimary ? acidGreen.withOpacity(0.2) : Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isPrimary ? acidGreen : Colors.white54),
            )
          ],
        ),
      ),
    );
  }
}

class DealCard extends StatelessWidget {
  final String title;
  final String status;
  final int value;
  final String date;
  final Color color;

  const DealCard({super.key, required this.title, required this.status, required this.value, required this.date, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111827).withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.sora(fontWeight: FontWeight.w600, color: Colors.white)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), 
                child: Text(status.toUpperCase(), style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.bold, color: color))),
            ],
          ),
          const SizedBox(height: 8),
          Text("\$$value", style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFCCFF00))),
          Text(date, style: GoogleFonts.sora(color: Colors.white30, fontSize: 10)),
        ],
      )
    );
  }
}
