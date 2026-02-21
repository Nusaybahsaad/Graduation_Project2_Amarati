import 'package:equatable/equatable.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();

  @override
  List<Object?> get props => [];
}

class FetchInvoicesEvent extends BillingEvent {}

class PayInvoiceEvent extends BillingEvent {
  final String invoiceId;
  final double amount;
  final String paymentMethod;

  const PayInvoiceEvent({
    required this.invoiceId,
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [invoiceId, amount, paymentMethod];
}

class CreateInvoiceEvent extends BillingEvent {
  final String propertyId;
  final String userId;
  final double amount;
  final String description;
  final DateTime dueDate;

  const CreateInvoiceEvent({
    required this.propertyId,
    required this.userId,
    required this.amount,
    required this.description,
    required this.dueDate,
  });

  @override
  List<Object?> get props => [propertyId, userId, amount, description, dueDate];
}
