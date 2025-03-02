import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/views/base_view/base_view.dart';
import 'package:frontend/widgets/first_election/first_election.dart';
import '../../localizations/l10n.dart';

class PublicElection1Desktop extends StatefulWidget {
  const PublicElection1Desktop({Key? key}) : super(key: key);

  @override
  _PublicElection1DesktopState createState() => _PublicElection1DesktopState();
}

class _PublicElection1DesktopState extends State<PublicElection1Desktop> {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  String? erstwahlId;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchVotingIds();
  }

  Future<void> _fetchVotingIds() async {
    try {
      final fetchedErstwahlId = await secureStorage.read(key: 'erstwahlId');
      setState(() {
        erstwahlId = fetchedErstwahlId;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load voting IDs';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (erstwahlId == null) {
      return Center(child: CircularProgressIndicator());
    }

    return BaseView(
      title: AppLocalizations.of(context)!.translate('public_election_1.title'),
      tooltip: AppLocalizations.of(context)!.translate('public_election_1.tooltip_public_election_info'),
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
                  AppLocalizations.of(context)!.translate('public_election_1.description'),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
          ),
        ),
        FirstElection(votingId: erstwahlId!),
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
                    Navigator.of(context).pushNamed('/p/election/2');
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