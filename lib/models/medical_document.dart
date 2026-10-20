import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalDocument {
  final String documentId;
  final String recordId;
  final String patientId;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final DateTime uploadedAt;

  MedicalDocument({
    required this.documentId,
    required this.recordId,
    required this.patientId,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.uploadedAt,
  });

  factory MedicalDocument.fromMap(String documentId, Map<String, dynamic> data) {
    return MedicalDocument(
      documentId: documentId,
      recordId: (data['recordId'] ?? '').toString(),
      patientId: (data['patientId'] ?? '').toString(),
      fileName: (data['fileName'] ?? '').toString(),
      fileUrl: (data['fileUrl'] ?? '').toString(),
      fileType: (data['fileType'] ?? '').toString(),
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recordId': recordId,
      'patientId': patientId,
      'fileName': fileName,
      'fileUrl': fileUrl,
      'fileType': fileType,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}
