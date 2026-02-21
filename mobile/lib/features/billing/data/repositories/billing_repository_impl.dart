import 'package:dio/dio.dart';
import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../../domain/repositories/billing_repository.dart';
import '../../../../core/network/api_client.dart';

class BillingRepositoryImpl implements BillingRepository {
  final ApiClient apiClient;

  BillingRepositoryImpl({required this.apiClient});

  @override
  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final response = await apiClient.get('/billing/invoices');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => InvoiceModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load invoices');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<PaymentModel> payInvoice(
    String invoiceId,
    double amount,
    String paymentMethod,
  ) async {
    try {
      final response = await apiClient.post(
        '/billing/payments/$invoiceId/pay',
        data: {'amount': amount.toString(), 'payment_method': paymentMethod},
      );
      if (response.statusCode == 200) {
        return PaymentModel.fromJson(response.data);
      } else {
        throw Exception('Payment failed');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Network error during payment',
      );
    } catch (e) {
      throw Exception('Unknown error: $e');
    }
  }

  @override
  Future<InvoiceModel> createInvoice(
    String propertyId,
    String userId,
    double amount,
    String description,
    DateTime dueDate,
  ) async {
    try {
      final response = await apiClient.post(
        '/billing/invoices',
        data: {
          'property_id': propertyId,
          'user_id': userId,
          'amount': amount.toString(),
          'description': description,
          'due_date': dueDate.toIso8601String(),
        },
      );
      if (response.statusCode == 201) {
        return InvoiceModel.fromJson(response.data);
      } else {
        throw Exception('Failed to create invoice');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
