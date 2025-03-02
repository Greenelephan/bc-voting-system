import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../widgets/custom_icon_button/custom_icon_button.dart';

class PublicElectionHomeDesktop extends StatefulWidget {
  const PublicElectionHomeDesktop({super.key});

  @override
  _PublicElectionHomeDesktopState createState() => _PublicElectionHomeDesktopState();
}

class _PublicElectionHomeDesktopState extends State<PublicElectionHomeDesktop> {
  late ApiService apiService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? erstwahlId;
  String? zweitwahlId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    apiService = Provider.of<ApiService>(context, listen: false);
    _fetchVotingData();
  }

  Future<void> _fetchVotingData() async {
    try {
      final data = await apiService.get('api/voting/open');
      setState(() {
        final openVotings = data['openVotings'];
        erstwahlId = openVotings.firstWhere((voting) => voting['title'] == 'Erstwahl')['votingId'];
        zweitwahlId = openVotings.firstWhere((voting) => voting['title'] == 'Zweitwahl')['votingId'];
      });
      await secureStorage.write(key: 'erstwahlId', value: erstwahlId);
      await secureStorage.write(key: 'zweitwahlId', value: zweitwahlId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load voting data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (erstwahlId == null || zweitwahlId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return BaseView(
      title: AppLocalizations.of(context)!.translate('public_election_home.title'),
      tooltip: AppLocalizations.of(context)!.translate('public_election_home.tooltip_public_election_info'),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 70.0),
          child: Center(
            child: DefaultTextStyle(
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.0,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  AppLocalizations.of(context)!.translate('public_election_home.description'),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        Center(
          child: CustomIconButton(
            buttonSize: 250.0,
            icon: Icons.how_to_vote, // Example icon
            text: AppLocalizations.of(context)!.translate('public_election_home.vote_button'),
            tooltip: AppLocalizations.of(context)!.translate('public_election_home.vote_tooltip'),
            onPressed: () {
              Navigator.of(context).pushNamed('/p/election/1');
            },
          ),
        ),
        const SizedBox(height: 40),
        Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/home');
              },
              child: Text(AppLocalizations.of(context)!.translate('common.back')),
            ),
          ),
        ),
      ],
    );
  }
}