import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commonFirebaseStorageRepositoryProvider = Provider((ref) =>
    CommonFirebaseStorageRepository(firebaseStorage: FirebaseStorage.instance));

class CommonFirebaseStorageRepository {
  final FirebaseStorage firebaseStorage;

  CommonFirebaseStorageRepository({
    required this.firebaseStorage,
  });

  Future<String> storeFileToFirebase(
    String ref,
    File file,
  ) async {
    // Create an upload task with the specified reference path and file
    UploadTask uploadTask = firebaseStorage.ref().child(ref).putFile(file);
    // Wait for the upload task to complete and get the task snapshot
    TaskSnapshot snap = await uploadTask;
    // Retrieve the download URL of the uploaded file
    String downloadUrl = await snap.ref.getDownloadURL();
    return downloadUrl;
  }
}
