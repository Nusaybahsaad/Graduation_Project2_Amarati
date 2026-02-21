import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/maintenance/domain/repositories/maintenance_repository.dart';
import '../../features/maintenance/data/repositories/maintenance_repository_impl.dart';
import '../../features/maintenance/presentation/bloc/maintenance_bloc.dart';
import '../../features/provider/domain/repositories/provider_repository.dart';
import '../../features/provider/data/repositories/provider_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/presentation/bloc/notification_bloc.dart';
import '../../features/billing/domain/repositories/billing_repository.dart';
import '../../features/billing/data/repositories/billing_repository_impl.dart';
import '../../features/billing/presentation/bloc/billing_bloc.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/presentation/bloc/community_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());
  sl.registerLazySingleton<ApiClient>(() => ApiClient(secureStorage: sl()));

  // Auth Feature
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(apiClient: sl(), secureStorage: sl()),
  );
  sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));

  // Maintenance Feature
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(apiClient: sl()),
  );
  sl.registerFactory<MaintenanceBloc>(() => MaintenanceBloc(repository: sl()));

  // Provider Feature
  sl.registerLazySingleton<ProviderRepository>(
    () => ProviderRepositoryImpl(apiClient: sl()),
  );

  // Notifications Feature
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(apiClient: sl()),
  );
  sl.registerFactory<NotificationBloc>(
    () => NotificationBloc(repository: sl()),
  );

  // Billing Feature
  sl.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(apiClient: sl()),
  );
  sl.registerFactory<BillingBloc>(() => BillingBloc(repository: sl()));

  // Community Feature
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(apiClient: sl()),
  );
  sl.registerFactory<CommunityBloc>(() => CommunityBloc(repository: sl()));
}
