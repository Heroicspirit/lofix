import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/auth/presentation/pages/login_screen.dart';
import 'package:musicapp/core/services/audio/music_player_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';



class ProfileScreen extends ConsumerStatefulWidget {

  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}



class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  final ImagePicker _picker = ImagePicker();

  File? _localImage;

  bool _isEditingProfile = false;

  final TextEditingController _nameController = TextEditingController();



  @override

  void initState() {

    super.initState();

    _loadProfileImage();

    _loadUserName();

  }



  void _loadProfileImage() {

    final userSession = ref.read(userSessionServiceProvider);

    final profileImageUrl = userSession.getUserProfileImage();

    

    if (profileImageUrl != null && profileImageUrl.isNotEmpty) {

      print('Loading profile image: $profileImageUrl');

      // Force a rebuild to show saved profile image

      setState(() {});

    }

  }



  void _loadUserName() {

    final userSession = ref.read(userSessionServiceProvider);

    final userName = userSession.getUsername() ?? 'User';

    _nameController.text = userName;

  }



  void _startEditProfile() {

    final offlineModeState = ref.read(offlineModeProvider);

    

    if (!offlineModeState.canEditProfile) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text('Cannot edit profile in offline mode'),

          backgroundColor: Colors.orange,

        ),

      );

      return;

    }

    

    setState(() {

      _isEditingProfile = true;

    });

  }



  Future<void> _saveProfile() async {

    if (_nameController.text.trim().isEmpty) return;

    

    try {

      // Update name

      await ref.read(authViewModelProvider.notifier).updateUserName(_nameController.text.trim());

      

      // Upload image if changed

      if (_localImage != null) {

        await ref.read(authViewModelProvider.notifier).uploadPhoto(_localImage!);

      }

      

      setState(() {

        _isEditingProfile = false;

      });

      

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Profile updated successfully'),

            backgroundColor: Colors.green,

          ),

        );

      }

    } catch (e) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(

            content: Text('Failed to update profile: $e'),

            backgroundColor: Colors.red,

          ),

        );

      }

    }

  }



  void _cancelEditProfile() {

    setState(() {

      _isEditingProfile = false;

      _localImage = null;

    });

    _loadUserName(); // Reset to original name

  }



  Future<void> _handleLogout() async {

    try {

      // Stop music player before logout

      final musicPlayerService = ref.read(musicPlayerServiceProvider);

      

      // Multiple attempts to stop music

      try {

        await musicPlayerService.stopSong();

      } catch (e) {

        print('Error stopping song: $e');

      }

      

      // Also try to pause if stop doesn't work

      try {

        await musicPlayerService.pauseSong();

      } catch (e) {

        print('Error pausing song: $e');

      }

      

      // Clear current song

      ref.read(currentSongProvider.notifier).state = null;

      ref.read(isPlayingProvider.notifier).state = false;

      

      // Call the logout method from auth view model

      await ref.read(authViewModelProvider.notifier).logout();

      

      // Navigate to login screen

      if (mounted) {

        Navigator.of(context).pushAndRemoveUntil(

          MaterialPageRoute(builder: (context) => const LoginScreen()),

          (route) => false,

        );

      }

    } catch (e) {

      print('Error during logout: $e');

    }

  }



  @override

  void dispose() {

    _nameController.dispose();

    super.dispose();

  }



  Future<void> _pickImage(ImageSource source) async {

    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {

      final imageFile = File(pickedFile.path);

      setState(() => _localImage = imageFile);

      // Don't upload immediately - wait for save

    }

  }



  @override

  Widget build(BuildContext context) {

    final userSession = ref.watch(userSessionServiceProvider);

    final offlineModeState = ref.watch(offlineModeProvider);

    final userName = _isEditingProfile ? _nameController.text : (userSession.getUsername() ?? 'User');

    final userEmail = userSession.getUserEmail() ?? 'No Email';

    final profileImageUrl = userSession.getUserProfileImage();



    ImageProvider? imageToShow;

    // Don't load images in offline mode

    if (_localImage != null) {

      imageToShow = FileImage(_localImage!);

    } else if (profileImageUrl != null && 

               profileImageUrl.isNotEmpty && 

               offlineModeState.canLoadImages) {

      print('Raw profileImageUrl: $profileImageUrl');

      

      // Remove /upload/ prefix if it exists to avoid duplication

      final cleanImageUrl = profileImageUrl.startsWith('/upload/') 

          ? profileImageUrl.substring(7)

          : profileImageUrl;

      

      final finalUrl = 'http://192.168.1.67:5000/upload/$cleanImageUrl';

      print('Clean image URL: $finalUrl');
      

      imageToShow = NetworkImage(finalUrl);

    }



    return Scaffold(

      appBar: AppBar(

        title: const Text("Account"),

        elevation: 0,

        actions: [

          IconButton(

            onPressed: _handleLogout,

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

                  if (_isEditingProfile)

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

            if (_isEditingProfile)

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: TextField(

                  controller: _nameController,

                  textAlign: TextAlign.center,

                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),

                  decoration: const InputDecoration(

                    border: UnderlineInputBorder(),

                    hintText: 'Enter your name',

                  ),

                ),

              )

            else

              Text(userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

            Text(userEmail, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),



            // --- Edit/Save Buttons ---

            if (_isEditingProfile)

              Padding(

                padding: const EdgeInsets.symmetric(horizontal: 20),

                child: Row(

                  children: [

                    Expanded(

                      child: ElevatedButton(

                        onPressed: _cancelEditProfile,

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.grey,

                          foregroundColor: Colors.white,

                        ),

                        child: const Text('Cancel'),

                      ),

                    ),

                    const SizedBox(width: 16),

                    Expanded(

                      child: ElevatedButton(

                        onPressed: _saveProfile,

                        style: ElevatedButton.styleFrom(

                          backgroundColor: Colors.blue,

                          foregroundColor: Colors.white,

                        ),

                        child: const Text('Save'),

                      ),

                    ),

                  ],

                ),

              ),



            // --- Settings Sections ---

            _buildSectionTitle("Account Settings"),

            if (!_isEditingProfile)

              _buildSettingsItem(Icons.person_outline, "Edit Profile", offlineModeState.canEditProfile ? _startEditProfile : () {}),

            _buildSettingsItem(Icons.lock_outline, "Change Password", () {}),

            

            const Divider(),

            _buildSectionTitle("Preferences"),

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