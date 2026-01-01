//stless
import 'package:flutter/material.dart';
import 'package:musicapp/features/splash/presentation/pages/splash_screen.dart';
import 'package:musicapp/app/theme/theme.dart';


class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: getApplicationTheme(),
      home:SplashScreen(),
    );
  }
}