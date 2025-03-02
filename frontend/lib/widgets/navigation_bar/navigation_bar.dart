import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localizations/l10n.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';

class NavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String tooltip;
  final bool hasMenu;
  final VoidCallback onDrawerTapped;
  final VoidCallback onHelpTapped;
  final ValueChanged<int> onSelected; // Add this parameter
  final double newSize;
  final double titleFontSize;

  const NavigationBar({
    super.key,
    required this.title,
    required this.onDrawerTapped,
    required this.onHelpTapped,
    required this.onSelected, // Add this parameter
    this.newSize = 30.0,
    this.hasMenu = true,
    this.tooltip = 'help',
    this.titleFontSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.isLoggedIn;

    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconTheme(
                  data: IconThemeData(size: newSize),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasMenu)
                        IconButton(
                          icon: Icon(Icons.menu, color: colorScheme.onPrimary),
                          onPressed: onDrawerTapped,
                        ),
                      IconButton(
                        icon: Icon(Icons.help_outline, color: colorScheme.onPrimary),
                        tooltip: tooltip,
                        onPressed: onHelpTapped,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10.0),
                MediaQuery.of(context).size.width > 400
                    ? DefaultTextStyle(
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: titleFontSize),
                        child: Text(
                          title,
                          overflow: TextOverflow.ellipsis,
                        ),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            IconTheme(
              data: IconThemeData(size: newSize),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PopupMenuButton<int>(
                    icon: Icon(Icons.person, color: colorScheme.onPrimary),
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
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                      PopupMenuItem<int>(
                        value: 0,
                        child: ListTile(
                          leading: Icon(isLoggedIn ? Icons.logout : Icons.login, color: colorScheme.onPrimary),
                          title: Text(AppLocalizations.of(context)!.translate(isLoggedIn ? 'common.logout' : 'common.login')),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<Locale>(
                    icon: Icon(Icons.language, color: colorScheme.onPrimary),
                    onSelected: (Locale locale) {
                      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
                      localeProvider.setLocale(locale);
                    },
                    itemBuilder: (BuildContext context) {
                      final languageNames = {
                        'de': 'Deutsch',
                        'en': 'English',
                      };

                      return [
                        const Locale('de', ''),
                        const Locale('en', ''),
                      ].map((Locale locale) {
                        return PopupMenuItem<Locale>(
                          value: locale,
                          child: Text(languageNames[locale.languageCode] ?? locale.languageCode),
                        );
                      }).toList();
                    },
                    offset: const Offset(0, 40),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}