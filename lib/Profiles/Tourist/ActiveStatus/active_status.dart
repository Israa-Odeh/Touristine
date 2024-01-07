import 'package:cloud_firestore/cloud_firestore.dart';

void setUserActiveStatus(String touristEmail, bool isActive) {
  FirebaseFirestore.instance
      .collection('user_status')
      .doc(touristEmail)
      .update({
    'active': isActive,
    'lastUpdate': FieldValue.serverTimestamp(),
  }).catchError((_) {
    // If the document doesn't exist, it will be created.
    FirebaseFirestore.instance.collection('user_status').doc(touristEmail).set({
      'active': isActive,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  });
}
