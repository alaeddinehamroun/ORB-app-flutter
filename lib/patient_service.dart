import 'dart:ffi';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class PatientService {
  static String? userId = "dLKr1teQlsmBOMwQB5tD";

  Future<void> toggleDevice(String device, bool deviceStatus) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference patientRef = db.collection('rooms').doc(userId);

    if (device == "lights") patientRef.update({'devices.lights': deviceStatus});
    if (device == "ac") patientRef.update({'devices.ac': deviceStatus});
    if (device == "tv") patientRef.update({'devices.tv': deviceStatus});
  }

  Future<void> toggleOnlieStatus(bool isOnline) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference patientRef = db.collection('patients').doc(userId);

    patientRef.update({'isOnline': isOnline});
  }

  Future<void> sendNotification(
      String notificationType, String notificationText) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference notificationRef =
        db.collection('patients').doc(userId).collection('notifications').doc();
    notificationRef.set({
      'type': notificationType,
      'text': notificationText,
      'date': DateTime.now().millisecondsSinceEpoch
    });
  }
  // Future<String> getNotification() {

  // }

  Future<void> sendFile(String notificationType, String filePath) async {
    final file = File(filePath);
    // Create the file metadata
    final metadata = SettableMetadata(contentType: "image/jpeg");
    // Create a reference to the Firebase Storage bucket
    final storageRef = FirebaseStorage.instance.ref();
    // Upload file and metadata to the path 'images/mountains.jpg'
    final uploadTask = storageRef
        .child("images/path/to/mountains.jpg")
        .putFile(file, metadata);

    // Listen for state changes, errors, and completion of the upload.
    uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          final progress =
              100.0 * (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
          print("Upload is $progress% complete.");
          break;
        case TaskState.paused:
          print("Upload is paused.");
          break;
        case TaskState.canceled:
          print("Upload was canceled");
          break;
        case TaskState.error:
          // Handle unsuccessful uploads
          break;
        case TaskState.success:
          // Handle successful uploads on complete
          // ...
          break;
      }
    });

    // String fileUrl =
    //     await storageRef.child("images/path/to/mountains.jpg").getDownloadURL();

    // FirebaseFirestore db = FirebaseFirestore.instance;
    // DocumentReference patientRef = db.collection('rooms').doc(userId);

    // patientRef.update({'files': fileUrl});
  }
}
