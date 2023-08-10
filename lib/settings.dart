import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

const sandboxEnabled = false;

class UserConfig {
  static final UserConfig _instance = UserConfig._internal();
  UserConfig._internal();
  factory UserConfig() => _instance;

  final user = FirebaseAuth.instance.currentUser;

  bool get replaceEmailWithUsernameOnWallPost => _configReplaceEmailWithUsernameOnWallPost;
  bool get enterSendsPost => _configEnterSendsPost;
  bool get enablePostComments => _configEnablePostComments;
  bool get darkMode => _configDarkMode;

  Future<void> init() async {
    final settings =
        await FirebaseFirestore.instance.collection('User Settings').doc(user?.email).get();

    if (settings.exists) {
      _configReplaceEmailWithUsernameOnWallPost =
          settings['replaceEmailWithUsernameOnWallPost'] ?? true;
      _configEnterSendsPost = settings['enterSendsPost'] ?? false;
      _configEnablePostComments = settings['enablePostComments'] ?? true;
      _configDarkMode = settings['darkMode'] ?? false;
    }
  }

  Future<void> saveSettings({
    bool? replaceEmailWithUsernameOnWallPost,
    bool? enterSendsPost,
    bool? enablePostComments,
    bool? darkMode,
  }) async {
    // stores new values to local
    _configReplaceEmailWithUsernameOnWallPost =
        replaceEmailWithUsernameOnWallPost ?? _configReplaceEmailWithUsernameOnWallPost;
    _configEnterSendsPost = enterSendsPost ?? _configEnterSendsPost;
    _configEnablePostComments = enablePostComments ?? _configEnablePostComments;
    _configDarkMode = darkMode ?? _configDarkMode;

    // save changes to database
    await FirebaseFirestore.instance.collection('User Settings').doc(user!.email).set({
      'replaceEmailWithUsernameOnWallPost':
          replaceEmailWithUsernameOnWallPost ?? _configReplaceEmailWithUsernameOnWallPost,
      'enterSendsPost': enterSendsPost ?? _configEnterSendsPost,
      'enablePostComments': enablePostComments ?? _configEnablePostComments,
      'darkMode': darkMode ?? _configDarkMode,
    });
  }

  var _configReplaceEmailWithUsernameOnWallPost = true;
  var _configEnterSendsPost = false;
  var _configEnablePostComments = true;
  var _configDarkMode = false;
}
