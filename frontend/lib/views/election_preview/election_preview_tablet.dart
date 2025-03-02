import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';

import '../../localizations/l10n.dart';

class PublicElectionPreviewTablet extends StatelessWidget {
  const PublicElectionPreviewTablet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BaseView(
      title: AppLocalizations.of(context)!.translate('public_election_preview.title'),
      tooltip: AppLocalizations.of(context)!.translate('public_election_preview.tooltip_preview_info'),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 70.0),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                AppLocalizations.of(context)!.translate('public_election_preview.description'),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),

        // Preview election Widget


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context)!.translate('common.back')),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/home');
                  },
                  child: Text(AppLocalizations.of(context)!.translate('public_election_preview.button_preview_election')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}