import 'package:flutter/material.dart';
import 'package:musicapp/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {

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
            onPressed: () {
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