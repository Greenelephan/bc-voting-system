import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:frontend/services/api_service.dart';
import '../../localizations/l10n.dart';

class FirstElection extends StatefulWidget {
  final String votingId;

  const FirstElection({required this.votingId});

  @override
  _FirstElectionState createState() => _FirstElectionState();
}

class _FirstElectionState extends State<FirstElection> {
  late ApiService apiService;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  int? _selectedCandidateId;
  Map<String, dynamic>? _votingData;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      apiService = Provider.of<ApiService>(context, listen: false);
      _fetchVotingStatus();
    });
  }

  Future<void> _fetchVotingStatus() async {
    try {
      final data = await apiService.get('api/voting/status/${widget.votingId}');
      setState(() {
        _votingData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.translate('error.failed_to_load_data');
      });
    }
  }

  void _storeVote(int candidateId, String candidateName) async {
    await secureStorage.write(key: 'selectedVote1', value: candidateId.toString());
    await secureStorage.write(key: 'selectedVote1Name', value: candidateName);
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_votingData == null) {
      return Center(child: CircularProgressIndicator());
    } else if (_votingData!['status'] == 'closed') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/home');
      });
      return Center(child: Text('Voting is closed.'));
    } else {
      final candidates = _votingData!['candidates'];
      if (candidates == null || candidates.isEmpty) {
        return Center(child: Text(AppLocalizations.of(context)!.translate('error.no_candidates')));
      }

      return Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            children: candidates.map<Widget>((candidate) {
              return RadioListTile<int>(
                title: Text('Candidate: ${candidate['name']} (ID: ${candidate['id']})'),
                value: candidate['id'],
                groupValue: _selectedCandidateId,
                onChanged: (int? value) {
                  setState(() {
                    _selectedCandidateId = value;
                    if (value != null) {
                      _storeVote(value, candidate['name']);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ),
      );
    }
  }
}