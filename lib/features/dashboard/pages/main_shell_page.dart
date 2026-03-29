import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/services/journey_time_service.dart';
import '../../final_five/pages/final_five_shell.dart';

class MainShellPage extends StatefulWidget {
  final Widget child;

  const MainShellPage({super.key, required this.child});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  bool _showGauntletCut = false;
  bool _isFinalFive = false;
  int _currentDay = 1;

  @override
  void initState() {
    super.initState();
    _checkGauntletState();
  }

  Future<void> _checkGauntletState() async {
    final prefs = getIt<SharedPreferences>();
    final timeService = getIt<JourneyTimeService>();
    final currentDay = timeService.currentJourneyDay();

    if (currentDay >= 361) {
      final hasSeenCut = prefs.getBool('gauntletEntryShownDate') ?? false;
      if (!hasSeenCut) {
        // Show hard cut
        setState(() {
          _showGauntletCut = true;
          _isFinalFive = true;
          _currentDay = currentDay;
        });

        await Future.delayed(const Duration(milliseconds: 1500));
        await prefs.setBool('gauntletEntryShownDate', true);

        if (mounted) {
          setState(() {
            _showGauntletCut = false;
          });
        }
      } else {
        // Already seen, just show Gauntlet
        setState(() {
          _isFinalFive = true;
          _currentDay = currentDay;
        });
      }
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(AppRoutes.dashboard)) return 0;
    if (location.startsWith(AppRoutes.goals)) return 1;
    if (location.startsWith(AppRoutes.graphs)) return 2;
    if (location.startsWith(AppRoutes.levels)) return 3;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        break;
      case 1:
        context.go(AppRoutes.goals);
        break;
      case 2:
        context.go(AppRoutes.graphs);
        break;
      case 3:
        context.go(AppRoutes.levels);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showGauntletCut) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            '5 DAYS REMAIN',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: AppFontSize.xxl,
              fontWeight: AppFontWeight.extraBold,
              letterSpacing: 4.0,
            ),
          ),
        ),
      );
    }

    if (_isFinalFive) {
      // Completely override everything.
      // FinalFiveShell takes over the entire scaffold and bottom nav.
      return FinalFiveShell(currentJourneyDay: _currentDay);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.divider, width: 1.0)),
        ),
        child: BottomNavigationBar(
          backgroundColor: AppColors.background,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textDisabled,
          selectedLabelStyle: const TextStyle(fontWeight: AppFontWeight.bold, fontSize: 10, letterSpacing: 1.5),
          unselectedLabelStyle: const TextStyle(fontWeight: AppFontWeight.regular, fontSize: 10, letterSpacing: 1.0),
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'MIRROR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.track_changes_outlined),
              activeIcon: Icon(Icons.track_changes),
              label: 'GOALS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'DATA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.layers_outlined),
              activeIcon: Icon(Icons.layers),
              label: 'RANKS',
            ),
          ],
        ),
      ),
    );
  }
}
