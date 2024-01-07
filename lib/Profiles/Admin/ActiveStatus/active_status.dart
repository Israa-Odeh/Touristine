import 'package:cloud_firestore/cloud_firestore.dart';

void setAdminActiveStatus(String adminEmail, bool isActive) {
  FirebaseFirestore.instance
      .collection('Admins_active_status')
      .doc(adminEmail)
      .update({
    'active': isActive,
    'lastUpdate': FieldValue.serverTimestamp(),
  }).catchError((_) {
    // If the document doesn't exist, it will be created.
    FirebaseFirestore.instance.collection('Admins_active_status').doc(adminEmail).set({
      'active': isActive,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  });
}
