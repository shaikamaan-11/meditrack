import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../models/medical_document.dart';

class StorageService {
  FirebaseStorage? _storage;
  final Uuid _uuid = const Uuid();

  StorageService() {
    if (Firebase.apps.isNotEmpty) {
      _storage = FirebaseStorage.instance;
    }
  }

  FirebaseStorage get storage => _storage ?? _throwNoApp();

  FirebaseStorage _throwNoApp() {
    throw FirebaseException(
      plugin: 'firebase_storage',
      code: 'no-app',
      message: 'No Firebase app has been initialized.',
    );
  }

  Future<MedicalDocument?> uploadDocumentForRecord({
    required String patientId,
    required String recordId,
    required String userId,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
      withData: false,
    );

    if (result == null || result.files.isEmpty) return null;

    final selectedFile = result.files.first;
    final filePath = selectedFile.path;
    if (filePath == null) return null;

    final file = File(filePath);
    final bytes = await file.length();
    const maxBytes = 5 * 1024 * 1024;
    if (bytes > maxBytes) {
      throw Exception('File exceeds the 5 MB limit.');
    }

    final extension = selectedFile.extension ?? 'bin';
    final safeType = selectedFile.extension != null && selectedFile.extension!.isNotEmpty
        ? selectedFile.extension!
        : 'file';

    final fileName = '${_uuid.v4()}.$extension';
    final ref = storage.ref().child('patients/$patientId/records/$recordId/$fileName');

    final uploadTask = await ref.putFile(file);
    final url = await uploadTask.ref.getDownloadURL();

    final document = MedicalDocument(
      documentId: _uuid.v4(),
      recordId: recordId,
      patientId: patientId,
      fileName: selectedFile.name,
      fileUrl: url,
      fileType: safeType,
      uploadedAt: DateTime.now(),
    );

    return document;
  }
}
