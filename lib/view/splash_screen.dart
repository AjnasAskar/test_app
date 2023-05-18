import 'package:firebase_auths/view/home_screen.dart';
import 'package:firebase_auths/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'authentication/auth_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Text(
          'Ecommerce',
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  @override
  void initState() {
    navigateFromSplash();
    super.initState();
  }

  Future<void> navigateFromSplash() async {
    await Future.delayed(const Duration(seconds: 2));
    if (context.mounted) {
      context.read<AuthViewModel>().validateUserLoginStat().then((value) {
        if (value != null) {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (route) => false);
        } else {
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const AuthScreen()),
              (route) => false);
        }
      });
    }
  }
}
