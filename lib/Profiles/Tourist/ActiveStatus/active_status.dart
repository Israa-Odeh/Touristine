import 'package:cloud_firestore/cloud_firestore.dart';

void setTouristActiveStatus(String touristEmail, bool isActive) {
  FirebaseFirestore.instance
      .collection('tourists_active_status')
      .doc(touristEmail)
      .update({
    'active': isActive,
    'lastUpdate': FieldValue.serverTimestamp(),
  }).catchError((_) {
    // If the document doesn't exist, it will be created.
    FirebaseFirestore.instance.collection('tourists_active_status').doc(touristEmail).set({
      'active': isActive,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  });
}
