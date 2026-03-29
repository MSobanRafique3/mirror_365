import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/models.dart';

class DaySquare extends StatelessWidget {
  final DayRecordModel record;

  const DaySquare({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    Color color;
    if (record.dayRecordId.startsWith('missing_')) {
      // Future or blank
      color = AppColors.surfaceVariant;
    } else if (record.isFailed) {
      // Exact 0.0 completion
      color = AppColors.error;
    } else if (record.isPure) {
      // Exact 1.0 completion
      color = AppColors.primary;
    } else {
      // Partial completion
      color = AppColors.primaryLight; // Gold light, distinct from pure
    }

    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: color,
      ),
    );
  }
}
