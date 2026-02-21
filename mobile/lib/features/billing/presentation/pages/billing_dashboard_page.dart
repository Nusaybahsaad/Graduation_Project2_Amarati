import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/billing_bloc.dart';
import '../bloc/billing_event.dart';
import '../bloc/billing_state.dart';
import 'invoice_detail_page.dart';
import '../../data/models/invoice_model.dart';
import 'package:intl/intl.dart';

class BillingDashboardPage extends StatefulWidget {
  const BillingDashboardPage({super.key});

  @override
  State<BillingDashboardPage> createState() => _BillingDashboardPageState();
}

class _BillingDashboardPageState extends State<BillingDashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<BillingBloc>().add(FetchInvoicesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'الفواتير والدفع',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            labelStyle: TextStyle(
              fontFamily: 'Cairo',
              fontWeight: FontWeight.bold,
            ),
            tabs: [
              Tab(text: 'المستحقة'),
              Tab(text: 'السجل'),
            ],
          ),
        ),
        body: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state is BillingLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is BillingError) {
              return Center(
                child: Text(
                  'حدث خطأ: ${state.message}',
                  style: const TextStyle(
                    color: AppColors.error,
                    fontFamily: 'Cairo',
                  ),
                ),
              );
            } else if (state is InvoicesLoaded) {
              final pending = state.invoices
                  .where((i) => i.status == 'PENDING' || i.status == 'OVERDUE')
                  .toList();
              final paid = state.invoices
                  .where((i) => i.status == 'PAID')
                  .toList();

              return TabBarView(
                children: [
                  _buildInvoiceList(pending, true),
                  _buildInvoiceList(paid, false),
                ],
              );
            }
            return const Center(
              child: Text(
                'لا توجد بيانات',
                style: TextStyle(fontFamily: 'Cairo'),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInvoiceList(List<InvoiceModel> invoices, bool isPending) {
    if (invoices.isEmpty) {
      return Center(
        child: Text(
          isPending ? 'لا توجد فواتير مستحقة' : 'لا يوجد سجل مدفوعات',
          style: const TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.textHint,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: invoices.length,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        final isOverdue = invoice.status == 'OVERDUE';

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: AppColors.surface,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => InvoiceDetailPage(invoice: invoice),
                ),
              );
            },
            leading: CircleAvatar(
              backgroundColor: isPending
                  ? (isOverdue
                        ? AppColors.error.withOpacity(0.1)
                        : AppColors.warning.withOpacity(0.1))
                  : AppColors.success.withOpacity(0.1),
              child: Icon(
                isPending ? Icons.receipt_long : Icons.check_circle,
                color: isPending
                    ? (isOverdue ? AppColors.error : AppColors.warning)
                    : AppColors.success,
              ),
            ),
            title: Text(
              invoice.description,
              style: const TextStyle(
                fontFamily: 'Cairo',
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'تاريخ الاستحقاق: ${DateFormat('yyyy-MM-dd').format(invoice.dueDate)}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  color: isOverdue ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${invoice.amount.toStringAsFixed(2)} AED',
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? (isOverdue
                              ? AppColors.error.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1))
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    invoice.statusLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPending
                          ? (isOverdue ? AppColors.error : AppColors.warning)
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
