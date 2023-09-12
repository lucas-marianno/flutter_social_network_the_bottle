import 'package:firebase_auth/firebase_auth.dart';

bool isCurrentUser(String userEmail) {
  User? currentUser = FirebaseAuth.instance.currentUser;
  String? currentUserEmail = currentUser?.email;
  if (currentUser == null || currentUserEmail == null || currentUserEmail != userEmail) {
    return false;
  } else {
    return true;
  }
}
