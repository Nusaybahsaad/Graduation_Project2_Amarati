import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/invoice_model.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';

class InvoiceDetailPage extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailPage({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final bool isPaid = invoice.status == 'PAID';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'تفاصيل الفاتورة',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: BlocListener<BillingBloc, BillingState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تم الدفع بنجاح!',
                  style: TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is BillingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: 'Cairo'),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInvoiceHeader(),
              const SizedBox(height: 24),
              _buildInvoiceDetails(),
              const SizedBox(height: 32),
              if (!isPaid) _buildPayButton(context),
              if (isPaid &&
                  invoice.payments != null &&
                  invoice.payments!.isNotEmpty)
                _buildPaymentReceipt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            invoice.status == 'PAID' ? Icons.check_circle : Icons.receipt,
            size: 64,
            color: invoice.status == 'PAID'
                ? AppColors.success
                : AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            '${invoice.amount.toStringAsFixed(2)} AED',
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            invoice.description,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDetailRow(
            'رقم الفاتورة',
            invoice.id.substring(0, 8).toUpperCase(),
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildDetailRow(
            'تاريخ الإصدار',
            DateFormat('yyyy-MM-dd').format(invoice.createdAt),
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildDetailRow(
            'تاريخ الاستحقاق',
            DateFormat('yyyy-MM-dd').format(invoice.dueDate),
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildDetailRow(
            'الحالة',
            invoice.statusLabel,
            valueColor: invoice.status == 'PAID'
                ? AppColors.success
                : (invoice.status == 'OVERDUE'
                      ? AppColors.error
                      : AppColors.warning),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentReceipt() {
    final payment = invoice.payments!.first;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إيصال الدفع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'رقم المعاملة',
            payment.transactionReference ?? 'N/A',
          ),
          const SizedBox(height: 8),
          _buildDetailRow('طريقة الدفع', payment.paymentMethod),
          const SizedBox(height: 8),
          _buildDetailRow(
            'تاريخ الدفع',
            DateFormat('yyyy-MM-dd HH:mm').format(payment.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return BlocBuilder<BillingBloc, BillingState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state is BillingLoading
              ? null
              : () {
                  _showPaymentBottomSheet(context);
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: state is BillingLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'ادفع الآن',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        );
      },
    );
  }

  void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surface,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'اختر طريقة الدفع',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildPaymentMethodTile(
                  context,
                  'MOCK_CREDIT_CARD',
                  'بطاقة ائتمان',
                  Icons.credit_card,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodTile(
                  context,
                  'MOCK_APPLE_PAY',
                  'Apple Pay',
                  Icons.apple,
                ),
                const SizedBox(height: 12),
                _buildPaymentMethodTile(
                  context,
                  'MOCK_BANK_TRANSFER',
                  'تحويل بنكي',
                  Icons.account_balance,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodTile(
    BuildContext context,
    String method,
    String title,
    IconData icon,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Close bottom sheet
        context.read<BillingBloc>().add(
          PayInvoiceEvent(
            invoiceId: invoice.id,
            amount: invoice.amount,
            paymentMethod: method,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}
