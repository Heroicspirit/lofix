import 'package:flutter/material.dart';
import 'package:musicapp/features/dashboard/presentation/pages/home_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/library_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<DashboardScreen> {

  int _selectedIndex=0;

  List<Widget> lstBottomscreen =[
    const HomeScreen(),
    const SearchScreen(),
    const LibraryScreen(),
    const ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: lstBottomscreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
            label: 'Search'
            ),
            BottomNavigationBarItem(icon: Icon(Icons.library_add),
            label: 'Library'
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person),
            label: 'Profile'
            ),
        ],
        backgroundColor: Colors.amber,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        } ,
      ),
    );
  }
}