import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../localizations/l10n.dart';
import 'new_election_form.dart';

class NewElectionFormWrapper extends StatefulWidget {
  const NewElectionFormWrapper({super.key});

  @override
  _NewElectionFormWrapperState createState() => _NewElectionFormWrapperState();
}

class _NewElectionFormWrapperState extends State<NewElectionFormWrapper> {
  bool _hasOpenVotings = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkForOpenVotings();
  }

  Future<void> _checkForOpenVotings() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.get('api/voting/open');

      setState(() {
        _hasOpenVotings = response['openVotings'].isNotEmpty;
        _isLoading = false;
      });
    } catch (e) {

      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('new_election.error_checking_votings'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_hasOpenVotings) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.translate('new_election.close_open_votings_first'),
          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.error),
        ),
      );
    }

    return NewElectionForm();
  }
}