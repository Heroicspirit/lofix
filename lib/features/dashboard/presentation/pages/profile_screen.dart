import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _localImage;

  // --- Permission Handling (Gallery Fix) ---
  Future<void> _checkPermissionAndPick(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // Android 13+ logic
      status = Platform.isAndroid 
          ? await Permission.photos.request() 
          : await Permission.photos.request();
      
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    if (status.isGranted) {
      _pickImage(source);
    } else {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Denied"),
        content: const Text("We need access to your gallery to update your profile picture."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(onPressed: () => openAppSettings(), child: const Text("Settings")),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() => _localImage = imageFile);
      await ref.read(authViewModelProvider.notifier).uploadPhoto(imageFile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);
    final userName = userSession.getUsername() ?? 'User';
    final userEmail = userSession.getUserEmail() ?? 'No Email';
    final profileImageUrl = userSession.getUserProfileImage();

    ImageProvider? imageToShow;
    if (_localImage != null) {
      imageToShow = FileImage(_localImage!);
    } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      imageToShow = NetworkImage('http://192.168.1.74:5000/public/profile_pictures/$profileImageUrl');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Account"),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => ref.read(authViewModelProvider.notifier).logout(),
            icon: const Icon(Icons.logout, color: Colors.red),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- Profile Header ---
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent.withOpacity(0.1),
                    backgroundImage: imageToShow,
                    child: imageToShow == null 
                        ? Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 40)) 
                        : null,
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Theme.of(context).primaryColor,
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      onPressed: () => _showPickerOptions(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(userEmail, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),

            // --- Settings Sections ---
            _buildSectionTitle("Account Settings"),
            _buildSettingsItem(Icons.person_outline, "Edit Profile", () {}),
            _buildSettingsItem(Icons.lock_outline, "Change Password", () {}),
            
            const Divider(),
            _buildSectionTitle("Preferences"),
            _buildSettingsItem(Icons.dark_mode_outlined, "Dark Mode", () {}, 
                trailing: Switch(value: false, onChanged: (v) {})),
            _buildSettingsItem(Icons.notifications_none, "Notifications", () {}),
            
            const Divider(),
            _buildSectionTitle("More"),
            _buildSettingsItem(Icons.help_outline, "Help & Support", () {}),
            _buildSettingsItem(Icons.info_outline, "About App", () {}),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.camera_alt), title: const Text('Camera'), onTap: () { Navigator.pop(context); _checkPermissionAndPick(ImageSource.camera); }),
            ListTile(leading: const Icon(Icons.photo_library), title: const Text('Gallery'), onTap: () { Navigator.pop(context); _checkPermissionAndPick(ImageSource.gallery); }),
          ],
        ),
      ),
    );
  }
}