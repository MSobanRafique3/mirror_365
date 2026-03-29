import 'package:uuid/uuid.dart';
import '../local/hive_database.dart';
import '../models/models.dart';

class UserProfileRepository {
  final _uuid = const Uuid();

  UserProfileModel? getProfile() {
    final box = HiveDatabase.userProfileBox;
    if (box.isEmpty) return null;
    return box.values.first;
  }

  Future<UserProfileModel> createProfile({
    required String name,
    String? intention,
  }) async {
    final profile = UserProfileModel(
      id: _uuid.v4(),
      name: name,
      intention: intention,
      createdAt: DateTime.now(),
    );
    await HiveDatabase.userProfileBox.put(profile.id, profile);
    return profile;
  }

  Future<void> updateProfile(UserProfileModel profile) async {
    await HiveDatabase.userProfileBox.put(profile.id, profile);
  }

  Future<void> completeOnboarding(String profileId) async {
    final profile = getProfile();
    if (profile == null) return;
    await updateProfile(profile.copyWith(onboardingComplete: true));
  }

  Future<void> updateStreak() async {
    final profile = getProfile();
    if (profile == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastActive = profile.lastActiveDate;

    int newStreak = profile.currentStreak;

    if (lastActive == null) {
      newStreak = 1;
    } else {
      final lastDay = DateTime(
          lastActive.year, lastActive.month, lastActive.day);
      final diff = today.difference(lastDay).inDays;
      if (diff == 1) {
        newStreak = profile.currentStreak + 1;
      } else if (diff > 1) {
        newStreak = 1;
      }
      // diff == 0 means already updated today, keep same
    }

    await updateProfile(profile.copyWith(
      currentStreak: newStreak,
      longestStreak: newStreak > profile.longestStreak
          ? newStreak
          : profile.longestStreak,
      lastActiveDate: now,
      totalDays: today.difference(profile.createdAt).inDays,
    ));
  }

  bool get isOnboardingComplete => getProfile()?.onboardingComplete ?? false;
}
