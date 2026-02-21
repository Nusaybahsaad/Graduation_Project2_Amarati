import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/billing_repository.dart';
import 'billing_event.dart';
import 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final BillingRepository repository;

  BillingBloc({required this.repository}) : super(BillingInitial()) {
    on<FetchInvoicesEvent>(_onFetchInvoices);
    on<PayInvoiceEvent>(_onPayInvoice);
    on<CreateInvoiceEvent>(_onCreateInvoice);
  }

  Future<void> _onFetchInvoices(
    FetchInvoicesEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoices = await repository.getInvoices();
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onPayInvoice(
    PayInvoiceEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final payment = await repository.payInvoice(
        event.invoiceId,
        event.amount,
        event.paymentMethod,
      );
      emit(PaymentSuccess(payment));
      // Re-fetch invoices to update the list
      add(FetchInvoicesEvent());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }

  Future<void> _onCreateInvoice(
    CreateInvoiceEvent event,
    Emitter<BillingState> emit,
  ) async {
    emit(BillingLoading());
    try {
      final invoice = await repository.createInvoice(
        event.propertyId,
        event.userId,
        event.amount,
        event.description,
        event.dueDate,
      );
      emit(InvoiceCreatedSuccess(invoice));
      add(FetchInvoicesEvent());
    } catch (e) {
      emit(BillingError(e.toString()));
    }
  }
}
