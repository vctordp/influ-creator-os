import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brand_deal.dart';

class BrandDealService {
  final _supabase = Supabase.instance.client;

  Future<List<BrandDeal>> fetchDeals() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return [];

    final response = await _supabase
        .from('brand_deals')
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    return (response as List).map((e) => BrandDeal.fromJson(e)).toList();
  }

  Future<void> createDeal({
    required String brandName,
    String? contactEmail,
    double value = 0.0,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    await _supabase.from('brand_deals').insert({
      'user_id': uid,
      'brand_name': brandName,
      'contact_email': contactEmail,
      'value': value,
      'status': 'prospecting',
    });
  }

  Future<void> updateStatus(String dealId, String newStatus) async {
    await _supabase.from('brand_deals').update({
      'status': newStatus,
    }).eq('id', dealId);
  }

  Future<void> queueEmail({
    required String dealId,
    required String recipientEmail,
    required String subject,
    required String body,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    await _supabase.from('email_queue').insert({
      'user_id': uid,
      'deal_id': dealId,
      'recipient_email': recipientEmail,
      'subject': subject,
      'body_html': body,
      'status': 'pending',
      'scheduled_for': DateTime.now().toIso8601String(), // Send immediately (handled by cron)
    });
    
    // Auto-move deal to 'contract_sent' or 'negotiation' if prospecting?
    updateStatus(dealId, 'negotiation');
  }

  Future<double> calculatePipelineValue() async {
    final deals = await fetchDeals();
    // Sum value of deals in 'negotiation', 'contract_sent', 'active'
    // Exclude 'prospecting' (too early) and 'lost'
    // 'completed' is already earned, maybe count it differently?
    // Let's count 'negotiation' + 'active' + 'contract_sent' as "Pipeline".
    
    double total = 0;
    for (var deal in deals) {
      if (['negotiation', 'contract_sent', 'active'].contains(deal.status)) {
        total += deal.value;
      }
    }
    return total;
  }
}
