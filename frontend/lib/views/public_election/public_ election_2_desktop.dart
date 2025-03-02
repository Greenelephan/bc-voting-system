import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/widgets/second_election/second_election.dart';
import '../../localizations/l10n.dart';

class PublicElection2Desktop extends StatefulWidget {
  const PublicElection2Desktop({Key? key}) : super(key: key);

  @override
  _PublicElection2DesktopState createState() => _PublicElection2DesktopState();
}

class _PublicElection2DesktopState extends State<PublicElection2Desktop> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? zweitwahlId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVotingId();
  }

  Future<void> _fetchVotingId() async {
    try {
      final fetchedZweitwahlId = await secureStorage.read(key: 'zweitwahlId');
      setState(() {
        zweitwahlId = fetchedZweitwahlId;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load voting ID';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (zweitwahlId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return BaseView(
      title: AppLocalizations.of(context)!.translate('public_election_2.title'),
      tooltip: AppLocalizations.of(context)!.translate('public_election_2.tooltip_public_election_info'),
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
            child: DefaultTextStyle(
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.0,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  AppLocalizations.of(context)!.translate('public_election_2.description'),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        ),
        SecondElection(votingId: zweitwahlId!),
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
                    Navigator.of(context).pushNamed('/p/election/preview');
                  },
                  child: Text(AppLocalizations.of(context)!.translate('common.next')),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}