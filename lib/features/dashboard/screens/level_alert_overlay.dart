import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/level_service.dart';

class LevelAlertOverlay extends StatefulWidget {
  const LevelAlertOverlay({super.key});

  @override
  State<LevelAlertOverlay> createState() => _LevelAlertOverlayState();
}

class _LevelAlertOverlayState extends State<LevelAlertOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  late final Animation<double> _fade = Tween<double>(begin: 0.0, end: 1.0).animate(
    CurvedAnimation(parent: _ctrl, curve: Curves.easeIn),
  );

  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    final res = getIt<LevelService>().lastEvaluationResult;
    if (res != null && (res['leveledUp'] == true || res['droppedLevel'] == true)) {
      _ctrl.forward();
    } else {
      _isDismissed = true;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final res = getIt<LevelService>().lastEvaluationResult!;
    final bool isUp = res['leveledUp'] == true;
    final int newLevel = res['newLevel'] as int;
    final String? dropReason = res['reason'] as String?;

    return Positioned.fill(
      child: FadeTransition(
        opacity: _fade,
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isUp ? 'LEVEL GAINED' : 'LEVEL LOST',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isUp ? AppColors.primary : AppColors.error,
                  fontSize: AppFontSize.xl,
                  letterSpacing: 8.0,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                'RANK $newLevel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 64,
                  letterSpacing: 4.0,
                  fontWeight: AppFontWeight.bold,
                ),
              ),
              if (!isUp && dropReason != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  dropReason,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: AppFontSize.md,
                    height: 1.5,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _isDismissed = true),
                child: Container(
                  height: 60,
                  color: AppColors.surfaceVariant,
                  alignment: Alignment.center,
                  child: const Text(
                    'ACKNOWLEDGE',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      letterSpacing: 3.0,
                      fontWeight: AppFontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
