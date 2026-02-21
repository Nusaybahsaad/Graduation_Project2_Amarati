import 'package:equatable/equatable.dart';
import '../../data/models/invoice_model.dart';
import '../../data/models/payment_model.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingInitial extends BillingState {}

class BillingLoading extends BillingState {}

class InvoicesLoaded extends BillingState {
  final List<InvoiceModel> invoices;

  const InvoicesLoaded(this.invoices);

  @override
  List<Object?> get props => [invoices];
}

class BillingError extends BillingState {
  final String message;

  const BillingError(this.message);

  @override
  List<Object?> get props => [message];
}

class PaymentSuccess extends BillingState {
  final PaymentModel payment;

  const PaymentSuccess(this.payment);

  @override
  List<Object?> get props => [payment];
}

class InvoiceCreatedSuccess extends BillingState {
  final InvoiceModel invoice;

  const InvoiceCreatedSuccess(this.invoice);

  @override
  List<Object?> get props => [invoice];
}
