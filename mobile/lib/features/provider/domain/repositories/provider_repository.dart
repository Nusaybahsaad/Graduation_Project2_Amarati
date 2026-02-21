import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/provider_model.dart';

abstract class ProviderRepository {
  Future<Either<Failure, List<ProviderModel>>> getProviders({
    String? category,
    String? city,
    double? minRating,
  });
  Future<Either<Failure, ProviderModel>> getProvider(String id);
}
