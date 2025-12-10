import 'package:flutter/material.dart';

class OnboardingStep {
  final String id;
  final String title;
  final String description;
  final String actionLabel;
  final IconData icon;

  const OnboardingStep({
    required this.id,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.icon,
  });
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final bool unlocked;
  final int progress; // 0-100

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    this.unlocked = false,
    this.progress = 0,
  });

  Achievement copyWith({bool? unlocked, int? progress}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      icon: icon,
      gradient: gradient,
      unlocked: unlocked ?? this.unlocked,
      progress: progress ?? this.progress,
    );
  }
}

class UserProgress {
  final int currentXP;
  final int currentLevel;
  final int onboardingStep;
  final List<String> completedSteps;

  const UserProgress({
    this.currentXP = 0,
    this.currentLevel = 1,
    this.onboardingStep = 0,
    this.completedSteps = const [],
  });

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    return UserProgress(
      currentXP: map['current_xp'] ?? 0,
      currentLevel: map['current_level'] ?? 1,
      onboardingStep: map['onboarding_step'] ?? 0,
      completedSteps: List<String>.from(map['completed_steps'] ?? []),
    );
  }
}

class XPMilestone {
  final int level;
  final int requiredXP;
  final String reward;

  const XPMilestone({required this.level, required this.requiredXP, required this.reward});
}

// CONSTANTS

final List<OnboardingStep> kOnboardingSteps = [
  const OnboardingStep(id: 'profile', title: 'Complete seu Perfil', description: 'Adicione foto e nicho.', actionLabel: 'Editar Perfil', icon: Icons.person),
  const OnboardingStep(id: 'first_idea', title: 'Primeira Ideia', description: 'Crie sua primeira ideia de conteúdo.', actionLabel: 'Criar Ideia', icon: Icons.lightbulb),
  const OnboardingStep(id: 'upload_content', title: 'Upload de Conteúdo', description: 'Suba um print ou vídeo.', actionLabel: 'Fazer Upload', icon: Icons.upload_file),
  const OnboardingStep(id: 'connect_social', title: 'Conectar Redes', description: 'Vincule Instagram ou TikTok.', actionLabel: 'Conectar', icon: Icons.share),
  const OnboardingStep(id: 'explore_marketplace', title: 'Explorar Marketplace', description: 'Veja oportunidades disponíveis.', actionLabel: 'Explorar', icon: Icons.store),
];

final List<Achievement> kBaseAchievements = [
  const Achievement(id: 'first_step', title: 'Primeiros Passos', description: 'Complete 3 passos do onboarding', icon: Icons.bolt, gradient: [Colors.yellow, Colors.orange]),
  const Achievement(id: 'idea_master', title: 'Mestre de Ideias', description: 'Crie 10 ideias de conteúdo', icon: Icons.lightbulb_circle, gradient: [Colors.blue, Colors.purple]),
  const Achievement(id: 'viral_creator', title: 'Criador Viral', description: '3 posts com 10k+ engajamento', icon: Icons.trending_up, gradient: [Colors.red, Colors.pink]),
  const Achievement(id: 'deal_maker', title: 'Deal Maker', description: 'Feche sua primeira oportunidade', icon: Icons.handshake, gradient: [Colors.green, Colors.teal]),
  const Achievement(id: 'community_star', title: 'Estrela da Comunidade', description: '100 curtidas na comunidade', icon: Icons.star, gradient: [Colors.orange, Colors.red]),
  const Achievement(id: 'analytics_pro', title: 'Analytics Pro', description: 'Visualize 50 análises', icon: Icons.analytics, gradient: [Colors.purple, Colors.deepPurple]),
];

final List<XPMilestone> kXPMilestones = [
  const XPMilestone(level: 1, requiredXP: 0, reward: 'Acesso Básico'),
  const XPMilestone(level: 2, requiredXP: 100, reward: 'Análise de IA'),
  const XPMilestone(level: 3, requiredXP: 300, reward: 'Marketplace'),
  const XPMilestone(level: 4, requiredXP: 600, reward: 'Comunidade'),
  const XPMilestone(level: 5, requiredXP: 1000, reward: 'Mentoria'),
  const XPMilestone(level: 6, requiredXP: 1500, reward: 'API Access'),
  const XPMilestone(level: 7, requiredXP: 2100, reward: 'White Label'),
  const XPMilestone(level: 8, requiredXP: 2800, reward: 'Status Pro'),
  const XPMilestone(level: 9, requiredXP: 3600, reward: 'Suporte VIP'),
  const XPMilestone(level: 10, requiredXP: 5000, reward: 'Lenda'),
];
