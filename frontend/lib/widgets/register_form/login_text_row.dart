import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../localizations/l10n.dart';

class LoginTextRow extends StatelessWidget {
  final Color color;

  const LoginTextRow({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: <TextSpan>[
            TextSpan(
              text: AppLocalizations.of(context)!.translate('registration.text_to_login_1'),
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.translate('registration.text_to_login_2'),
              style: TextStyle(color: color),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  Navigator.of(context).pushNamed('/p/login');
                },
            ),
            TextSpan(
              text: AppLocalizations.of(context)!.translate('registration.text_to_login_3'),
            ),
          ],
        ),
      ),
    );
  }
}