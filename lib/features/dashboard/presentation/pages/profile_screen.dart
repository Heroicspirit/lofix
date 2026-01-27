import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Use your defined colors
  final Color primaryGreen = Colors.green;
  final String fontFamily = 'Poppins Regular';

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);
    final userName = userSession.getUsername() ?? 'User';
    final userEmail = userSession.getUserEmail() ?? 'email@example.com';
    final profileImage = userSession.getUserProfileImage();

    // Construct the full URL for the server image
    final displayImage = profileImage != null && profileImage.isNotEmpty
        ? 'http://10.0.2.2:5050/$profileImage'
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // --- Custom Header ---
          _buildProfileHeader(userName, userEmail, displayImage),

          const SizedBox(height: 20),

          // --- Menu Options ---
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildMenuTile(Icons.person_outline, "Account Settings", "Manage your profile"),
                _buildMenuTile(Icons.notifications_none, "Notifications", "Alerts and updates"),
                _buildMenuTile(Icons.security, "Privacy & Security", "Control your data"),
                const Divider(),
                _buildMenuTile(
                  Icons.logout, 
                  "Logout", 
                  "Sign out of your account", 
                  isDestructive: true,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email, String? imageUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Profile Picture with Edit Button
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                  child: imageUrl == null
                      ? Text(name[0].toUpperCase(), 
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: primaryGreen))
                      : null,
                ),
              ),
              // The Camera Trigger
              GestureDetector(
                onTap: _pickMedia, // Uses your existing logic
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt, color: primaryGreen, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            email,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, String subtitle, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : primaryGreen),
      ),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: isDestructive ? Colors.red : Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // TODO: Add your logout logic here
                Navigator.of(context).pop();
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Dummy implementation for picking media (e.g., image picker)
  void _pickMedia() async {
    // TODO: Implement media picking logic here
    // For now, just show a snackbar as a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pick media tapped!')),
    );
  }
}