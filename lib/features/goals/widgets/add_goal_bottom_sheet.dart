import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/journey_time_service.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

class AddGoalBottomSheet extends StatefulWidget {
  final GoalCategory initialCategory;

  const AddGoalBottomSheet({
    super.key,
    this.initialCategory = GoalCategory.daily,
  });

  @override
  State<AddGoalBottomSheet> createState() => _AddGoalBottomSheetState();
}

class _AddGoalBottomSheetState extends State<AddGoalBottomSheet> {
  late GoalCategory _category;
  final _titleCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _category = widget.initialCategory;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ADD NEW GOAL',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSize.lg,
                    letterSpacing: 1.5,
                    fontWeight: AppFontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textDisabled),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            
            // Category Selector
            Wrap(
              spacing: AppSpacing.sm,
              children: GoalCategory.values.map((cat) {
                final isSelected = _category == cat;
                return ChoiceChip(
                  label: Text(
                    cat.name.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? AppColors.background : AppColors.textSecondary,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primary,
                  backgroundColor: AppColors.surfaceVariant,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  onSelected: (val) {
                    if (val) setState(() => _category = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),

            TextField(
              controller: _titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'TITLE',
                labelStyle: TextStyle(color: AppColors.textDisabled, letterSpacing: 1.0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            
            TextField(
              controller: _targetCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'TARGET (e.g. 1 session)',
                labelStyle: TextStyle(color: AppColors.textDisabled, letterSpacing: 1.0),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.divider)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary)),
              ),
            ),
            
            // Brutal Warning Text
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.lg),
              child: Text(
                'Once added, this goal is permanent. You cannot remove it.',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: AppFontSize.xs,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.error, fontSize: AppFontSize.sm),
                ),
              ),

            const SizedBox(height: AppSpacing.xl),
            GestureDetector(
              onTap: _isLoading ? null : () async {
                final title = _titleCtrl.text.trim();
                final target = _targetCtrl.text.trim();

                if (title.length < 3 || title.length > 40) {
                  setState(() => _errorMessage = 'Title must be 3-40 characters.');
                  return;
                }
                if (target.length < 3 || target.length > 30) {
                  setState(() => _errorMessage = 'Target must be 3-30 characters.');
                  return;
                }

                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });

                try {
                  final goalRepo = getIt<JourneyGoalRepository>();
                  final timeService = getIt<JourneyTimeService>();
                  
                  final existing = goalRepo.getAllGoals();
                  if (existing.any((g) => g.title.toLowerCase() == title.toLowerCase())) {
                    throw Exception("A goal with this exact title already exists.");
                  }

                  final nowMs = DateTime.now().millisecondsSinceEpoch;
                  final currentDay = timeService.currentJourneyDay(nowMs);

                  await goalRepo.addGoal(
                    title: title,
                    description: '',
                    category: _category,
                    addedOnDay: currentDay,
                    targetValue: target,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (mounted) {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = e.toString().replaceFirst('Exception: ', '');
                    });
                  }
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                color: _isLoading ? AppColors.surfaceVariant : AppColors.primary,
                alignment: Alignment.center,
                child: _isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                  : const Text(
                      'ADD GOAL',
                      style: TextStyle(
                        color: AppColors.background,
                        letterSpacing: 1.5,
                        fontWeight: AppFontWeight.bold,
                      ),
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      );
  }
}
