//stless
import 'package:flutter/material.dart';
import 'package:musicapp/screens/splash_screen.dart';
import 'package:musicapp/theme/theme.dart';


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