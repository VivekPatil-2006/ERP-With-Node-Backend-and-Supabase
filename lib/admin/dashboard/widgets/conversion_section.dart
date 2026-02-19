import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ConversionSection extends StatelessWidget {
  final Map<String, dynamic> conversion;

  const ConversionSection({
    super.key,
    required this.conversion,
  });

  @override
  Widget build(BuildContext context) {
    final enquiryToQuotation =
    (conversion["enquiryToQuotationPercentage"] ?? 0)
        .toDouble();

    final quotationToPayment =
    (conversion["quotationToPaymentPercentage"] ?? 0)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Conversion Rates",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildConversionCard(
                "Enquiry → Quotation",
                enquiryToQuotation,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildConversionCard(
                "Quotation → Payment",
                quotationToPayment,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConversionCard(String title, double value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            "${value.toStringAsFixed(2)}%",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),

          const SizedBox(height: 8),

          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primaryBlue,
            minHeight: 6,
          ),
        ],
      ),
    );
  }
}
