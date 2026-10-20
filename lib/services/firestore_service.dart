import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../models/app_user.dart';
import '../models/medical_document.dart';
import '../models/medical_record.dart';
import '../models/patient_profile.dart';

class FirestoreService {
  FirebaseFirestore? _db;

  FirestoreService() {
    if (Firebase.apps.isNotEmpty) {
      _db = FirebaseFirestore.instance;
    }
  }

  FirebaseFirestore get db => _db ?? _throwNoApp();

  FirebaseFirestore _throwNoApp() {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'no-app',
      message: 'No Firebase app has been initialized.',
    );
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _patientsCollection() =>
      db.collection('patients');

  CollectionReference<Map<String, dynamic>> _recordsCollection() =>
      db.collection('records');

  CollectionReference<Map<String, dynamic>> _documentsCollection() =>
      db.collection('documents');

  Future<void> saveUserProfile(AppUser user) async {
    await _userDoc(user.uid).set(user.toMap(), SetOptions(merge: true));
  }

  Future<AppUser?> fetchUser(String uid) async {
    final snap = await _userDoc(uid).get();
    if (!snap.exists) return null;
    return AppUser.fromMap(uid, snap.data() ?? {});
  }

  Future<void> savePatientProfile(String uid, PatientProfile profile) async {
    await _patientsCollection().doc(uid).set(profile.toMap(), SetOptions(merge: true));
  }

  Future<PatientProfile?> fetchPatientProfile(String uid) async {
    final snap = await _patientsCollection().doc(uid).get();
    if (!snap.exists) return null;
    return PatientProfile.fromMap(uid, snap.data() ?? {});
  }

  Future<void> updateUserActiveStatus(String uid, bool isActive) async {
    await _userDoc(uid).update({'isActive': isActive});
  }

  Future<void> deleteUser(String uid) async {
    await _userDoc(uid).delete();
    await _patientsCollection().doc(uid).delete();
  }

  Future<List<AppUser>> fetchUsersByRole(String role) async {
    final snap = await db
        .collection('users')
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .get();

    return snap.docs
        .map((doc) => AppUser.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<AppUser>> fetchAllUsers() async {
    final snap = await db.collection('users').orderBy('createdAt', descending: true).get();
    return snap.docs.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> addRecord(MedicalRecord record) async {
    final ref = _recordsCollection().doc(record.recordId);
    await ref.set(record.toMap());
  }

  Future<void> updateRecord(MedicalRecord record) async {
    await _recordsCollection().doc(record.recordId).update(record.toMap());
  }

  Future<void> deleteRecord(String recordId) async {
    await _recordsCollection().doc(recordId).delete();
    final docs = await _documentsCollection().where('recordId', isEqualTo: recordId).get();
    for (final doc in docs.docs) {
      await doc.reference.delete();
    }
  }

  Future<List<MedicalRecord>> fetchRecordsForPatient(String patientId) async {
    final snap = await _recordsCollection()
        .where('patientId', isEqualTo: patientId)
        .orderBy('visitDate', descending: true)
        .get();

    return snap.docs
        .map((doc) => MedicalRecord.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<List<MedicalRecord>> fetchAllRecords() async {
    final snap = await _recordsCollection().orderBy('visitDate', descending: true).get();
    return snap.docs.map((doc) => MedicalRecord.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<AppUser>> searchPatientsByNameOrEmail(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      return fetchUsersByRole('Patient');
    }

    final snap = await db
        .collection('users')
        .where('role', isEqualTo: 'Patient')
        .get();

    final matches = snap.docs.where((doc) {
      final data = doc.data();
      final name = (data['name'] ?? '').toString().toLowerCase();
      final email = (data['email'] ?? '').toString().toLowerCase();
      final needle = q.toLowerCase();
      return name.contains(needle) || email.contains(needle);
    }).toList();

    return matches.map((doc) => AppUser.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<MedicalDocument>> fetchDocumentsForRecord(String recordId) async {
    final snap = await _documentsCollection().where('recordId', isEqualTo: recordId).get();
    return snap.docs.map((doc) => MedicalDocument.fromMap(doc.id, doc.data())).toList();
  }

  Future<void> saveDocument(MedicalDocument document) async {
    await _documentsCollection().doc(document.documentId).set(document.toMap());
  }
}
