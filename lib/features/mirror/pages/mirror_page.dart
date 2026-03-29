import 'package:flutter/material.dart';

class MirrorPage extends StatelessWidget {
  const MirrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Mirror',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
