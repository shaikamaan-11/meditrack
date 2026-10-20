import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/medical_document.dart';
import '../../models/medical_record.dart';
import '../../services/firestore_service.dart';

class RecordDetailScreen extends StatefulWidget {
  final MedicalRecord record;

  const RecordDetailScreen({super.key, required this.record});

  @override
  State<RecordDetailScreen> createState() => _RecordDetailScreenState();
}

class _RecordDetailScreenState extends State<RecordDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<MedicalDocument> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    final docs = await _firestoreService.fetchDocumentsForRecord(widget.record.recordId);
    setState(() {
      _documents = docs;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Record details')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Doctor / Hospital', widget.record.doctorOrHospital),
                  _infoRow('Visit date', widget.record.visitDate.toLocal().toString().split(' ')[0]),
                  _infoRow('Reason', widget.record.reason),
                  _infoRow('Diagnosis', widget.record.diagnosis),
                  const SizedBox(height: 12),
                  const Text('Prescription', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.record.prescription),
                  const SizedBox(height: 20),
                  const Text('Attached documents', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (_documents.isEmpty)
                    const Text('No attachments')
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _documents.length,
                      itemBuilder: (context, index) {
                        final doc = _documents[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: Text(doc.fileName),
                            subtitle: Text(doc.fileType.toUpperCase()),
                            trailing: const Icon(Icons.open_in_new),
                            onTap: () async {
                              final messenger = ScaffoldMessenger.maybeOf(context);
                              final uri = Uri.parse(doc.fileUrl);
                              if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
                                if (!mounted) return;
                                messenger?.showSnackBar(
                                  const SnackBar(content: Text('Unable to open file.')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value),
        ],
      ),
    );
  }
}
