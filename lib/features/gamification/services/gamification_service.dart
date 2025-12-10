import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/gamification_models.dart';

class GamificationService extends ChangeNotifier {
  // Remove persistent client field to debug build
  
  UserProgress _progress = const UserProgress();
  List<Achievement> _achievements = kBaseAchievements;
  
  UserProgress get progress => _progress;
  List<Achievement> get achievements => _achievements;

  GamificationService() {
    _init();
  }

  Future<void> _init() async {
    // Just listen to auth changes directly
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        fetchAll();
      } else {
        _progress = const UserProgress();
        notifyListeners();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      await fetchAll();
    }
  }

  Future<void> fetchAll() async {
    try {
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid == null) return;

      // Fetch Progress
      try {
        final data = await client.from('user_progress').select().eq('user_id', uid).maybeSingle();
        if (data != null) {
          _progress = UserProgress.fromMap(data);
        } else {
          // Default state
           _progress = const UserProgress();
           // Attempt insert
           try {
             await client.from('user_progress').insert({'user_id': uid});
           } catch (_) {}
        }
      } catch (e) {
        if (kDebugMode) print("Gamification Table Error: \$e");
      }

      // Fetch Achievements
      try {
        final List<dynamic> data = await client.from('user_achievements').select().eq('user_id', uid);
        List<Achievement> updated = [];
        
        for (var base in kBaseAchievements) {
          final match = data.firstWhere(
            (element) => element['achievement_id'] == base.id, 
            orElse: () => null
          );
          
          if (match != null) {
            updated.add(base.copyWith(
              unlocked: match['unlocked'] ?? false,
              progress: (match['progress'] as num?)?.toInt() ?? 0,
            ));
          } else {
            updated.add(base);
          }
        }
        _achievements = updated;
      } catch (e) {
          if (kDebugMode) print("Gamification Achievement Error: \$e");
      }

      _notify();

    } catch (e) {
        if (kDebugMode) print("Gamification Service Error: \$e");
    }
  }

  Future<void> completeOnboardingStep(String stepId) async {
    // Optimistic Update
    List<String> newCompleted = List.from(_progress.completedSteps);
    if (!newCompleted.contains(stepId)) {
      newCompleted.add(stepId);
      final newStepIndex = newCompleted.length;
      
      _progress = UserProgress(
        currentXP: _progress.currentXP + 10,
        currentLevel: _progress.currentLevel,
        onboardingStep: newStepIndex,
        completedSteps: newCompleted,
      );
      _notify();
      
      final client = Supabase.instance.client;
      final uid = client.auth.currentUser?.id;
      if (uid != null) {
          try {
             await client.from('user_progress').upsert({
               'user_id': uid,
               'completed_steps': newCompleted,
               'onboarding_step': newStepIndex,
               'current_xp': _progress.currentXP, 
             });
             await client.from('user_activities').insert({
               'user_id': uid,
               'activity_type': 'onboarding_\$stepId',
               'xp_earned': 10
             });
          } catch (_) {}
      }
    }
  }

  Future<void> addXP(int amount) async {
    int newXP = _progress.currentXP + amount;
    
    // Check Level Up
    int newLevel = _progress.currentLevel;
    for (var m in kXPMilestones) {
      if (newXP >= m.requiredXP && m.level > newLevel) {
        newLevel = m.level;
      }
    }

    _progress = UserProgress(
      currentXP: newXP,
      currentLevel: newLevel,
      onboardingStep: _progress.onboardingStep,
      completedSteps: _progress.completedSteps,
    );
    _notify();

    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid != null) {
        try {
          await client.from('user_progress').update({
            'current_xp': newXP,
            'current_level': newLevel
          }).eq('user_id', uid);
        } catch (_) {}
    }
  }

  void _notify() {
    notifyListeners();
  }
}
