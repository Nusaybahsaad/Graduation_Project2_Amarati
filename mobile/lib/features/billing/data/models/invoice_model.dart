import 'payment_model.dart';

class InvoiceModel {
  final String id;
  final String propertyId;
  final String? unitId;
  final String userId;
  final String createdById;
  final double amount;
  final String description;
  final DateTime dueDate;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<PaymentModel>? payments;

  InvoiceModel({
    required this.id,
    required this.propertyId,
    this.unitId,
    required this.userId,
    required this.createdById,
    required this.amount,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.payments,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      propertyId: json['property_id'] as String,
      unitId: json['unit_id'] as String?,
      userId: json['user_id'] as String,
      createdById: json['created_by_id'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      payments: (json['payments'] as List?)
          ?.map((p) => PaymentModel.fromJson(p))
          .toList(),
    );
  }

  String get statusLabel {
    switch (status) {
      case 'PENDING':
        return 'قيد الانتظار';
      case 'PAID':
        return 'مدفوعة';
      case 'OVERDUE':
        return 'متأخرة';
      case 'CANCELLED':
        return 'ملغاة';
      default:
        return status;
    }
  }
}
