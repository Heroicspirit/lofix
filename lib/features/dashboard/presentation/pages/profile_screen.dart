import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart'; // FIXES THE ERROR
import 'package:musicapp/core/services/storage/user_session_service.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _localImage;

  // --- Permission Handling ---
  Future<void> _checkPermissionAndPick(ImageSource source) async {
    PermissionStatus status;
    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // For Gallery
      status = Platform.isAndroid 
          ? await Permission.storage.request() 
          : await Permission.photos.request();
    }

    if (status.isGranted) {
      _pickImage(source);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Please enable it in settings.")),
      );
    }
  }

  // --- Image Picking ---
  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
      preferredCameraDevice: CameraDevice.front,
    );
    
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _localImage = imageFile;
      });

      // Upload via the ViewModel you provided
      await ref.read(authViewModelProvider.notifier).uploadPhoto(imageFile);
    }
  }

  // --- Bottom Sheet UI ---
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _checkPermissionAndPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Navigator.pop(context);
                _checkPermissionAndPick(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userSession = ref.watch(userSessionServiceProvider);
    final userName = userSession.getUsername() ?? 'User';
    final userEmail = userSession.getUserEmail() ?? 'No Email';
    final profileImageUrl = userSession.getUserProfileImage();

    // Logic: Local preview > Remote image > Initial placeholder
    ImageProvider? imageToShow;
    if (_localImage != null) {
      imageToShow = FileImage(_localImage!);
    } else if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
      // NOTE: Change 10.0.2.2 to your specific backend IP if needed
      imageToShow = NetworkImage('http://10.0.2.2:5000/public/uploads/$profileImageUrl');
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 40),
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: imageToShow,
                  child: imageToShow == null 
                      ? Text(userName[0].toUpperCase(), style: const TextStyle(fontSize: 40)) 
                      : null,
                ),
                IconButton(
                  onPressed: _showPickerOptions,
                  icon: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(userEmail),
          ],
        ),
      ),
    );
  }
}