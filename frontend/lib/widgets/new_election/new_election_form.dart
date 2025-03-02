import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../localizations/l10n.dart';

class NewElectionForm extends StatefulWidget {
  const NewElectionForm({super.key});

  @override
  _NewElectionFormState createState() => _NewElectionFormState();
}

class _NewElectionFormState extends State<NewElectionForm> {
  final List<TextEditingController> _erstwahlCandidateControllers = [TextEditingController()];
  final List<TextEditingController> _zweitwahlCandidateControllers = [TextEditingController()];

  void _addCandidate(List<TextEditingController> controllers) {
    setState(() {
      controllers.add(TextEditingController());
    });
  }

  void _removeCandidate(List<TextEditingController> controllers, int index) {
    setState(() {
      controllers.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final erstwahlCandidates = _erstwahlCandidateControllers.map((controller) => {'name': controller.text}).toList();
    final zweitwahlCandidates = _zweitwahlCandidateControllers.map((controller) => {'name': controller.text}).toList();

    try {
      final erstwahlResponse = await apiService.post('api/admin/voting/initialize', {
        'title': 'Erstwahl',
        'candidates': erstwahlCandidates,
      }, useAuth: true);

      final zweitwahlResponse = await apiService.post('api/admin/voting/initialize', {
        'title': 'Zweitwahl',
        'candidates': zweitwahlCandidates,
      }, useAuth: true);

      setState(() {
        _erstwahlCandidateControllers.clear();
        _zweitwahlCandidateControllers.clear();
        _erstwahlCandidateControllers.add(TextEditingController());
        _zweitwahlCandidateControllers.add(TextEditingController());
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(AppLocalizations.of(context)!.translate('new_election.success_message')),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Erstwahl Response:'),
                Text('Voting ID: ${erstwahlResponse['votingId']}'),
                Text('Status: ${erstwahlResponse['status']}'),
                Text('Candidates Count: ${erstwahlResponse['candidatesCount']}'),
                Text('Timestamp: ${erstwahlResponse['timestamp']}'),
                SizedBox(height: 10),
                Text('Zweitwahl Response:'),
                Text('Voting ID: ${zweitwahlResponse['votingId']}'),
                Text('Status: ${zweitwahlResponse['status']}'),
                Text('Candidates Count: ${zweitwahlResponse['candidatesCount']}'),
                Text('Timestamp: ${zweitwahlResponse['timestamp']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/p/home');
                },
                child: Text(AppLocalizations.of(context)!.translate('common.ok')),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.translate('new_election.error'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Container(
        width: 800,
        color: colorScheme.surfaceContainer,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildCandidateColumn('Erstwahl', _erstwahlCandidateControllers, colorScheme),
            const SizedBox(height: 10),
            Container(
              width: 800,
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () => _addCandidate(_erstwahlCandidateControllers),
                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.secondary),
                child: Text(
                  AppLocalizations.of(context)!.translate('new_election.button_add_candidate'),
                  style: TextStyle(color: colorScheme.onSecondary),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildCandidateColumn('Zweitwahl', _zweitwahlCandidateControllers, colorScheme),
            const SizedBox(height: 20),
            Container(
              width: 800,
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _addCandidate(_zweitwahlCandidateControllers),
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.secondary),
                    child: Text(
                      AppLocalizations.of(context)!.translate('new_election.button_add_candidate'),
                      style: TextStyle(color: colorScheme.onSecondary),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary),
                    child: Text(
                      AppLocalizations.of(context)!.translate('new_election.button_submit'),
                      style: TextStyle(color: colorScheme.onPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandidateColumn(String title, List<TextEditingController> controllers, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...controllers.asMap().entries.map((entry) {
          final index = entry.key;
          final controller = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.translate('new_election.label_candidate'),
                      labelStyle: TextStyle(color: colorScheme.onSurface),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: colorScheme.secondary),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: colorScheme.error),
                  onPressed: () => _removeCandidate(controllers, index),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}