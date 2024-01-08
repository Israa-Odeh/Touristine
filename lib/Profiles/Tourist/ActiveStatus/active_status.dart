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
    FirebaseFirestore.instance
        .collection('tourists_active_status')
        .doc(touristEmail)
        .set({
      'active': isActive,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  });
}

Future<bool?> getAdminActiveStatus(String adminEmail) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('admins_active_status')
        .doc(adminEmail)
        .get();

    if (snapshot.exists) {
      return snapshot.data()?['active'] as bool?;
    } else {
      return null;
    }
  } catch (e) {
    print('admins_active_status: $e');
    return null;
  }
}
