import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../localizations/l10n.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../views/receipt/receipt_view.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final voterIdController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            width: 300,
            child: Tooltip(
              message: AppLocalizations.of(context)!.translate('registration.tooltip_voterid'),
              child: TextField(
                controller: voterIdController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.translate('registration.label_voterid'),
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
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: 300,
            child: TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('registration.label_password'),
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
            child: TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('registration.label_confirm_password'),
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
          ElevatedButton(
            onPressed: () {
              register(context, voterIdController.text, passwordController.text, confirmPasswordController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary, // background color
            ),
            child: Text(
              AppLocalizations.of(context)!.translate('registration.button_register'),
              style: TextStyle(
                color: colorScheme.onSecondary, // text color
              ),
            ),
          ),
        ],
      ),
    );
  }

  void register(BuildContext context, String voterId, String password, String confirmPassword) {
  if (password != confirmPassword) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.translate('registration.error_password_mismatch'))),
    );
    return;
  }

  final authProvider = Provider.of<AuthProvider>(context, listen: false);

  authProvider.login(voterId, password).then((result) {
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
          SnackBar(content: Text(AppLocalizations.of(context)!.translate('registration.error_registration_failed'))),
        );
        break;
    }
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Registration failed: $error')),
    );
  });
  }
}