import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> getUserName(String userEmail) async {
  final data = await FirebaseFirestore.instance.collection('User Profile').doc(userEmail).get();
  final username = data.data()?['username'];
  return username ?? userEmail;
}
