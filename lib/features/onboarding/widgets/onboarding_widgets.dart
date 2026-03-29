import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';

/// Gold primary button used across all onboarding screens.
class OnboardingPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OnboardingPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.35,
      duration: AppDuration.normal,
      child: GestureDetector(
        onTap: enabled ? onPressed : null,
        child: Container(
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            color: enabled ? AppColors.primary : AppColors.surfaceVariant,
            border: Border.all(
              color: enabled ? AppColors.primary : AppColors.divider,
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: AppColors.background,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.background,
                    fontSize: AppFontSize.lg,
                    fontWeight: AppFontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
        ),
      ),
    );
  }
}

/// Outlined secondary button.
class OnboardingSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const OnboardingSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSize.md,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

/// Thin gold horizontal rule with optional label.
class OnboardingDivider extends StatelessWidget {
  final String? label;
  const OnboardingDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(height: 1, color: AppColors.divider);
    }
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label!,
            style: const TextStyle(
              color: AppColors.textDisabled,
              fontSize: AppFontSize.xs,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.divider)),
      ],
    );
  }
}

/// Reusable goal input card for all three category screens.
class GoalInputCard extends StatefulWidget {
  final int index;
  final String categoryLabel; // e.g. "YEARLY GOAL"
  final String initialTitle;
  final String initialDescription;
  final String initialTarget;
  final void Function(String title, String desc, String target) onChanged;

  const GoalInputCard({
    super.key,
    required this.index,
    required this.categoryLabel,
    required this.onChanged,
    this.initialTitle = '',
    this.initialDescription = '',
    this.initialTarget = '',
  });

  @override
  State<GoalInputCard> createState() => _GoalInputCardState();
}

class _GoalInputCardState extends State<GoalInputCard>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _targetCtrl;
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.initialTitle);
    _descCtrl = TextEditingController(text: widget.initialDescription);
    _targetCtrl = TextEditingController(text: widget.initialTarget);

    _animController = AnimationController(
      vsync: this,
      duration: AppDuration.slow,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
    _animController.forward();

    _titleCtrl.addListener(_notify);
    _descCtrl.addListener(_notify);
    _targetCtrl.addListener(_notify);
  }

  void _notify() {
    widget.onChanged(
        _titleCtrl.text, _descCtrl.text, _targetCtrl.text);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Container(
              width: double.infinity,
              color: AppColors.surfaceVariant,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Text(
                '${widget.categoryLabel} ${widget.index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: AppFontSize.xs,
                  fontWeight: AppFontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildField(_titleCtrl, 'TITLE', 1),
                  const SizedBox(height: AppSpacing.sm),
                  _buildField(_descCtrl, 'DESCRIPTION', 3),
                  const SizedBox(height: AppSpacing.sm),
                  _buildField(_targetCtrl, 'TARGET (e.g. "5 times")', 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      TextEditingController ctrl, String hint, int maxLines) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: AppFontSize.md,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textDisabled,
          fontSize: AppFontSize.sm,
          letterSpacing: 1.0,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
          borderRadius: BorderRadius.zero,
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.divider),
          borderRadius: BorderRadius.zero,
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1),
          borderRadius: BorderRadius.zero,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
      ),
      cursorColor: AppColors.primary,
    );
  }
}

/// Screen scaffold used by all onboarding screens — no back button.
class OnboardingScaffold extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const OnboardingScaffold({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.xxl,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
