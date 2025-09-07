import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

const Color finBuddyLime = Color(0xFFC4E03B);
const Color finBuddyBlue = Color(0xFF3A86E0);
const Color finBuddyDark = Color(0xFF212121);

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _opacity = 1);

      Timer(const Duration(seconds: 4), () {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: finBuddyLime,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.calculate_rounded,
                size: 100.0,
                color: finBuddyDark,
              ),
              const SizedBox(height: 24),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _opacity,
                child: const Text(
                  'Fin_Buddy',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: finBuddyDark,
                  ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'From DevSphere v0.5.0_beta',
                  style: TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 14,
                    // ignore: deprecated_member_use
                    color: finBuddyDark.withOpacity(0.75),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
