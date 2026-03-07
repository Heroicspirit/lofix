import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicapp/core/services/storage/user_session_service.dart';
import 'package:musicapp/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:musicapp/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/home_screen.dart';
import 'package:musicapp/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:musicapp/features/dashboard/presentation/view_model/music_viewmodel.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_top_picks_usecase.dart';
import 'package:musicapp/features/dashboard/domain/usecases/get_new_releases_usecase.dart';
import 'package:musicapp/core/providers/offline_mode_provider.dart';

// Mock classes
class MockUserSessionService extends Mock implements UserSessionService {}
class MockAuthViewModel extends AuthViewModel with Mock {} 
class MockGetTopPicksUseCase extends Mock implements GetTopPicksUseCase {}
class MockGetNewReleasesUseCase extends Mock implements GetNewReleasesUseCase {}
class MockOfflineModeNotifier extends StateNotifier<OfflineModeState> implements OfflineModeNotifier {
  MockOfflineModeNotifier() : super(OfflineModeState(
    status: OfflineModeStatus.online,
    isLoggedIn: false,
    hasNetwork: true,
  ));
  
  @override
  Future<void> checkConnectionStatus() async {}
  
  @override
  Future<void> refresh() async {}
  
  @override
  void updateLoginStatus(bool isLoggedIn) {}
}

void main() {
  late MockUserSessionService mockSessionService;
  late MockAuthViewModel mockAuthViewModel;
  late MockGetTopPicksUseCase mockGetTopPicksUseCase;
  late MockGetNewReleasesUseCase mockGetNewReleasesUseCase;

  setUp(() {
    mockSessionService = MockUserSessionService();
    mockAuthViewModel = MockAuthViewModel();
    mockGetTopPicksUseCase = MockGetTopPicksUseCase();
    mockGetNewReleasesUseCase = MockGetNewReleasesUseCase();

    // Stub the methods that ProfileScreen calls during its build/init
    when(() => mockSessionService.getUsername()).thenReturn("Test User");
    when(() => mockSessionService.getUserEmail()).thenReturn("test@example.com");
    when(() => mockSessionService.getUserProfileImage()).thenReturn(null);
    
    // Mock the use cases to return empty lists
    when(() => mockGetTopPicksUseCase()).thenAnswer((_) async => []);
    when(() => mockGetNewReleasesUseCase()).thenAnswer((_) async => []);
    
    // Initialize mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
  });

  Future<Widget> createDashboardScreen() async {
    final prefs = await SharedPreferences.getInstance();
    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        userSessionServiceProvider.overrideWithValue(mockSessionService),
        authViewModelProvider.overrideWith(() => mockAuthViewModel),
        getTopPicksUseCaseProvider.overrideWithValue(mockGetTopPicksUseCase),
        getNewReleasesUseCaseProvider.overrideWithValue(mockGetNewReleasesUseCase),
        offlineModeProvider.overrideWith((ref) => MockOfflineModeNotifier()),
      ],
      child: const MaterialApp(
        home: DashboardScreen(),
      ),
    );
  }

  group("DashboardScreen Navigation Tests", () {
    testWidgets('DashboardScreen has correct navigation bar items', (tester) async {
      await tester.pumpWidget(await createDashboardScreen());
      await tester.pump(); 

      // Verify navigation bar exists
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      
      // Verify labels are present (allowing for multiple instances)
      expect(find.text('Home'), findsNWidgets(2)); // One in AppBar, one in nav bar
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Navigation bar has correct styling', (tester) async {
      await tester.pumpWidget(await createDashboardScreen());
      await tester.pump(); 
      
      final navBar = tester.widget<BottomNavigationBar>(find.byType(BottomNavigationBar));
      expect(navBar.backgroundColor, Colors.amber);
      expect(navBar.selectedItemColor, Colors.blueAccent);
      expect(navBar.unselectedItemColor, Colors.white);
    });

    testWidgets('Tapping navigation items changes selected index', (tester) async {
      await tester.pumpWidget(await createDashboardScreen());
      await tester.pump(); 

      // Initially Home should be selected
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Tap on Profile icon in the navigation bar (find by text label to be more specific)
      await tester.tap(find.text('Profile'));
      await tester.pump(); 
      
      // ProfileScreen should now be shown
      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.text("Test User"), findsOneWidget);
    });
  });
}
