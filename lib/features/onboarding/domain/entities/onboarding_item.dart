import 'package:flutter/material.dart';

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<Color> gradientColors;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradientColors,
  });
}
