import 'package:flutter/material.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class MenuDrawer extends StatelessWidget {
  final bool isAdmin;
  final bool isLoggedIn;
  const MenuDrawer({super.key, required this.isAdmin, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              AppLocalizations.of(context)!.translate('menu.title'),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_home')),
            onTap: () {
              if (isAdmin) {
                Navigator.of(context).pushNamed('/p/home');
              } else {
                Navigator.of(context).pushNamed('/home');
              }
            },
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_help')),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.translate('menu.item_help')),
                    content: Text(AppLocalizations.of(context)!.translate('menu.item_help_content')),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(AppLocalizations.of(context)!.translate('common.close')),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          if (isAdmin) ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_results')),
            onTap: () {
              Navigator.of(context).pushNamed('/p/results');
            },
          ),
          if (isAdmin) ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_election')),
            onTap: () {
              Navigator.of(context).pushNamed('/p/new_election');
            },
          ),
          if (isAdmin) ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_close_election')),
            onTap: () {
              Navigator.of(context).pushNamed('/p/close_election');
            },
          ),
          if (isLoggedIn) ListTile(
            title: Text(AppLocalizations.of(context)!.translate('menu.item_logout')),
            onTap: () {
              authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}