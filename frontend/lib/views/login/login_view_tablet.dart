import 'package:flutter/material.dart';
import '../../localizations/l10n.dart';
import '../../widgets/login_form/login_form.dart';
import '../base_view/base_view.dart';

class LoginViewTablet extends StatelessWidget {
  const LoginViewTablet({super.key});

  @override
  Widget build(BuildContext context) {

    return BaseView(
      title: AppLocalizations.of(context)!.translate('login.title'),
      tooltip: AppLocalizations.of(context)!.translate('login.tooltip_login_info'),
      children: const [
        LoginForm()
      ],
    );
  }
}