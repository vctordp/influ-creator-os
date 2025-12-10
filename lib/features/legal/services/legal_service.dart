import 'package:supabase_flutter/supabase_flutter.dart';

class ContractTemplate {
  final String id;
  final String name;
  final String description;
  final bool isPro;

  ContractTemplate({required this.id, required this.name, required this.description, this.isPro = false});
}

class LegalService {
  final _supabase = Supabase.instance.client;

  Future<List<ContractTemplate>> fetchTemplates() async {
    // In a real scenario, fetch from 'contract_templates' table.
    // For MVP/Prototype, we return hardcoded premium templates.
    await Future.delayed(const Duration(milliseconds: 500));
    
    return [
      ContractTemplate(
        id: '1', 
        name: 'UGC Content Agreement', 
        description: 'Standard rights transfer for User Generated Content.',
        isPro: false
      ),
      ContractTemplate(
        id: '2', 
        name: 'Brand Ambassador Exclusive', 
        description: 'Long-term partnership with exclusivity clauses.',
        isPro: true
      ),
      ContractTemplate(
        id: '3', 
        name: 'Podcast Sponsorship', 
        description: 'Specific terms for audio/video ad reads.',
        isPro: true
      ),
      ContractTemplate(
        id: '4', 
        name: 'NDA (Non-Disclosure)', 
        description: 'Protect your confidential campaign details.',
        isPro: false
      ),
    ];
  }

  Future<void> generateContract({
    required String templateId,
    required String brandName,
    required double value,
    required bool exclusivity,
  }) async {
    // Call Edge Function 'contract_generator'
    // For now, simulate success
    await Future.delayed(const Duration(seconds: 2));
    
    // await _supabase.functions.invoke('contract_generator', body: { ... });
  }
}
