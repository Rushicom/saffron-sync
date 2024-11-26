// import 'package:firebase_app_check/firebase_app_check.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:task/screens/option.dart';
// import 'package:task/widgets/admintabs.dart';
// import 'package:task/widgets/tabs.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   await FirebaseAppCheck.instance.activate();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   Future<Widget> _getInitialScreen() async {
//     final prefs = await SharedPreferences.getInstance();
//     final uid = prefs.getString('uid');
//     final role = prefs.getString('role');

//     if (uid != null) {
//       if (role == 'employee') {
//         return const UserTabs();
//       } else if (role == 'admin') {
//         return const AdminTabs();
//       }
//     }
//     return const OptionScreen();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Widget>(
//       future: _getInitialScreen(),
//       builder: (contex, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const MaterialApp(
//             home: Scaffold(
//               body: Center(
//                 child: CircularProgressIndicator(),
//               ),
//             ),
//           );
//         }else {
//           return MaterialApp(
//             debugShowCheckedModeBanner: false,
//             title: 'Authenticate',
//             theme: ThemeData().copyWith(
//               colorScheme: ColorScheme.fromSeed(
//                 seedColor: const Color.fromARGB(255, 63, 17, 177),
//               ),
//             ),
//             home: snapshot.data,
//           );
//         }
//       },
//     );
//   }
// }

// //         else{
// //     return MaterialApp(
// //         debugShowCheckedModeBanner: false,
// //         title: 'Authenticate',
// //         theme: ThemeData().copyWith(
// //           colorScheme: ColorScheme.fromSeed(
// //             seedColor: const Color.fromARGB(255, 63, 17, 177),
// //           ),
// //         ),
// //         home: const OptionScreen());
// //   }
// // },);
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/screens/option.dart';
import 'package:task/widgets/admintabs.dart';
import 'package:task/widgets/tabs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminUid = prefs.getString('admin_uid');

      if (adminUid != null) {
        return const AdminTabs();
      }

      // Include employee logic
      final uid = prefs.getString('uid');
      final role = prefs.getString('role');
      if (uid != null) {
        if (role == 'employee') {
          return const UserTabs();
        }
      }

      return const OptionScreen();
    } catch (e) {
      debugPrint('Error retrieving initial screen: $e');
      return const OptionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _getInitialScreen(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error occurred!'),
              ),
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
  home: snapshot.data,
  theme: ThemeData(
    scaffoldBackgroundColor: Colors.white, // Sets the background to white
    primaryColor: Colors.white, // Primary theme color
   
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.orange.shade200,
      // primary: Colors.white, // Use white as the primary color
      secondary: Colors.black, // Contrast for buttons, etc.
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Default text color
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black), // AppBar title text
    ),
  ),
          );
        }
      },
    );
  }
}
