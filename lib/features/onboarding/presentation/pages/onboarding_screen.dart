import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {

  final PageController swipeController  = PageController();
  int currentIndex =0;

  final List<Map<String,String>> pages = [
    {"title": "Welcome to Lofix", "desc": "Stream your favorite music anytime, anywhere"},
    {"title": "Search your favourite", "desc": "and enjoy"},
    {"title": "Get Started", "desc": "Login to explore endless music"},
  ];

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Skip button at the top
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 50, right: 20),
              child: TextButton(
                onPressed: () async {
                  // Mark onboarding as completed even when skipping
                  await ref.read(userSessionServiceProvider).completeOnboarding();
                  
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: swipeController,
            itemCount: pages.length,
            onPageChanged: (index){
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mobile_friendly,size: 120),
                  const SizedBox(height: 20),
                  Text(
                    pages[index]['title']!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(pages[index]['desc']!),
                ],
              );
            },
            ),
            ),
            Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => Container(
                margin: const EdgeInsets.all(5),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: currentIndex == index ? Colors.black : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          currentIndex == pages.length-1
          ? ElevatedButton(
            onPressed: () async {
              // Much cleaner!
              await ref.read(userSessionServiceProvider).completeOnboarding();
              
              print('=== DEBUG: Onboarding Completion ===');
              print('After completion: isOnboardingCompleted = ${ref.read(userSessionServiceProvider).isOnboardingCompleted()}');
              
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }, 
            child: const Text("Get Started"),
            )
            :TextButton(
              onPressed: () {
                swipeController.nextPage(duration: const Duration(milliseconds: 200), 
                curve: Curves.easeIn,
                );
              }, 
              child: const Text("Next"),
              ),
              const SizedBox(height: 30),
        ],
      ),
    );
  }
}