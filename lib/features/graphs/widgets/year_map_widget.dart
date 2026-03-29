import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/models.dart';

class YearMapWidget extends StatelessWidget {
  final List<DayRecordModel> yearMapDays;

  const YearMapWidget({super.key, required this.yearMapDays});

  @override
  Widget build(BuildContext context) {
    // 12 months, 30 days per month.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'YEAR MAP',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: AppFontSize.lg,
            letterSpacing: 2.0,
            fontWeight: AppFontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(12, (mIndex) {
              final rowMonth = mIndex + 1;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        'M$rowMonth',
                        style: const TextStyle(
                          color: AppColors.textDisabled,
                          fontSize: 10,
                          fontWeight: AppFontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(30, (dIndex) {
                        final colDay = dIndex + 1;
                        final targetJourneyDay = (mIndex * 30) + colDay;

                        // Find record if it exists
                        final record = yearMapDays.cast<DayRecordModel?>().firstWhere(
                              (r) => r?.journeyDay == targetJourneyDay,
                              orElse: () => null,
                            );

                        Color fill = AppColors.surfaceVariant;
                        Color border = AppColors.divider;
                        
                        if (record != null) {
                          if (record.isPure) {
                            fill = AppColors.primary;
                            border = AppColors.primary;
                          } else if (record.overallCompletionRate > 0.5) {
                            fill = Colors.yellow.shade800;
                            border = Colors.yellow.shade800;
                          } else {
                            fill = AppColors.error;
                            border = AppColors.error;
                          }
                        }

                        return GestureDetector(
                          onTap: record == null
                              ? null
                              : () {
                                  _showDayDetailsPopup(context, record);
                                },
                          child: Container(
                            width: 14,
                            height: 14,
                            margin: const EdgeInsets.only(right: 2.0),
                            decoration: BoxDecoration(
                              color: fill,
                              border: Border.all(color: border, width: 0.5),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  void _showDayDetailsPopup(BuildContext context, DayRecordModel record) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        title: Text(
          'DAY ${record.journeyDay}',
          style: const TextStyle(color: AppColors.primary, letterSpacing: 2.0),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('COMPLETION: ${(record.overallCompletionRate * 100).toStringAsFixed(0)}%', style: const TextStyle(color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            Text('STATUS: ${record.isPure ? "PURE" : record.isFailed ? "FAILED" : "PARTIAL"}', style: TextStyle(color: record.isPure ? AppColors.primary : AppColors.error)),
          ],
        ),
      ),
    );
  }
}
