import 'package:flutter/material.dart';
import 'package:flutter_complete_project/src/imports/core_imports.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
  await Future.delayed(const Duration(seconds: 2));

  if (!mounted) return;
  context.go(AppRoutes.home);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("HI"),
      ),
    );
  }
}