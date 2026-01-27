import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:permission_handler/permission_handler.dart';



class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _localImage;
  final Color primaryGreen = Colors.green;

  // --- Permission Handling ---
  Future<void> _checkPermissionAndPick(ImageSource source) async {
    PermissionStatus status = PermissionStatus.denied;
    
    if (source == ImageSource.camera) {
      status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
    } else {
      // For Gallery - handle both Android and iOS
      if (Platform.isAndroid) {
        // For Android 13+ use READ_MEDIA_IMAGES, for older versions use READ_EXTERNAL_STORAGE
        bool permissionGranted = false;
        
        // First try to get Android 13+ media permissions
        PermissionStatus mediaStatus = await Permission.photos.request();
        if (mediaStatus.isGranted) {
          permissionGranted = true;
        } else if (mediaStatus.isPermanentlyDenied) {
          status = PermissionStatus.permanentlyDenied;
        } else {
          // Fallback to storage permission for older Android versions
          PermissionStatus storageStatus = await Permission.storage.request();
          if (storageStatus.isGranted) {
            permissionGranted = true;
          } else if (storageStatus.isPermanentlyDenied) {
            status = PermissionStatus.permanentlyDenied;
          } else {
            status = PermissionStatus.denied;
          }
        }
        
        if (permissionGranted) {
          status = PermissionStatus.granted;
        }
      } else {
        // For iOS
        status = await Permission.photos.status;
        if (!status.isGranted) {
          status = await Permission.photos.request();
        }
      }
    }

    if (status.isGranted) {
      _pickImage(source);
    } else if (status.isPermanentlyDenied) {
      // If user denied forever, take them to settings
      _showSettingsDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied. Please enable it in settings to use this feature."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text("This app needs camera and photo library access to set your profile picture. Please enable permissions in settings."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text("Open Settings"),
          ),
        ],
      ),
    );
  }

  // --- Image Picking ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
        preferredCameraDevice: CameraDevice.front, // Uses laptop webcam on emulator
      );
      
      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);
        setState(() {
          _localImage = imageFile;
        });

        // Upload via the ViewModel
        await ref.read(authViewModelProvider.notifier).uploadPhoto(imageFile);
        
        // Clear local preview after successful upload to show server image
        setState(() {
          _localImage = null;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      // Clear local preview on error
      setState(() {
        _localImage = null;
      });
    }
  }

  // --- Bottom Sheet UI ---
  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("Profile Photo", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: primaryGreen),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _checkPermissionAndPick(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library, color: primaryGreen),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _checkPermissionAndPick(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 20),
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
      // Updated port to 5000 as per your previous message
      imageToShow = NetworkImage('http://192.168.1.74:5000/public/uploads/$profileImageUrl');
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // --- Header Profile Card ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: Colors.white,
                        backgroundImage: imageToShow,
                        child: imageToShow == null 
                            ? Text(userName[0].toUpperCase(), 
                                style: TextStyle(fontSize: 35, color: primaryGreen, fontWeight: FontWeight.bold)) 
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _showPickerOptions,
                          child: const CircleAvatar(
                            radius: 15,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.edit, color: Colors.green, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userName, 
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(userEmail, 
                          style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // --- Settings Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuTile(Icons.person_outline, "Edit Profile"),
                  _buildMenuTile(Icons.notifications_none, "Notifications"),
                  _buildMenuTile(Icons.lock_outline, "Privacy & Security"),
                  const Divider(height: 40),
                  _buildMenuTile(Icons.help_outline, "Help Support"),
                  _buildMenuTile(Icons.logout, "Logout", isDestructive: true, onTap: () {
                    _showLogoutDialog(context);
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap ?? () {},
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: isDestructive ? Colors.red : Colors.black87),
      ),
      title: Text(title, 
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : Colors.black87
        )),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              ref.read(authViewModelProvider.notifier).logout();
              Navigator.pop(context);
            }, 
            child: const Text("Logout", style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }
}