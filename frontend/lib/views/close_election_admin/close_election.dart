import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:frontend/widgets/close_election/close_election_form.dart';

class CloseElectionAdminDesktop extends StatelessWidget {
  const CloseElectionAdminDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return BaseView(
      title: AppLocalizations.of(context)!.translate('close_election.title'),
      tooltip: AppLocalizations.of(context)!.translate('close_election.tooltip_close_election_info'),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: DefaultTextStyle(
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24.0,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Text(
                AppLocalizations.of(context)!.translate('close_election.description'),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
        CloseElectionForm(),
      ],
    );
  }
}
