class PaymentModel {
  final String id;
  final String invoiceId;
  final String userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? transactionReference;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.invoiceId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.transactionReference,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      userId: json['user_id'] as String,
      amount: double.tryParse(json['amount'].toString()) ?? 0.0,
      paymentMethod: json['payment_method'] as String,
      status: json['status'] as String,
      transactionReference: json['transaction_reference'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
