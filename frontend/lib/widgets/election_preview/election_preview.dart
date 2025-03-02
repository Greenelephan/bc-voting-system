import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/localizations/l10n.dart';
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';

import '../../views/receipt/receipt_view.dart';

class ElectionPreview extends StatelessWidget {
  const ElectionPreview({Key? key}) : super(key: key);

  Future<Map<String, String?>> _fetchSelectedVotes() async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    final selectedVote1 = await secureStorage.read(key: 'selectedVote1');
    final selectedVote1Name = await secureStorage.read(key: 'selectedVote1Name');
    final selectedVote2 = await secureStorage.read(key: 'selectedVote2');
    final selectedVote2Name = await secureStorage.read(key: 'selectedVote2Name');
    return {
      'selectedVote1': selectedVote1,
      'selectedVote1Name': selectedVote1Name,
      'selectedVote2': selectedVote2,
      'selectedVote2Name': selectedVote2Name,
    };
  }

  Future<void> _completeElection(BuildContext context) async {
    final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      // Fetch registration token
      final registrationToken = await secureStorage.read(key: 'registrationToken');
      if (registrationToken == null) throw Exception('Registration token not found');

      // Verify and get voting token

      // Fetch voting IDs and candidate IDs
      final erstwahlId = await secureStorage.read(key: 'erstwahlId');
      final zweitwahlId = await secureStorage.read(key: 'zweitwahlId');
      final selectedVote1 = await secureStorage.read(key: 'selectedVote1');
      final selectedVote2 = await secureStorage.read(key: 'selectedVote2');
      if (erstwahlId == null || zweitwahlId == null || selectedVote1 == null || selectedVote2 == null) {
        throw Exception('Voting data not found');
      }

      // Send votes
      final voteResponse1 = await apiService.post('api/voters/vote', {'votingId': erstwahlId, 'candidateId': int.parse(selectedVote1)}, useAuth: true);
      final voteResponse2 = await apiService.post('api/voters/vote', {'votingId': zweitwahlId, 'candidateId': int.parse(selectedVote2)}, useAuth: true);
      if (voteResponse2['success'] != true) throw Exception('Failed to submit votes');

      // Remove data from secure storage
      await secureStorage.delete(key: 'erstwahlId');
      await secureStorage.delete(key: 'zweitwahlId');
      await secureStorage.delete(key: 'selectedVote1');
      await secureStorage.delete(key: 'selectedVote1Name');
      await secureStorage.delete(key: 'selectedVote2');
      await secureStorage.delete(key: 'selectedVote2Name');

      // Display receipt ID and redirect to receipt page
      final receiptId1 = voteResponse1['receiptId'];
      final receiptId2 = voteResponse2['receiptId'];
      final concatenatedReceiptId = '$receiptId1#$receiptId2';
      _showReceiptDialog(context, concatenatedReceiptId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('error.failed_to_complete_election'))));
    }
  }

  void _showReceiptDialog(BuildContext context, String concatenatedReceiptId) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(AppLocalizations.of(context)!.translate('receipt.dialog_title')),
        content: Text('${AppLocalizations.of(context)!.translate('receipt.receipt_id')} \n $concatenatedReceiptId'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ReceiptView(initialReceiptId: concatenatedReceiptId),
                ),
              );
            },
            child: Text(AppLocalizations.of(context)!.translate('common.ok')),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String?>>(
      future: _fetchSelectedVotes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text(AppLocalizations.of(context)!.translate('error.failed_to_load_data')));
        } else {
          final selectedVotes = snapshot.data!;
          return Column(
            children: [
              Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.translate('public_election_preview.first_election')),
                  subtitle: Text(
                    '${AppLocalizations.of(context)!.translate('public_election_preview.candidate')}: ${selectedVotes['selectedVote1Name'] ?? AppLocalizations.of(context)!.translate('election_preview.not_selected')} (ID: ${selectedVotes['selectedVote1'] ?? AppLocalizations.of(context)!.translate('election_preview.not_selected')})',
                  ),
                ),
              ),
              Card(
                color: Theme.of(context).colorScheme.surfaceContainer,
                child: ListTile(
                  title: Text(AppLocalizations.of(context)!.translate('public_election_preview.second_election')),
                  subtitle: Text(
                    '${AppLocalizations.of(context)!.translate('public_election_preview.candidate')}: ${selectedVotes['selectedVote2Name'] ?? AppLocalizations.of(context)!.translate('election_preview.not_selected')} (ID: ${selectedVotes['selectedVote2'] ?? AppLocalizations.of(context)!.translate('election_preview.not_selected')})',
                  ),
                ),
              ),
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
                        onPressed: () => _completeElection(context),
                        child: Text(AppLocalizations.of(context)!.translate('public_election_preview.button_preview_election')),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }
}
