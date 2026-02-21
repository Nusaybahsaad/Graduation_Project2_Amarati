import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({required this.apiClient, required this.secureStorage});

  @override
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String role,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'role': role,
        },
      );
      // The backend returns a RegisterResponse message without tokens.
      // Usually after registration, the user might need OTP verification or direct login.
      // For now, we return a mock user or login immediately if the backend allows it.
      // Since our schema returns User data inside RegisterResponse:
      return Right(UserModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );

      final accessToken = response.data['access_token'];
      final refreshToken = response.data['refresh_token'];

      await secureStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      // Now fetch the current user profile
      return await getCurrentUser();
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.me);
      return Right(UserModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.deleteTokens();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
