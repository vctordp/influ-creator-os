import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/gamification_models.dart';
import '../services/gamification_service.dart';

// ============================================
// 1. Onboarding Tour
// ============================================
class OnboardingTour extends StatelessWidget {
  const OnboardingTour({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<GamificationService>();
    final progress = service.progress;
    
    // Only show if not fully completed (e.g., first 5 steps)
    if (progress.completedSteps.length >= kOnboardingSteps.length) {
       return const SizedBox.shrink(); // Hide if done
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFCCFF00).withOpacity(0.1), Colors.black]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.rocket_launch, color: Color(0xFFCCFF00)),
              const SizedBox(width: 12),
              Text("PRIMEIROS PASSOS", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
              const Spacer(),
              Text("${progress.completedSteps.length}/${kOnboardingSteps.length} Completos", style: GoogleFonts.sora(color: Colors.white54, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          // Horizontal Scroll for steps
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: kOnboardingSteps.map((step) {
                final isCompleted = progress.completedSteps.contains(step.id);
                // Highlight next step
                final isNext = !isCompleted && !progress.completedSteps.contains(step.id) && 
                   (kOnboardingSteps.indexOf(step) == 0 || progress.completedSteps.contains(kOnboardingSteps[kOnboardingSteps.indexOf(step)-1].id));
                
                return _buildStepCard(context, step, isCompleted, isNext);
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStepCard(BuildContext context, OnboardingStep step, bool isCompleted, bool isNext) {
    final color = isCompleted ? const Color(0xFFCCFF00) : (isNext ? Colors.white : Colors.white24);
    
    return GestureDetector(
      onTap: () {
        if (!isCompleted) {
          // In real app, navigate. For gamification demo, complete it.
          context.read<GamificationService>().completeOnboardingStep(step.id);
        }
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted ? const Color(0xFFCCFF00).withOpacity(0.1) : Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isCompleted || isNext ? color.withOpacity(0.5) : Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Icon(isCompleted ? Icons.check_circle : step.icon, color: color, size: 24),
             const SizedBox(height: 12),
             Text(step.title, style: GoogleFonts.sora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
             const SizedBox(height: 4),
             Text(step.description, style: GoogleFonts.sora(color: Colors.white54, fontSize: 10)),
             const SizedBox(height: 12),
             if (!isCompleted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isNext ? const Color(0xFFCCFF00) : Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  step.actionLabel, 
                  style: GoogleFonts.sora(
                    color: isNext ? Colors.black : Colors.white38, 
                    fontSize: 10, fontWeight: FontWeight.bold
                  )
                ),
              )
          ],
        ),
      ).animate(target: isNext ? 1 : 0).shimmer(duration: 2.seconds),
    );
  }
}

// ============================================
// 2. Achievement Badges
// ============================================
class AchievementBadges extends StatelessWidget {
  const AchievementBadges({super.key});

  @override
  Widget build(BuildContext context) {
    final achievements = context.watch<GamificationService>().achievements;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("CONQUISTAS", style: GoogleFonts.bebasNeue(fontSize: 24, color: Colors.white)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust for mobile
            childAspectRatio: 0.8,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: achievements.length,
          itemBuilder: (ctx, index) {
            final ach = achievements[index];
            return _buildBadge(ach);
          },
        ),
      ],
    );
  }

  Widget _buildBadge(Achievement ach) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ach.unlocked ? ach.gradient.last.withOpacity(0.5) : Colors.transparent),
        gradient: ach.unlocked ? LinearGradient(colors: ach.gradient.map((c) => c.withOpacity(0.2)).toList(), begin: Alignment.topLeft, end: Alignment.bottomRight) : null
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: ach.unlocked ? ach.gradient : [Colors.grey, Colors.grey.shade800]),
            ),
            child: Icon(ach.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 8),
          Text(ach.title, textAlign: TextAlign.center, style: GoogleFonts.sora(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          if (!ach.unlocked)
             Padding(
               padding: const EdgeInsets.only(top: 4),
               child: Icon(Icons.lock, size: 12, color: Colors.white24),
             )
        ],
      ),
    );
  }
}

// ============================================
// 3. XP Progress Bar
// ============================================
class XPProgressBar extends StatelessWidget {
  const XPProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<GamificationService>().progress;
    
    // Find next milestone
    final currentLevelMilestone = kXPMilestones.firstWhere((m) => m.level == progress.currentLevel, orElse: () => kXPMilestones.first);
    final nextMilestone = kXPMilestones.firstWhere((m) => m.level > progress.currentLevel, orElse: () => kXPMilestones.last);
    
    final int currentLevelXP = currentLevelMilestone.requiredXP;
    final int nextLevelXP = nextMilestone.requiredXP;
    
    // Calculate percentage within level
    final double range = (nextLevelXP - currentLevelXP).toDouble();
    final double current = (progress.currentXP - currentLevelXP).toDouble();
    final double percent = (range == 0) ? 1.0 : (current / range).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(16)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("NÍVEL ${progress.currentLevel}", style: GoogleFonts.bebasNeue(fontSize: 20, color: const Color(0xFFCCFF00))),
              Text("${progress.currentXP} / $nextLevelXP XP", style: GoogleFonts.sora(fontSize: 12, color: Colors.white54)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.white10,
            color: const Color(0xFFCCFF00),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 8),
          Text("Próximo: ${nextMilestone.reward}", style: GoogleFonts.sora(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }
}

// ============================================
// 4. Full Dashboard Widget
// ============================================
class GamificationDashboard extends StatelessWidget {
  const GamificationDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        OnboardingTour(),
        SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: XPProgressBar()),
            SizedBox(width: 16),
            Expanded(child: AchievementBadges()),
          ],
        )
      ],
    );
  }
}
