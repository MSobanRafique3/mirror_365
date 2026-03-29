import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

part 'user_profile_model.g.dart';

@HiveType(typeId: HiveTypeIds.userProfile)
class UserProfileModel extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? intention; // user's primary intention/why

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final bool onboardingComplete;

  @HiveField(5)
  final int totalDays; // days since app start

  @HiveField(6)
  final int currentStreak;

  @HiveField(7)
  final int longestStreak;

  @HiveField(8)
  final DateTime? lastActiveDate;

  const UserProfileModel({
    required this.id,
    required this.name,
    this.intention,
    required this.createdAt,
    this.onboardingComplete = false,
    this.totalDays = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActiveDate,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? intention,
    DateTime? createdAt,
    bool? onboardingComplete,
    int? totalDays,
    int? currentStreak,
    int? longestStreak,
    DateTime? lastActiveDate,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      intention: intention ?? this.intention,
      createdAt: createdAt ?? this.createdAt,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      totalDays: totalDays ?? this.totalDays,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        intention,
        createdAt,
        onboardingComplete,
        totalDays,
        currentStreak,
        longestStreak,
        lastActiveDate,
      ];
}
