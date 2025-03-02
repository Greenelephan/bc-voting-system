import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../localizations/l10n.dart';

class ResultsAdmin extends StatefulWidget {
  const ResultsAdmin({Key? key}) : super(key: key);

  @override
  ResultsAdminState createState() => ResultsAdminState();
}

class ResultsAdminState extends State<ResultsAdmin> {
  List<dynamic>? _results;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final response = await apiService.getAsList('api/admin/voting/statistics', useAuth: true);

      if (!mounted) return;

      setState(() {
        _results = response;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('public_election_results.error'))),
      );
      print('Error fetching results: $e');
    }
  }

  Widget _buildCandidatesList(List candidates) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: candidates.map((candidate) =>
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text('${candidate['name']}: ${candidate['votes']} votes'),
        ),
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      child: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_results != null && _results!.isNotEmpty)
                  ..._results!.map((result) =>
                    Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Voting ID: ${result['votingId']}'),
                            Text('Status: ${result['status']}'),
                            Text('Total Votes: ${result['totalVotes']}'),
                            Text('Total Registered Voters: ${result['totalRegisteredVoters']}'),
                            const SizedBox(height: 8),
                            const Text('Candidates:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            _buildCandidatesList(result['candidates'] as List),
                            const SizedBox(height: 8),
                            Text('Timestamp: ${result['timestamp']}'),
                          ],
                        ),
                      ),
                    ),
                  ).toList()
                else
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.translate('public_election_results.no_results')
                    ),
                  ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _fetchResults,
                    child: Text(
                      AppLocalizations.of(context)!.translate('public_election_results.refresh')
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
