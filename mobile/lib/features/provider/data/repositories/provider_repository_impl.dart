import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/repositories/provider_repository.dart';
import '../models/provider_model.dart';

class ProviderRepositoryImpl implements ProviderRepository {
  final ApiClient apiClient;

  ProviderRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, List<ProviderModel>>> getProviders({
    String? category,
    String? city,
    double? minRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (category != null) queryParams['category'] = category;
      if (city != null) queryParams['city'] = city;
      if (minRating != null) queryParams['min_rating'] = minRating;

      final response = await apiClient.get(
        ApiEndpoints.providers,
        queryParameters: queryParams,
      );
      final items = (response.data['items'] as List)
          .map((json) => ProviderModel.fromJson(json))
          .toList();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProviderModel>> getProvider(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.providerDetail(id));
      return Right(ProviderModel.fromJson(response.data));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
