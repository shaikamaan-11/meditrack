import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecord {
  final String recordId;
  final String patientId;
  final String doctorOrHospital;
  final DateTime visitDate;
  final String reason;
  final String diagnosis;
  final String prescription;
  final String addedBy;
  final DateTime createdAt;

  MedicalRecord({
    required this.recordId,
    required this.patientId,
    required this.doctorOrHospital,
    required this.visitDate,
    required this.reason,
    required this.diagnosis,
    required this.prescription,
    required this.addedBy,
    required this.createdAt,
  });

  factory MedicalRecord.fromMap(String recordId, Map<String, dynamic> data) {
    return MedicalRecord(
      recordId: recordId,
      patientId: (data['patientId'] ?? '').toString(),
      doctorOrHospital: (data['doctorOrHospital'] ?? '').toString(),
      visitDate: (data['visitDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reason: (data['reason'] ?? '').toString(),
      diagnosis: (data['diagnosis'] ?? '').toString(),
      prescription: (data['prescription'] ?? '').toString(),
      addedBy: (data['addedBy'] ?? '').toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientId': patientId,
      'doctorOrHospital': doctorOrHospital,
      'visitDate': Timestamp.fromDate(visitDate),
      'reason': reason,
      'diagnosis': diagnosis,
      'prescription': prescription,
      'addedBy': addedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
