import 'package:flutter/material.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:frontend/widgets/menu_drawer/menu_drawer.dart';
import 'package:frontend/widgets/navigation_bar/navigation_bar.dart' as nav;
import 'package:frontend/views/centered_view/centered_view.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class BaseView extends StatelessWidget {
  final List<Widget> children;
  final String title;
  final bool hasMenu;
  final String tooltip;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  BaseView({
    super.key,
    required this.children,
    required this.title,
    required this.tooltip,
    this.hasMenu = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      key: _scaffoldKey,
      appBar: nav.NavigationBar(
        title: title,
        tooltip: tooltip,
        hasMenu: hasMenu,
        onDrawerTapped: onDrawerTapped,
        onHelpTapped: onHelpTapped,
        onSelected: (int result) async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final isLoggedIn = authProvider.isLoggedIn;

          if (result == 0) {
            if (isLoggedIn) {
              await authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
            } else {
              Navigator.of(context).pushNamed('/p/login');
            }
          }
        },
      ),
      body: CenteredView(
        child: ListView(
          children: children,
        ),
      ),
      drawer: MenuDrawer(
        isAdmin: authProvider.isAdmin,
        isLoggedIn: authProvider.isLoggedIn,
      ),
    );
  }

  void onHelpTapped() {
    showDialog(
      context: _scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(tooltip),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.translate('common.close')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void onDrawerTapped() {
    _scaffoldKey.currentState?.openDrawer();
  }
}