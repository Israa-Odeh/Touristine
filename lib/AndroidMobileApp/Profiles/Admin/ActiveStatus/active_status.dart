import 'package:cloud_firestore/cloud_firestore.dart';

void setAdminActiveStatus(String adminEmail, bool isActive) {
  FirebaseFirestore.instance
      .collection('admins_active_status')
      .doc(adminEmail)
      .update({
    'active': isActive,
    'lastUpdate': FieldValue.serverTimestamp(),
  }).catchError((_) {
    // If the document doesn't exist, it will be created.
    FirebaseFirestore.instance
        .collection('admins_active_status')
        .doc(adminEmail)
        .set({
      'active': isActive,
      'lastUpdate': FieldValue.serverTimestamp(),
    });
  });
}

Future<bool?> getTouristActiveStatus(String touristEmail) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('tourists_active_status')
        .doc(touristEmail)
        .get();

    if (snapshot.exists) {
      return snapshot.data()?['active'] as bool?;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching tourist status: $e');
    return null;
  }
}
