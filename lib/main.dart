import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:musicapp/app/app.dart';
import 'package:musicapp/core/services/hive/hive_service.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    final hiveService = HiveService();
    await hiveService.init(); // This usually calls Hive.initFlutter()
    
    // ADD THIS LINE: Open the specific boxes your app uses
    // Replace 'user_box' with the actual name used in your Sign-Up logic
    await Hive.openBox('user_box'); 
    await Hive.openBox('settings_box'); // Open any others you need
  }
  
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs)
    ],
    child: const App(),
  ));
}