// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:task/widgets/admintabs.dart';

// final _firebase = FirebaseAuth.instance;

// class AdminScreen extends StatefulWidget {
//   const AdminScreen({super.key});

//   @override
//   State<AdminScreen> createState() => _AdminScreenState();
// }

// class _AdminScreenState extends State<AdminScreen> {
//   final _form = GlobalKey<FormState>();
//   var _enteredEmail = '';
//   var _enteredPassword = '';
//   var _isAuthenticating = false;

//   @override
//   void initState() {
//     super.initState();
//     _checkAdminSession();
//   }

//   Future<void> _checkAdminSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     final uid = prefs.getString('admin_uid');

//     if (uid != null && mounted) {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (ctx) => const AdminTabs(),
//         ),
//       );
//     }
//   }

//   Future<void> _saveAdminSession(String uid) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('admin_uid', uid);
//   }

//   Future<void> _submit() async {
//     if (!_form.currentState!.validate()) {
//       return;
//     }

//     _form.currentState!.save();

//     setState(() {
//       _isAuthenticating = true;
//     });

//     try {
//       UserCredential userCredential =
//           await _firebase.signInWithEmailAndPassword(
//         email: _enteredEmail,
//         password: _enteredPassword,
//       );

//       DocumentSnapshot adminDoc = await FirebaseFirestore.instance
//           .collection('admin')
//           .doc(userCredential.user!.uid)
//           .get();

//       if (adminDoc.exists) {
//         await _saveAdminSession(userCredential.user!.uid);
//         if (mounted) {
//           Navigator.of(context).pushReplacement(
//             MaterialPageRoute(
//               builder: (ctx) => const AdminTabs(),

//             ),
//           );
//            ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Logged in successfully!'),
//             duration: Duration(seconds: 2), // Optional duration
//           ),
//         );
//         }
//       } else {
//         _showSnackBar('Admin data not found.');
//       }
//     } on FirebaseAuthException catch (error) {
//       _showSnackBar(error.message ?? 'Authentication Failed');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAuthenticating = false;
//         });
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).clearSnackBars();
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       appBar: AppBar(
//         backgroundColor: Colors.orange.shade600,
//         title: const Text('Admin Login'),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//            ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                   Image.asset(
//                 'assets/image/profile.png', // Replace with your asset path
//                 height: 160, // Adjust size as needed
//               ),
//               const SizedBox(height: 20), 
//                 Card(
//                   margin: const EdgeInsets.all(12),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Form(
//                       key: _form,
//                       child: Column(
//                         children: [
//                           TextFormField(
//                             decoration:
//                                 const InputDecoration(labelText: 'Email ID'),
//                             keyboardType: TextInputType.emailAddress,
//                             autocorrect: false,
//                             textCapitalization: TextCapitalization.none,
//                             validator: (value) {
//                               if (value == null ||
//                                   value.trim().isEmpty ||
//                                   !value.contains('@')) {
//                                 return 'Please enter a valid email ID';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) {
//                               _enteredEmail = value!;
//                             },
//                           ),
//                           const SizedBox(height: 14),
//                           TextFormField(
//                             decoration:
//                                 const InputDecoration(labelText: 'Password'),
//                             obscureText: true,
//                             validator: (value) {
//                               if (value == null || value.trim().length < 6) {
//                                 return 'Please enter a password with at least 6 characters';
//                               }
//                               return null;
//                             },
//                             onSaved: (value) {
//                               _enteredPassword = value!;
//                             },
//                           ),
//                           const SizedBox(height: 12),
//                           if (_isAuthenticating)
//                             const CircularProgressIndicator(),
//                           if (!_isAuthenticating)
//                             ElevatedButton(
//                               onPressed: _submit,
//                               child: const Text('Login'),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/widgets/admintabs.dart';

final _firebase = FirebaseAuth.instance;

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    _checkAdminSession();
  }

  Future<void> _checkAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('admin_uid');

    if (uid != null && mounted) {
      // Avoid rebuilding to option.dart by using this navigation logic
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const AdminTabs()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _saveAdminSession(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_uid', uid);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) {
      return;
    }

    _form.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      UserCredential userCredential =
          await _firebase.signInWithEmailAndPassword(
        email: _enteredEmail,
        password: _enteredPassword,
      );

      DocumentSnapshot adminDoc = await FirebaseFirestore.instance
          .collection('admin')
          .doc(userCredential.user!.uid)
          .get();

      if (adminDoc.exists) {
        await _saveAdminSession(userCredential.user!.uid);
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (ctx) => const AdminTabs()),
            (Route<dynamic> route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged in successfully!'),
              duration: Duration(seconds: 2), // Optional duration
            ),
          );
        }
      } else {
        _showSnackBar('Admin data not found.');
      }
    } on FirebaseAuthException catch (error) {
      _showSnackBar(error.message ?? 'Authentication Failed');
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Admin Login'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/profile.png', // Replace with your asset path
                  height: 160, // Adjust size as needed
                ),
                const SizedBox(height: 20),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Email ID'),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid email ID';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return 'Please enter a password with at least 6 characters';
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              child: const Text('Login'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
