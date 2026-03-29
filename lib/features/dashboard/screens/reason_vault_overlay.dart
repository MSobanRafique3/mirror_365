import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../../../core/constants/app_constants.dart';

class ReasonVaultOverlay extends StatefulWidget {
  const ReasonVaultOverlay({super.key});

  @override
  State<ReasonVaultOverlay> createState() => _ReasonVaultOverlayState();
}

class _ReasonVaultOverlayState extends State<ReasonVaultOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final Animation<double> _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);

  bool _canDismiss = false;

  @override
  void initState() {
    super.initState();
    // Start animation and 5 second timer only when widget builds and overlay is visible.
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _runSequence() async {
    _fadeCtrl.forward();
    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      setState(() {
        _canDismiss = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listenWhen: (prev, curr) => !prev.showReasonVault && curr.showReasonVault,
      listener: (context, state) {
        if (state.showReasonVault) {
           _runSequence();
        }
      },
      // Also run if it started true
      builder: (context, state) {
        if (!state.showReasonVault) return const SizedBox.shrink();

        // If it mounted true initially, start sequence if not running
        if (!_fadeCtrl.isAnimating && _fadeCtrl.value == 0 && !_canDismiss) {
           WidgetsBinding.instance.addPostFrameCallback((_) {
             if (mounted) _runSequence();
           });
        }

        final bool failedAll = state.totalActiveGoalsYesterday > 0 && 
                              (state.yesterdayFailedGoalNames.length == state.totalActiveGoalsYesterday);
        
        final String headerText = failedAll 
            ? 'YESTERDAY YOU\nCHOSE NOTHING.' 
            : 'YOU FAILED\nYESTERDAY.';

        final failedGoals = state.yesterdayFailedGoalNames;
        final reasonText = state.originalReasonText ?? 'No Reason Vault recorded.';

        return Positioned.fill(
          child: Container(
            color: Colors.black, // Pure black overlay
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xxl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    Text(
                      headerText,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: AppFontSize.xl,
                        fontWeight: AppFontWeight.extraBold,
                        letterSpacing: 2.0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    
                    if (failedGoals.isNotEmpty && !failedAll) ...[
                      const Text(
                        'YESTERDAY YOU FAILED:',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSize.sm,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ...failedGoals.map((g) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Text(
                          '— ${g.toUpperCase()}',
                          style: const TextStyle(color: AppColors.textPrimary, letterSpacing: 1.0),
                        ),
                      )),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    FadeTransition(
                      opacity: _fadeAnim,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: AppColors.primary.withOpacity(0.5), width: 2)),
                          color: AppColors.surface.withOpacity(0.3),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'YOUR REASON VAULT (DAY 0):',
                              style: TextStyle(color: AppColors.primary, fontSize: 10, letterSpacing: 2.0),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              reasonText,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: AppFontSize.md,
                                height: 1.6,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const Spacer(flex: 2),
                    
                    if (_canDismiss)
                      GestureDetector(
                        onTap: () {
                          context.read<DashboardBloc>().add(const DashboardReasonVaultDismissed());
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 18.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'I REMEMBER WHY I STARTED',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: AppFontSize.md,
                              fontWeight: AppFontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 58), // spacer for button
                      
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
