import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String role,
  });

  Future<Either<Failure, UserModel>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserModel>> getCurrentUser();

  Future<Either<Failure, void>> logout();
}
