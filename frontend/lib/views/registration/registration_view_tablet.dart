import 'package:flutter/material.dart';
import 'package:frontend/widgets/register_form/login_text_row.dart';
import '../../localizations/l10n.dart';
import '../../widgets/register_form/register_form.dart';
import '../base_view/base_view.dart';

class RegistrationViewTablet extends StatelessWidget {
  const RegistrationViewTablet ({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BaseView(
      title: AppLocalizations.of(context)!.translate('registration.title'),
      tooltip: AppLocalizations.of(context)!.translate('registration.tooltip_register_info'),
      children: [
        const RegisterForm(),
        const SizedBox(
          height: 20,
        ),

        Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoginTextRow(color: colorScheme.secondary),
          ],
        ),
      ],
    );
  }
}