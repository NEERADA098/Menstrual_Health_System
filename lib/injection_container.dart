import 'package:get_it/get_it.dart';
import 'features/asha_dashboard/presentation/bloc/asha_bloc.dart';
import 'core/network/api_client.dart';

import 'core/sync/sync_service.dart';

import 'core/sync/sync_manager.dart';

import 'features/symptom_tracking/data/datasources/symptom_local_datasource.dart';
import 'features/symptom_tracking/data/repositories/symptom_repository_impl.dart';
import 'features/symptom_tracking/domain/repositories/symptom_repository.dart';
import 'features/symptom_tracking/domain/usecases/log_symptom.dart';
import 'features/symptom_tracking/domain/usecases/get_symptoms_for_user.dart';
import 'features/symptom_tracking/presentation/bloc/symptom_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'features/auth/data/datasources/firebase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/send_otp.dart';
import 'features/auth/domain/usecases/verify_otp.dart';
import 'features/auth/domain/usecases/sign_in_with_email.dart';
import 'features/auth/domain/usecases/sign_up_with_email.dart';
import 'features/auth/domain/usecases/sign_out.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'core/database/database_helper.dart';
import 'features/cycle_tracking/data/datasources/cycle_local_datasource.dart';
import 'features/cycle_tracking/data/repositories/cycle_repository_impl.dart';
import 'features/cycle_tracking/domain/repositories/cycle_repository.dart';
import 'features/cycle_tracking/domain/usecases/log_cycle.dart';
import 'features/cycle_tracking/domain/usecases/get_cycle_history.dart';
import 'features/cycle_tracking/domain/usecases/get_current_cycle.dart';
import 'features/cycle_tracking/presentation/bloc/cycle_bloc.dart';

/// sl - Stands for "Service Locator." This is a single global
/// instance of GetIt that holds every dependency your app needs.
///
/// WHY DEPENDENCY INJECTION MATTERS:
/// Without this, every widget that needs an AuthBloc would have to
/// manually construct it AND all six use cases AND the repository
/// AND the datasource AND Firebase instances - a massive chain of
/// object creation repeated everywhere. GetIt builds this chain
/// ONCE, here, and any widget can request "give me an AuthBloc"
/// without knowing or caring how it's built.
final sl = GetIt.instance;

/// Call this once in main.dart before runApp().
/// Registers every dependency the app needs, in the correct order
/// (dependencies must be registered before things that depend on them).
Future<void> setupInjection() async {
  // ── EXTERNAL PACKAGES (Firebase SDK instances) ──────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ── DATA SOURCES ─────────────────────────────────────────────────
  sl.registerLazySingleton(
    () => FirebaseAuthDataSource(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  // ── REPOSITORIES ─────────────────────────────────────────────────
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // ── USE CASES ────────────────────────────────────────────────────
  sl.registerLazySingleton(() => SendOtp(sl()));
  sl.registerLazySingleton(() => VerifyOtp(sl()));
  sl.registerLazySingleton(() => SignInWithEmail(sl()));
  sl.registerLazySingleton(() => SignUpWithEmail(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  



 sl.registerLazySingleton(() => ApiClient());

  sl.registerLazySingleton(() => SyncService(dbHelper: sl()));

  sl.registerLazySingleton(() => SyncManager(syncService: sl()));

  // ── CYCLE TRACKING ────────────────────────────────────────────────
  sl.registerLazySingleton(() => DatabaseHelper.instance);
  sl.registerLazySingleton(() => CycleLocalDataSource(dbHelper: sl()));
  sl.registerLazySingleton<CycleRepository>(
    () => CycleRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LogCycle(sl()));
  sl.registerLazySingleton(() => GetCycleHistory(sl()));
  sl.registerLazySingleton(() => GetCurrentCycle(sl()));


  sl.registerLazySingleton(() => AshaBloc());

  // ── SYMPTOM TRACKING ─────────────────────────────────────────────────
  sl.registerLazySingleton(() => SymptomLocalDataSource(dbHelper: sl()));
  sl.registerLazySingleton<SymptomRepository>(
    () => SymptomRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => LogSymptom(sl()));
  sl.registerLazySingleton(() => GetSymptomsForUser(sl()));
  sl.registerLazySingleton(
    () => SymptomBloc(
      logSymptom: sl(),
      getSymptomsForUser: sl(),
    ),
  );
  // ── BLOCS ────────────────────────────────────────────────────────
  // Note: registerFactory (not LazySingleton) - we want a FRESH
  // AuthBloc instance, though for app-wide auth state a singleton
  // is actually more correct. We use LazySingleton here since auth
  // state should persist across the whole app's lifetime.
  sl.registerLazySingleton(
    () => AuthBloc(
      sendOtp: sl(),
      verifyOtp: sl(),
      signInWithEmail: sl(),
      signUpWithEmail: sl(),
      signOut: sl(),
      getCurrentUser: sl(),
    ),
  );

  // ── CYCLE TRACKING BLOC ─────────────────────────────────────────────
  sl.registerLazySingleton(
    () => CycleBloc(
      logCycle: sl(),
      getCycleHistory: sl(),
      getCurrentCycle: sl(),
    ),
  );
}