import 'package:flutter/material.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/widgets/custom_icon_button/custom_icon_button.dart';
import 'package:provider/provider.dart';
import '../../localizations/l10n.dart';
import '../../providers/auth_provider.dart';

class HomeViewDesktop extends StatelessWidget {
  const HomeViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BaseView(
      title: AppLocalizations.of(context)!.translate('home.title'),
      tooltip: AppLocalizations.of(context)!.translate('home.tooltip_home_info'),
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
                AppLocalizations.of(context)!.translate('home.description'),
                textAlign: TextAlign.start,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.center,
                child: CustomIconButton(
                  buttonSize: 250.0,
                  icon: Icons.public,
                  text: AppLocalizations.of(context)!.translate('home.button_public_election'),
                  tooltip: AppLocalizations.of(context)!.translate('home.button_tooltip_public_election'),
                  onPressed: () {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    if (authProvider.isLoggedIn) {
                      Navigator.of(context).pushNamed('/p/election');
                    } else {
                      Navigator.of(context).pushNamed('/p/registration');
                    }
                  },
                ),
              ),
            ),
            const SizedBox(width: 20), // Add space between the buttons
            Flexible(
              child: Align(
                alignment: Alignment.center,
                child: CustomIconButton(
                  buttonSize: 250.0,
                  icon: Icons.lock,
                  text: AppLocalizations.of(context)!.translate('home.button_private_election'),
                  tooltip: AppLocalizations.of(context)!.translate('home.button_tooltip_private_election'),
                  isEnabled: false,
                  onPressed: () {
                    // Handle button press
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}