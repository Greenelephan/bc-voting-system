import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/views/close_election_admin/close_election.dart';
import 'package:frontend/views/election_preview/election_preview_desktop.dart';
import 'package:frontend/views/election_preview/election_preview_mobile.dart';
import 'package:frontend/views/election_preview/election_preview_tablet.dart';
import 'package:frontend/views/home_admin/home_admin_desktop.dart';
import 'package:frontend/views/home_admin/home_admin_mobile.dart';
import 'package:frontend/views/home_admin/home_admin_tablet.dart';
import 'package:frontend/views/login/login_view_desktop.dart';
import 'package:frontend/views/login/login_view_mobile.dart';
import 'package:frontend/views/login/login_view_tablet.dart';
import 'package:frontend/views/new_election_admin/new_election_admin_desktop.dart';
import 'package:frontend/views/public_election/public_%20election_1_desktop.dart';
import 'package:frontend/views/public_election/public_%20election_2_desktop.dart';
import 'package:frontend/views/public_election_home/public_election_home_desktop.dart';
import 'package:frontend/views/public_election_home/public_election_home_mobile.dart';
import 'package:frontend/views/public_election_home/public_election_home_tablet.dart';
import 'package:frontend/views/receipt/receipt_view.dart';
import 'package:frontend/views/registration/registration_view_desktop.dart';
import 'package:frontend/views/registration/registration_view_mobile.dart';
import 'package:frontend/views/registration/registration_view_tablet.dart';
import 'package:frontend/views/results_admin/results_admin_desktop.dart';
import 'package:frontend/views/results_admin/results_admin_mobile.dart';
import 'package:frontend/views/results_admin/results_admin_tablet.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:frontend/views/home/home_view_tablet.dart';
import 'providers/locale_provider.dart';
import 'localizations/l10n.dart';
import 'views/home/home_view_mobile.dart';
import 'views/home/home_view_desktop.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocaleProvider(const Locale('de', ''))),
        Provider<ApiService>(
          create: (_) => ApiService(baseUrl: 'http://127.0.0.1:8080'),
        ),
        ChangeNotifierProxyProvider<ApiService, AuthProvider>(
          create: (context) => AuthProvider(apiService: Provider.of<ApiService>(context, listen: false)),
          update: (context, apiService, authProvider) => AuthProvider(apiService: apiService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      locale: localeProvider.locale,
      title: "My App",
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary: Colors.lightGreen.shade800,
          secondary: Colors.lightGreen.shade500,
          surface: Colors.grey.shade900,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          surfaceContainer: Colors.grey.shade800,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de', ''),
        Locale('en', ''),
      ],
      home: ScreenTypeLayout.builder(
        mobile: (BuildContext context) => const HomeViewMobile(),
        desktop: (BuildContext context) => const HomeViewDesktop(),
        tablet: (BuildContext context) => const HomeViewTablet(),
      ),
      routes: {
        '/home': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const HomeViewMobile(),
          desktop: (BuildContext context) => const HomeViewDesktop(),
          tablet: (BuildContext context) => const HomeViewTablet(),
        ),
        '/p/login': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const LoginViewMobile(),
          desktop: (BuildContext context) => const LoginViewDesktop(),
          tablet: (BuildContext context) => const LoginViewTablet(),
        ),
        '/p/registration': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const RegistrationViewMobile(),
          desktop: (BuildContext context) => const RegistrationViewDesktop(),
          tablet: (BuildContext context) => const RegistrationViewTablet(),
        ),
        '/p/election': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const PublicElectionHomeMobile(),
          desktop: (BuildContext context) => const PublicElectionHomeDesktop(),
          tablet: (BuildContext context) => const PublicElectionHomeTablet(),
        ),
        '/p/election/1': (BuildContext context) => const PublicElection1Desktop(),
        '/p/election/2': (BuildContext context) => const PublicElection2Desktop(),
        '/p/election/preview': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const PublicElectionPreviewMobile(),
          desktop: (BuildContext context) => const PublicElectionPreviewDesktop(),
          tablet: (BuildContext context) => const PublicElectionPreviewTablet(),
        ),
        '/p/receipt': (BuildContext context) => const ReceiptView(),
        '/p/new_election': (BuildContext context) => const NewElectionAdminDesktop(),
        '/p/close_election': (BuildContext context) => const CloseElectionAdminDesktop(),
        '/p/results': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const ResultsAdminMobile(),
          desktop: (BuildContext context) => const ResultsAdminDesktop(),
          tablet: (BuildContext context) => const ResultsAdminTablet(),
        ),
        '/p/home': (context) => ScreenTypeLayout.builder(
          mobile: (BuildContext context) => const HomeAdminMobile(),
          desktop: (BuildContext context) => const HomeAdminDesktop(),
          tablet: (BuildContext context) => const HomeAdminTablet(),
        )
      }
    );
  }
}