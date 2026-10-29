import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/game/data/datasources/game_local_datasource.dart';
import '../../features/game/data/datasources/game_remote_datasource.dart';
import '../../features/game/data/repositories/game_repository_impl.dart';
import '../../features/game/domain/repositories/game_repository.dart';
import '../../features/game/domain/usecases/get_level_progress_usecase.dart';
import '../../features/game/domain/usecases/save_level_result_usecase.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../services/sound_service.dart';

/// Dependency Injection setup for the entire app.
class DependencyInjection {
  /// Asynchronous dependencies initialization before runApp()
  static Future<void> init() async {
    try {
      await Firebase.initializeApp();
    } catch (e) {
      debugPrint('Firebase init note: $e');
    }

    // Initialize Game Sound Service
    SoundService.init();
  }

  /// Synchronous bindings helper
  static void bindings() {
    InitialBinding().dependencies();
  }
}

/// Global Bindings loaded automatically by GetMaterialApp(initialBinding: InitialBinding())
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Auth Controller
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);

    // Game Domain & Data Layer (Clean Architecture)
    Get.lazyPut<GameLocalDataSource>(() => GameLocalDataSourceImpl(), fenix: true);
    Get.lazyPut<GameRemoteDataSource>(() => GameRemoteDataSourceImpl(), fenix: true);
    Get.lazyPut<GameRepository>(
      () => GameRepositoryImpl(
        localDataSource: Get.find<GameLocalDataSource>(),
        remoteDataSource: Get.find<GameRemoteDataSource>(),
      ),
      fenix: true,
    );
    Get.lazyPut<GetLevelProgressUseCase>(
      () => GetLevelProgressUseCase(Get.find<GameRepository>()),
      fenix: true,
    );
    Get.lazyPut<SaveLevelResultUseCase>(
      () => SaveLevelResultUseCase(Get.find<GameRepository>()),
      fenix: true,
    );

    // Home Controller
    Get.lazyPut<HomeController>(() => HomeController(), fenix: true);

    // Theme Controller to demonstrate DI and reactive theme control
    Get.lazyPut<ThemeController>(() => ThemeController(), fenix: true);
  }
}

/// Reactive ThemeController injected via Dependency Injection
class ThemeController extends GetxController {
  final RxBool isDarkMode = true.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void setTheme(bool dark) {
    isDarkMode.value = dark;
    Get.changeThemeMode(dark ? ThemeMode.dark : ThemeMode.light);
  }
}
