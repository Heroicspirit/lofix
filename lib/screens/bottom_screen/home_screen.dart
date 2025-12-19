import 'package:flutter/material.dart';
import 'package:musicapp/widgets/section_header.dart';
import 'package:musicapp/widgets/horizontal_music_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  final List<Map<String, String>> topPicks = const [
    {
      "image": "assets/images/image1.jpg",
      "title": "Cosmic Echoes",
      "artist": "Astral Wave"
    },
    {
      "image": "assets/images/image2.jpg",
      "title": "Forest Whispers",
      "artist": "Willow Creek"
    },
  ];

  final List<Map<String, String>> newReleases = const [
    {
      "image": "assets/images/image3.jpg",
      "title": "Future Soundscapes",
      "artist": "Synthoria"
    },
    {
      "image": "assets/images/image4.jpg",
      "title": "Geometric Harmonies",
      "artist": "Polygon Pop"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Home",
          style: TextStyle(color: Colors.black),
        ),
        leading: const Icon(Icons.music_note, color: Colors.black),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Spotify-like scroll
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: "Top Picks for You"),
            HorizontalMusicList(data: topPicks),

            SectionHeader(title: "New Releases"),
            HorizontalMusicList(data: newReleases),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
