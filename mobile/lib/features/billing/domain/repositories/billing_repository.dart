import '../../data/models/invoice_model.dart';
import '../../data/models/payment_model.dart';

abstract class BillingRepository {
  Future<List<InvoiceModel>> getInvoices();
  Future<PaymentModel> payInvoice(
    String invoiceId,
    double amount,
    String paymentMethod,
  );
  Future<InvoiceModel> createInvoice(
    String propertyId,
    String userId,
    double amount,
    String description,
    DateTime dueDate,
  );
}
