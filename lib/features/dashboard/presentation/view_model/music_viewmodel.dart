import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/services/storage/user_session_service.dart';
import '../../data/datasources/remote/music_remote_datasource.dart';
import '../../data/repositories/music_repository_impl.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/usecases/get_new_releases_usecase.dart';
import '../../domain/usecases/get_top_picks_usecase.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient(sharedPreferences: ref.read(sharedPreferencesProvider)));

// Remote Data Source Provider
final musicRemoteDataSourceProvider = Provider<MusicRemoteDataSource>(
  (ref) => MusicRemoteDataSourceImpl(ref.read(apiClientProvider)),
);

// Repository Provider
final musicRepositoryProvider = Provider<MusicRepository>(
  (ref) => MusicRepositoryImpl(ref.read(musicRemoteDataSourceProvider)),
);

// Use Cases Providers
final getTopPicksUseCaseProvider = Provider<GetTopPicksUseCase>(
  (ref) => GetTopPicksUseCase(ref.read(musicRepositoryProvider)),
);

final getNewReleasesUseCaseProvider = Provider<GetNewReleasesUseCase>(
  (ref) => GetNewReleasesUseCase(ref.read(musicRepositoryProvider)),
);



