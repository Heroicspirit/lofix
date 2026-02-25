class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:5000/api/'; // Android Emulator
  static const String baseUrl = 'http://192.168.1.67:5000/api/'; // Physical Device (current IP)
  // static const String baseUrl = 'http://localhost:5000/api/'; // iOS Simulator
  
  // For Android Emulator use: 'http://10.0.2.2:5000/api'
  // For iOS Simulator use: 'http://localhost:5000/api'
  // For Physical Device use your computer's IP: 'http://172.25.0.104:5000/api'

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Auth Endpoints
  static const String login = "auth/login";
  static const String register = "auth/register";

  static const String userProfile = 'auth/update-profile';

  // Music/Song Endpoints (matching actual backend routes)
  static const String songs = 'songs'; // GET /api/songs - gets all songs
  static const String topPicks = 'songs/top-picks';
  static const String newReleases = 'songs/new-releases';
  static const String trending = 'songs/trending';
  static const String search = 'songs/search'; // GET /api/songs/search?q=query 

  // Playlist Endpoints
  static const String playlists = 'playlists'; // GET /api/playlists, POST /api/playlists
}







