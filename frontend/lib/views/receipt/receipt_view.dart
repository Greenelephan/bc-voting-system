import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/widgets/receipt/receipt.dart';
import '../../localizations/l10n.dart';

class ReceiptView extends StatelessWidget {
  final String? initialReceiptId;

  const ReceiptView({super.key, this.initialReceiptId});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BaseView(
      title: AppLocalizations.of(context)!.translate('receipt.title'),
      tooltip: AppLocalizations.of(context)!.translate('receipt.tooltip_receipt_info'),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 70.0),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                AppLocalizations.of(context)!.translate('receipt.description'),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
        ReceiptStatus(initialReceiptId: initialReceiptId),
      ],
    );
  }
}