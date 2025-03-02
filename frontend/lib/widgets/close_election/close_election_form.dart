import 'package:flutter/material.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';

class CloseElectionForm extends StatefulWidget {
  const CloseElectionForm({Key? key}) : super(key: key);

  @override
  _CloseElectionFormState createState() => _CloseElectionFormState();
}

class _CloseElectionFormState extends State<CloseElectionForm> {
  List<Map<String, dynamic>> openVotings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOpenVotings();
  }

  Future<void> fetchOpenVotings() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final data = await apiService.get('api/voting/open');
      if (data['openVotings'] == null) {
        setState(() {
          openVotings = [];
          isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> votings = List<Map<String, dynamic>>.from(data['openVotings']);
      // Fetch status for each voting
      for (var voting in votings) {
        if (voting['votingId'] != null) {
          final statusData = await apiService.get('api/voting/status/${voting['votingId']}', useAuth: true);
          voting.addAll(statusData);
        }
      }

      setState(() {
        openVotings = votings;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching open votings: $e');
      setState(() {
        openVotings = [];
        isLoading = false;
      });
    }
  }

  Future<void> finalizeVoting(String votingId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.post('api/admin/voting/finalize/$votingId', {}, useAuth: true);
      await fetchOpenVotings(); // Ensure data is refetched after finalizing
    } catch (e) {
      // Handle error
    }
  }

  void showFinalizeConfirmationDialog(Map<String, dynamic> voting) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.translate('common.confirm')),
          content: Text(AppLocalizations.of(context)!.translate('close_election.confirm_finalize')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.translate('common.cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await finalizeVoting(voting['votingId']);
              },
              child: Text(AppLocalizations.of(context)!.translate('common.yes')),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else
              ...openVotings.map((voting) {
                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                  child: ListTile(
                    title: Text(voting['title']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Voting ID: ${voting['votingId']}'),
                        Text('Status: ${voting['status']}'),
                        Text('Total Votes: ${voting['totalVotes']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => showFinalizeConfirmationDialog(voting),
                      child: Text(AppLocalizations.of(context)!.translate('close_election.finalize_button')),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
