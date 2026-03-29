import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/repositories/monthly_confession_repository.dart';
import '../bloc/confession_bloc.dart';

class MonthlyConfessionScreen extends StatelessWidget {
  const MonthlyConfessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConfessionBloc(
        confessionRepo: getIt<MonthlyConfessionRepository>(),
        timeService: getIt<JourneyTimeService>(),
      )..add(const ConfessionLoadRequested()),
      child: const _ConfessionView(),
    );
  }
}

class _ConfessionView extends StatefulWidget {
  const _ConfessionView();

  @override
  State<_ConfessionView> createState() => _ConfessionViewState();
}

class _ConfessionViewState extends State<_ConfessionView> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MONTHLY CONFESSION', style: TextStyle(color: AppColors.primary, letterSpacing: 2.0)),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: BlocConsumer<ConfessionBloc, ConfessionState>(
        listenWhen: (p, c) => p.errorMessage != c.errorMessage && c.errorMessage != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!, style: const TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state.isLocked) {
            return const _LockedStateView();
          }

          if (state.requiredMonthNumber == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'NOTHING TO CONFESS.\nTHE MIRROR WAITS FOR THE MONTH TO END.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    letterSpacing: 2.0,
                    fontSize: AppFontSize.md,
                  ),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'MONTH ${state.requiredMonthNumber} IS OVER.',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSize.xl,
                    fontWeight: AppFontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Write your reflection. Tell the truth. Explain why you failed, or what it took to succeed. You will never see this again until Day 365.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: AppSpacing.xl),
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(color: AppColors.textPrimary, height: 1.5),
                    decoration: InputDecoration(
                      hintText: 'I failed to run because I was weak...',
                      hintStyle: const TextStyle(color: AppColors.textDisabled),
                      filled: true,
                      fillColor: AppColors.surfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.zero,
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.md),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                GestureDetector(
                  onTap: () {
                    context.read<ConfessionBloc>().add(ConfessionSubmitted(_ctrl.text));
                  },
                  child: Container(
                    height: 56,
                    color: AppColors.primary,
                    alignment: Alignment.center,
                    child: const Text(
                      'LOCK IT',
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: AppFontSize.md,
                        letterSpacing: 2.0,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LockedStateView extends StatelessWidget {
  const _LockedStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.lock, color: AppColors.textDisabled, size: 64),
          SizedBox(height: AppSpacing.xl),
          Text(
            'CONFESSION LOCKED\nSEE YOU AT DAY 365',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primary,
              letterSpacing: 3.0,
              fontSize: AppFontSize.lg,
              fontWeight: AppFontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
