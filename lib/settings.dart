const sandboxEnabled = false;

// class UserConfig {
//   static final UserConfig _instance = UserConfig._internal();
//   UserConfig._internal();
//   factory UserConfig() => _instance;

//   final user = FirebaseAuth.instance.currentUser!;

//   bool get enterSendsPost => _configEnterSendsPost;

//   bool get darkMode => _configDarkMode;

//   Future<void> init() async {
//     final settings =
//         await FirebaseFirestore.instance.collection('User Settings').doc(user.email).get();

//     if (settings.exists) {
//       _configEnterSendsPost = settings['enterSendsPost'] ?? false;

//       _configDarkMode = settings['darkMode'] ?? false;
//     }
//   }

//   Future<void> saveSettings({
//     bool? replaceEmailWithUsernameOnWallPost,
//     bool? enterSendsPost,
//     bool? enablePostComments,
//     bool? darkMode,
//   }) async {
//     // stores new values to local

//     _configEnterSendsPost = enterSendsPost ?? _configEnterSendsPost;

//     _configDarkMode = darkMode ?? _configDarkMode;

//     // save changes to database
//     await FirebaseFirestore.instance.collection('User Settings').doc(user.email).set({
//       'enterSendsPost': enterSendsPost ?? _configEnterSendsPost,
//       'darkMode': darkMode ?? _configDarkMode,
//     });
//   }

//   var _configEnterSendsPost = false;
//   var _configDarkMode = false;
// }
