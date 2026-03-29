import 'package:flutter/material.dart';

class GoalDetailPage extends StatelessWidget {
  final String goalId;

  const GoalDetailPage({super.key, required this.goalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Goal Detail: $goalId',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
