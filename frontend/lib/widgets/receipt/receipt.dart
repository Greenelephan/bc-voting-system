import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../localizations/l10n.dart';

class ReceiptStatus extends StatefulWidget {
  final String? initialReceiptId;

  const ReceiptStatus({Key? key, this.initialReceiptId}) : super(key: key);

  @override
  _ReceiptStatusState createState() => _ReceiptStatusState();
}

class _ReceiptStatusState extends State<ReceiptStatus> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _response1;
  Map<String, dynamic>? _response2;

  @override
  void initState() {
    super.initState();
    if (widget.initialReceiptId != null) {
      _controller.text = widget.initialReceiptId!;
    }
  }

  Future<void> _fetchStatus() async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final receiptIds = _controller.text.split('#');
    if (receiptIds.length != 2) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('error.invalid_receipt_id'))));
      return;
    }

    try {
      // Get voterId (userId) from secure storage
      final secureStorage = FlutterSecureStorage();
      final voterId = await secureStorage.read(key: 'userId'); // Retrieve the voterId

      if (voterId == null) {
        throw Exception('Voter ID not found');
      }

      // Make the new API call with voterId and receiptId
      final response1 = await apiService.get('api/voters/$voterId/votes/${receiptIds[0]}', useAuth: true);
      final response2 = await apiService.get('api/voters/$voterId/votes/${receiptIds[1]}', useAuth: true);

      setState(() {
        _response1 = response1;
        _response2 = response2;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.translate('error.failed_to_fetch_status'))));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 300,
        child: Column(
          children: [
            if (_response1 != null) _buildResponseCard(_response1!, AppLocalizations.of(context)!.translate('receipt.first_election')),
            if (_response2 != null) _buildResponseCard(_response2!, AppLocalizations.of(context)!.translate('receipt.second_election')),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.translate('receipt.enter_receipt_id'),
              ),
            ),
            ElevatedButton(
              onPressed: _fetchStatus,
              child: Text(AppLocalizations.of(context)!.translate('common.send')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> response, String title) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          '${AppLocalizations.of(context)!.translate('receipt.status')}: ${response['status']}',
        ),
      ),
    );
  }
}