import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/widgets/login_form/login_form.dart';
import '../../localizations/l10n.dart';

class LoginViewMobile extends StatelessWidget {
  const LoginViewMobile({super.key});

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