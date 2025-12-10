import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/services/auth_service.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final _supabase = Supabase.instance.client;
  String _filter = 'All'; // 'All', 'pitch', 'script'

  Stream<List<Map<String, dynamic>>> _getStream(String userId) {
    var query = _supabase
        .from('generated_content')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    
    // Note: Client-side filtering for stream acts differently, 
    // but for simple list, we can filter the stream results in the builder 
    // or apply filters if Supabase stream supports complex filters (limitation).
    // For simplicity with Stream, we'll fetch all and filter in memory, 
    // assuming < 1000 items for now.
    return query;
  }

  IconData _getIcon(String type) {
    if (type == 'pitch') return Icons.rocket_launch;
    if (type == 'script') return Icons.movie_creation;
    return Icons.article;
  }

  Color _getColor(String type) {
    if (type == 'pitch') return Colors.blueAccent;
    if (type == 'script') return Colors.purpleAccent;
    return Colors.grey;
  }
                      
  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthService>().currentUser?.id;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("THE VAULT", style: GoogleFonts.bebasNeue(fontSize: 28, letterSpacing: 2)),
        backgroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterBar(),
        ),
      ),
      body: userId == null
          ? const Center(child: Text("Please login to view vault"))
          : StreamBuilder<List<Map<String, dynamic>>>(
              stream: _getStream(userId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var data = snapshot.data!;

                // Client-side Filter
                if (_filter != 'All') {
                  data = data.where((item) => item['content_type'] == _filter).toList();
                }

                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
                        const SizedBox(height: 16),
                        Text("Your vault is empty.", style: GoogleFonts.montserrat(color: Colors.white54)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    final createdAt = DateTime.parse(item['created_at']).toLocal();
                    final dateStr = DateFormat('MMM d, y • h:mm a').format(createdAt);
                    
                    return _buildVaultCard(item, dateStr, index);
                  },
                );
              },
            ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildFilterChip('All'),
          const SizedBox(width: 12),
          _buildFilterChip('pitch', label: 'Pitches'),
          const SizedBox(width: 12),
          _buildFilterChip('script', label: 'Scripts'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, {String? label}) {
    final isSelected = _filter == key;
    return ChoiceChip(
      label: Text(label ?? key),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _filter = key;
        });
      },
      backgroundColor: Colors.white10,
      selectedColor: const Color(0xFFFFD700),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70, 
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildVaultCard(Map<String, dynamic> item, String dateStr, int index) {
    final type = item['content_type'] as String? ?? 'unknown';
    final content = item['content_body'] as String? ?? '';
    final meta = item['meta_data'] as Map<String, dynamic>? ?? {};
    
    String title = "Generated Content";
    if (type == 'pitch') {
      title = "Pitch for \${meta['brand'] ?? 'Unknown Brand'}";
    } else if (type == 'script') {
      title = "Script: \${meta['topic'] ?? 'Unknown Topic'}";
    }

    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Colors.white10)),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getColor(type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getIcon(type), color: _getColor(type)),
        ),
        title: Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(dateStr, style: const TextStyle(color: Colors.white38, fontSize: 12)),
        childrenPadding: const EdgeInsets.all(16),
        collapsedIconColor: Colors.white54,
        iconColor: const Color(0xFFFFD700),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              content,
              style: GoogleFonts.sourceCodePro(color: Colors.white70, fontSize: 13),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: content));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Content copied!")));
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text("COPY TO CLIPBOARD"),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFFFFD700)),
            ),
          )
        ],
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideY(begin: 0.1, end: 0);
  }
}
