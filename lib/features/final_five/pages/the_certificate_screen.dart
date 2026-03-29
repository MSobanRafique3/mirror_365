import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../bloc/final_five_bloc.dart';

class TheCertificateScreen extends StatefulWidget {
  const TheCertificateScreen({super.key});

  @override
  State<TheCertificateScreen> createState() => _TheCertificateScreenState();
}

class _TheCertificateScreenState extends State<TheCertificateScreen> {
  final GlobalKey _globalKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareCertificate() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      // Let UI settle before capture
      await Future.delayed(const Duration(milliseconds: 300));
      
      final RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/mirror_365_certificate.png');
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'My Discipline Certificate - Mirror 365');
    } catch (e) {
      debugPrint('Error sharing: $e');
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FinalFiveBloc, FinalFiveState>(
      builder: (context, state) {
        final startDt = DateTime.fromMillisecondsSinceEpoch(state.journeyStartMs);
        final dateStr = DateFormat('MMMM d, yyyy').format(startDt);
        final endDt = DateTime.fromMillisecondsSinceEpoch(state.journeyStartMs + (364 * 86400000));
        final endDateStr = DateFormat('MMMM d, yyyy').format(endDt);

        final levelObj = state.finalLevel;
        final levelNum = levelObj?.currentLevel ?? 1;
        final levelName = levelObj?.levelName.toUpperCase() ?? 'RAW';

        final double goalPct = state.totalGoalsPossible > 0 
           ? (state.totalGoalsCompleted / state.totalGoalsPossible) 
           : 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // The Capturable Certificate Boundary
              RepaintBoundary(
                key: _globalKey,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  padding: const EdgeInsets.all(AppSpacing.xxl),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 30, spreadRadius: 0)
                    ],
                  ),
                  child: Column(
                    children: [
                      Image.asset('assets/images/logo.png', width: 64, height: 64, errorBuilder: (_,__,___) => const Icon(Icons.shield, color: AppColors.primary, size: 64)),
                      const SizedBox(height: AppSpacing.xl),
                      const Text(
                        'MIRROR 365',
                        style: TextStyle(color: AppColors.textPrimary, letterSpacing: 6.0, fontWeight: AppFontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CERTIFICATE OF DISCIPLINE',
                        style: TextStyle(color: AppColors.primary, letterSpacing: 4.0, fontSize: AppFontSize.sm),
                      ),
                      const SizedBox(height: AppSpacing.xxl * 2),
                      
                      Text(
                        '${(state.finalDisciplineScore * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: AppColors.primary, fontSize: 80, fontWeight: AppFontWeight.bold, letterSpacing: 2.0),
                      ),
                      const Text('FINAL SCORE', style: TextStyle(color: AppColors.textDisabled, letterSpacing: 4.0, fontSize: AppFontSize.xs)),
                      const SizedBox(height: AppSpacing.xxl * 2),
                      
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSpacing.xl),
                      
                      _CertStat(label: 'RANK', value: 'LEVEL $levelNum — $levelName'),
                      _CertStat(label: 'TOTAL PURE DAYS', value: '${state.totalPureDays} / 365'),
                      _CertStat(label: 'BEST STREAK', value: '${state.longestPureStreak} CONSECUTIVE PURE DAYS'),
                      _CertStat(label: 'BEST WEEK', value: '${(state.bestWeekAvg * 100).toStringAsFixed(0)}% COMPLETION'),
                      _CertStat(label: 'WORST WEEK', value: '${(state.worstWeekAvg * 100).toStringAsFixed(0)}% COMPLETION'),
                      _CertStat(
                        label: 'GOAL OPERATIONS', 
                        value: '${state.totalGoalsCompleted} / ${state.totalGoalsPossible} (${(goalPct * 100).toStringAsFixed(0)}%)'
                      ),
                      
                      const SizedBox(height: AppSpacing.xl),
                      const Divider(color: AppColors.divider),
                      const SizedBox(height: AppSpacing.xl),
                      
                      Text(
                        'JOURNEY DATES',
                        style: TextStyle(color: AppColors.textDisabled, letterSpacing: 2.0, fontSize: AppFontSize.xs),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$dateStr — $endDateStr',
                        style: const TextStyle(color: AppColors.textSecondary, letterSpacing: 1.0, fontSize: AppFontSize.xs),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl * 2),
              
              // Share button
              GestureDetector(
                onTap: _shareCertificate,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isSharing ? AppColors.surfaceVariant : AppColors.primary,
                  ),
                  alignment: Alignment.center,
                  child: _isSharing 
                    ? const CircularProgressIndicator(color: AppColors.primary)
                    : const Text('SHARE', style: TextStyle(color: Colors.black, fontWeight: AppFontWeight.bold, letterSpacing: 4.0, fontSize: AppFontSize.md)),
                ),
              ),
              
              const SizedBox(height: AppSpacing.xxl),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: Text(
                  'THE MIRROR HAS SHOWN YOU EVERYTHING.\nWHAT YOU DO NEXT IS YOUR CHOICE.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.8,
                    letterSpacing: 2.0,
                    fontSize: AppFontSize.xs,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        );
      },
    );
  }
}

class _CertStat extends StatelessWidget {
  final String label;
  final String value;
  const _CertStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: AppColors.textDisabled, fontSize: 10, letterSpacing: 2.0)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: AppFontSize.md, letterSpacing: 1.0)),
        ],
      ),
    );
  }
}
