import 'package:supabase_flutter/supabase_flutter.dart';

class VisualAuditService {
  final _supabase = Supabase.instance.client;

  Future<void> saveAuditResult({
    required int score,
    required String report,
    String? imageUrl,
  }) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;

    // Use upsert to keep one audit per user (or insert new for history)
    // Assuming 'visual_audits' table exists. If not, this will error, but we try.
    // If it doesn't exist, we might fallback to saving in 'generated_content' with type 'visual_audit'.
    
    try {
      await _supabase.from('visual_audits').upsert({
        'user_id': uid,
        'score': score,
        'report': report,
        'image_url': imageUrl,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Fallback: Save to generated_content if visual_audits fails (table might not exist)
      await _supabase.from('generated_content').insert({
        'user_id': uid,
        'content_type': 'visual_audit',
        'content': report,
        'metadata': {'score': score, 'image_url': imageUrl},
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<int?>  getLatestScore() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return null;

    try {
      // Try fetching from visual_audits first
      final response = await _supabase
          .from('visual_audits')
          .select('score')
          .eq('user_id', uid)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response != null) {
        return response['score'] as int;
      }

      // Fallback: fetch from generated_content
      final fallbackResponse = await _supabase
          .from('generated_content')
          .select('metadata')
          .eq('user_id', uid)
          .eq('content_type', 'visual_audit')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (fallbackResponse != null) {
         final metadata = fallbackResponse['metadata'] as Map<String, dynamic>;
         return metadata['score'] as int?;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}
