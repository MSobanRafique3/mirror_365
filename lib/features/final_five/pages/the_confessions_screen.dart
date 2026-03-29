import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/final_five_bloc.dart';

class TheConfessionsScreen extends StatelessWidget {
  const TheConfessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalFiveBloc, FinalFiveState>(
      builder: (context, state) {
        final confessions = state.confessions;

        return GestureDetector(
          onVerticalDragEnd: (details) {
            if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
              context.read<FinalFiveBloc>().add(const FinalFiveScreenDismissed());
            }
          },
          child: Container(
            color: Colors.transparent,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xxl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: AppSpacing.xxl),
                        Text(
                          'YOU WROTE THESE.\nYOU CANNOT HIDE FROM THEM.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: AppFontSize.lg,
                            letterSpacing: 4.0,
                            fontWeight: AppFontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                
                if (confessions.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Text('NO CONFESSIONS RECORDED.', style: TextStyle(color: AppColors.textDisabled, letterSpacing: 2.0)),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final c = confessions[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.md),
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MONTH ${c.monthNumber} CONFESSION',
                                style: const TextStyle(color: AppColors.primary, fontSize: AppFontSize.xs, letterSpacing: 2.0, fontWeight: AppFontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'WRITTEN ${DateTime.fromMillisecondsSinceEpoch(c.writtenAt).toString().substring(0, 10)}',
                                style: const TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 1.0),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Text(
                                c.content,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: AppFontSize.sm,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      childCount: confessions.length,
                    ),
                  ),
                
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xxl),
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.xl),
                        Icon(Icons.keyboard_arrow_up, color: AppColors.textDisabled, size: 32),
                        SizedBox(height: 8),
                        Text(
                          'SWIPE UP TO ACCEPT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textDisabled,
                            letterSpacing: 2.0,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
