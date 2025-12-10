import 'package:flutter/material.dart';

class LocalizationService extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void toggleLanguage() {
    _locale = _locale.languageCode == 'en' ? const Locale('pt') : const Locale('en');
    notifyListeners();
  }

  String getString(String key) {
    return _localizedValues[_locale.languageCode]?[key] ?? key;
  }

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'MY MANAGER.AI',
      'welcome': 'Welcome',
      'tokens_ready': 'Your 6 Golden Tokens are ready.',
      'business_center': 'YOUR BUSINESS\nCOMMAND CENTER',
      'token_1_title': 'TOKEN 1: VISUAL AUDIT',
      'token_1_desc': 'Is your feed aesthetic enough?',
      'token_2_title': 'TOKEN 2: MONEY CALCULATOR',
      'token_2_desc': 'Are you leaving money on the table?',
      'token_3_title': 'TOKEN 3: LEGAL SHIELD',
      'token_3_desc': 'Scan contracts for traps.',
      'token_4_title': 'TOKEN 4: THE HUNTER',
      'token_4_desc': 'Generate sponsorship pitches instantly.',
      'token_5_title': 'TOKEN 5: INSTANT MEDIA KIT',
      'token_5_desc': 'Create your VIP Business Card.',
      'token_6_title': 'TOKEN 6: VIRAL WRITER',
      'token_6_desc': 'Generate 3 scripts for any topic.',
      'login_title': 'AGENCY ACCESS',
      'login_btn': 'ENTER THE AGENCY',
      'email_label': 'Email Access',
      'password_label': 'Secure Key (Password)',
      'analyzing': 'ANALYZING VISUALS...',
      'analyze_btn': 'ANALYZE ARGENT AESTHETICS',
      'scan_btn': 'SCAN FOR RED FLAGS 🚩',
      'generate_pitch_btn': 'GENERATE PITCH',
      'generate_card_btn': 'GENERATE VIP CARD',
      'generate_scripts_btn': 'GENERATE SCRIPTS',
    },
    'pt': {
      'app_title': 'MY MANAGER.AI',
      'welcome': 'Bem-vindo',
      'tokens_ready': 'Seus 6 Tokens Dourados estão prontos.',
      'business_center': 'SEU CENTRO DE\nCOMANDO',
      'token_1_title': 'TOKEN 1: AUDITORIA VISUAL',
      'token_1_desc': 'Seu feed é estético o suficiente?',
      'token_2_title': 'TOKEN 2: CALCULADORA DE \$: ',
      'token_2_desc': 'Você está deixando dinheiro na mesa?',
      'token_3_title': 'TOKEN 3: ESCUDO LEGAL',
      'token_3_desc': 'Escaneie contratos por armadilhas.',
      'token_4_title': 'TOKEN 4: O CAÇADOR',
      'token_4_desc': 'Gere pitches de patrocínio instantaneamente.',
      'token_5_title': 'TOKEN 5: MÍDIA KIT INSTANTÂNEO',
      'token_5_desc': 'Crie seu Cartão de Negócios VIP.',
      'token_6_title': 'TOKEN 6: ROTEIRISTA VIRAL',
      'token_6_desc': 'Gere 3 roteiros para qualquer tópico.',
      'login_title': 'ACESSO À AGÊNCIA',
      'login_btn': 'ENTRAR NA AGÊNCIA',
      'email_label': 'Email de Acesso',
      'password_label': 'Chave Segura (Senha)',
      'analyzing': 'ANALISANDO VISUAIS...',
      'analyze_btn': 'ANALISAR ESTÉTICA',
      'scan_btn': 'ESCANEAR BANDEIRAS VERMELHAS 🚩',
      'generate_pitch_btn': 'GERAR PITCH',
      'generate_card_btn': 'GERAR CARTÃO VIP',
      'generate_scripts_btn': 'GERAR ROTEIROS',
    },
  };
}
