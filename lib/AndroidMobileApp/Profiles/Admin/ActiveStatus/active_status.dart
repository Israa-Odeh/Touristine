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

Future<bool?> getCoordinatorActiveStatus(String coordinatorEmail) async {
  try {
    DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('admins_active_status')
        .doc(coordinatorEmail)
        .get();

    if (snapshot.exists) {
      return snapshot.data()?['active'] as bool?;
    } else {
      return null;
    }
  } catch (e) {
    print('Error fetching coordinator status: $e');
    return null;
  }
}
