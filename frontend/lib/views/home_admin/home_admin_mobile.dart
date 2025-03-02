import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';

import '../../localizations/l10n.dart';

class HomeAdminMobile extends StatelessWidget {
  const HomeAdminMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BaseView(
      title: AppLocalizations.of(context)!.translate('home_admin.title'),
      tooltip: AppLocalizations.of(context)!.translate('home_admin.tooltip'),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                AppLocalizations.of(context)!.translate('home_admin.description'),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),



      ],
    );
  }
}