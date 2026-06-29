import 'package:flutter/material.dart';
import '../../app_theme.dart';

class SplashView extends StatelessWidget {
  final Widget nextScreen;

  const SplashView({super.key, required this.nextScreen});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
