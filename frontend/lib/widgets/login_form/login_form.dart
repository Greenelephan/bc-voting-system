import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localizations/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../views/receipt/receipt_view.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: Text(AppLocalizations.of(context)!.translate('login.text_login')),
          ),
          SizedBox(
            width: 300,
            child: TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('login.label_username'),
                labelStyle: TextStyle(
                  color: colorScheme.onSurface,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('login.label_password'),
                labelStyle: TextStyle(
                  color: colorScheme.onSurface,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: colorScheme.secondary,
                  ),
                ),
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            child: ElevatedButton(
              onPressed: () {
                login(context, usernameController.text, passwordController.text);
              },
              child: Text(AppLocalizations.of(context)!.translate('login.button_login')),
            ),
          ),
        ],
      ),
    );
  }

  void login(BuildContext context, String username, String password) {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  authProvider.login(username, password).then((result) {
    switch (result) {
      case AuthResult.admin:
        Navigator.of(context).pushNamed('/p/home');
        break;
      case AuthResult.election:
        Navigator.of(context).pushNamed('/p/election');
        break;
      case AuthResult.receipt:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ReceiptView(initialReceiptId: null), // Pass the receipt ID here or null
          ),
        );
        break;
      case AuthResult.error:
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed')),
        );
        break;
    }
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $error')),
    );
  });
}
}