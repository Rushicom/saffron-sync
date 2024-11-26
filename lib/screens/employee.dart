// import 'dart:math';
// import 'dart:io';

// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:task/screens/user_image_picker.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:task/widgets/tabs.dart';
// import 'package:uuid/uuid.dart';

// var uuid = const Uuid();

// final _firebase = FirebaseAuth.instance;

// class EmployeeLoginScreen extends StatefulWidget {
//   const EmployeeLoginScreen({super.key});

//   @override
//   State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
// }

// class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
//   final _form = GlobalKey<FormState>();
//   var _isLogin = true;
//   var _enteredName = '';
//   var _enteredAddress = '';
//   var _enteredAdhar = '';
//   String _selectDepartment = 'HR';
//   var _enteredEmail = '';
//   var _enteredPassword = '';
//   String _id = '';
//   File? _selectedImage;

//   @override
//   void initState() {
//     super.initState();
//     _checkSession();
//     _id = _genrateUserID();
//   }

//   var _isAuthenticating = false;

//   final List<String> department = ['HR', 'Finance', 'Engineering', 'Marketing'];

//   String _genrateUserID() {
//     const prefix = 'SE-KS-';
//     const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
//     Random rand = Random();
//     String randomPart = String.fromCharCodes(
//       Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
//     );
//     return '$prefix$randomPart';
//   }

//   Future<void> _submit() async {
//     final _isValid = _form.currentState!.validate();
//     if (!_isValid) {
//       return;
//     }
//     if (!_isLogin && _selectedImage == null) {
//       print('Image not selected');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an image.')),
//       );
//       return;
//     }
//     _form.currentState!.save();

//     try {
//       setState(() {
//         _isAuthenticating = true;
//       });

//       UserCredential userCredential;
//       if (_isLogin) {
//         userCredential = await _firebase.signInWithEmailAndPassword(
//           email: _enteredEmail,
//           password: _enteredPassword,
//         );
//       } else {
//         userCredential = await _firebase.createUserWithEmailAndPassword(
//           email: _enteredEmail,
//           password: _enteredPassword,
//         );

//         if (_selectedImage != null) {
//           final ref = FirebaseStorage.instance
//               .ref()
//               .child('employee_images')
//               .child('$_id.jpg');

//           await ref.putFile(_selectedImage!);
//           final imageUrl = await ref.getDownloadURL();

//           await FirebaseFirestore.instance
//               .collection('users')
//               .doc(userCredential.user!.uid)
//               .set({
//             'id': _id,
//             'name': _enteredName,
//             'email': _enteredEmail,
//             'address': _enteredAddress,
//             'aadhaar': _enteredAdhar,
//             'department': _selectDepartment,
//             'password': _enteredPassword,
//             'imageUrl': imageUrl,
//             'role': 'employee'
//           });
//         }
//       }
//       await _saveSession(userCredential.user!.uid, 'employee');

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Center(child: Text('Login Successful'))),
//       );

//       _form.currentState!.reset();
//       setState(() {
//         _selectedImage = null;
//         _id = _genrateUserID();
//       });

//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(
//           builder: (ctx) => const UserTabs(),
//         ),
//       );
//     } on FirebaseAuthException catch (error) {
//       if (error.code == 'email-alread-in-use') {}
//       ScaffoldMessenger.of(context).clearSnackBars();
//       ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(error.message ?? 'Authaniction Failed')));
//       setState(() {
//         _isAuthenticating = false;
//       });
//     }
//   }

//   Future<void> _saveSession(String uid, String role) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('uid', uid);
//     await prefs.setString('role', role);
//   }

//   Future<void> _checkSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     final uid = prefs.getString('uid');
//     final role = prefs.getString('role');

//     if (uid != null && role == 'employee') {
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (ctx) => const UserTabs()));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       appBar: AppBar(
//         backgroundColor: Colors.orange.shade600,
//         title: Text(_isLogin ? 'User Login' : 'User Registration'),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 if (_isLogin) // Show only during login
//                   Image.asset(
//                     'assets/image/profile.png', // Replace with your asset path
//                     height: 160,
//                   ),
//                 Card(
//                   margin: const EdgeInsets.all(12),
//                   child: SingleChildScrollView(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Form(
//                         key: _form,
//                         child: Column(
//                           children: [
//                             if (!_isLogin)
//                               Text(
//                                 'User Id: $_id',
//                               ),
//                             if (!_isLogin)
//                               UserImagePicker(
//                                 onImagePicked: (pickedImage) {
//                                   _selectedImage = pickedImage;
//                                 },
//                               ),
//                             if (!_isLogin)
//                               TextFormField(
//                                 decoration:
//                                     const InputDecoration(label: Text('Name')),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium!
//                                     .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .onSurface),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty ||
//                                       value.trim().length > 50) {
//                                     return 'Character count must be between 1 and 50';
//                                   }
//                                   return null;
//                                 },
//                                 onSaved: (value) {
//                                   _enteredName = value!;
//                                 },
//                               ),
//                             const SizedBox(height: 14),
//                             if (!_isLogin)
//                               TextFormField(
//                                 decoration: const InputDecoration(
//                                     label: Text('Address')),
//                                 style: Theme.of(context)
//                                     .textTheme
//                                     .bodyMedium!
//                                     .copyWith(
//                                         color: Theme.of(context)
//                                             .colorScheme
//                                             .onSurface),
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty ||
//                                       value.trim().length > 50) {
//                                     return 'Character count must be between 1 and 50';
//                                   }
//                                   return null;
//                                 },
//                                 onSaved: (value) {
//                                   _enteredAddress = value!;
//                                 },
//                               ),
//                             const SizedBox(height: 14),
//                             TextFormField(
//                               decoration:
//                                   const InputDecoration(labelText: 'Email ID'),
//                               keyboardType: TextInputType.emailAddress,
//                               autocorrect: false,
//                               textCapitalization: TextCapitalization.none,
//                               validator: (value) {
//                                 if (value == null ||
//                                     value.trim().isEmpty ||
//                                     !value.contains('@')) {
//                                   return 'Please enter a valid email id';
//                                 }
//                                 return null;
//                               },
//                               onSaved: (value) {
//                                 _enteredEmail = value!;
//                               },
//                             ),
//                             const SizedBox(height: 14),
//                             if (!_isLogin)
//                               TextFormField(
//                                 decoration:
//                                     const InputDecoration(labelText: 'Aadhaar'),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null ||
//                                       value.trim().isEmpty ||
//                                       value.length != 12) {
//                                     return 'Please enter a valid 12-digit Aadhaar number';
//                                   }
//                                   return null;
//                                 },
//                                 onSaved: (value) {
//                                   _enteredAdhar = value!;
//                                 },
//                               ),
//                             const SizedBox(height: 14),
//                             if (!_isLogin)
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: DropdownButton<String>(
//                                       value: _selectDepartment,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyMedium!
//                                           .copyWith(
//                                               color: Theme.of(context)
//                                                   .colorScheme
//                                                   .onSurface),
//                                       items: department
//                                           .map(
//                                             (dept) => DropdownMenuItem<String>(
//                                               value: dept,
//                                               child: Text(dept),
//                                             ),
//                                           )
//                                           .toList(),
//                                       onChanged: (value) {
//                                         if (value == null) return;
//                                         setState(() {
//                                           _selectDepartment = value;
//                                         });
//                                       },
//                                       isExpanded: true,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             const SizedBox(height: 14),
//                             TextFormField(
//                               decoration:
//                                   const InputDecoration(labelText: 'Password'),
//                               obscureText: true,
//                               validator: (value) {
//                                 if (value == null || value.trim().length < 6) {
//                                   return 'Please enter a password with at least 6 characters';
//                                 }
//                                 return null;
//                               },
//                               onSaved: (value) {
//                                 _enteredPassword = value!;
//                               },
//                             ),
//                             const SizedBox(height: 12),
//                             if (_isAuthenticating)
//                               const CircularProgressIndicator(),
//                             if (!_isAuthenticating)
//                               ElevatedButton(
//                                 onPressed: _submit,
//                                 child: Text(_isLogin ? 'Login' : 'Signup'),
//                               ),
//                             TextButton(
//                               onPressed: () {
//                                 setState(() {
//                                   _isLogin = !_isLogin;
//                                 });
//                               },
//                               child: Text(_isLogin
//                                   ? 'Create an account'
//                                   : 'I already have an account'),
//                             ),
//                           ],
//                         ),
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



import 'dart:math';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/screens/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task/widgets/tabs.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

final _firebase = FirebaseAuth.instance;

class EmployeeLoginScreen extends StatefulWidget {
  const EmployeeLoginScreen({super.key});

  @override
  State<EmployeeLoginScreen> createState() => _EmployeeLoginScreenState();
}

class _EmployeeLoginScreenState extends State<EmployeeLoginScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredName = '';
  var _enteredAddress = '';
  var _enteredAdhar = '';
  String _selectDepartment = 'HR';
  var _enteredEmail = '';
  var _enteredPassword = '';
  String _id = '';
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _id = _genrateUserID();
  }

  var _isAuthenticating = false;

  final List<String> department = ['HR', 'Finance', 'Engineering', 'Marketing'];

  String _genrateUserID() {
    const prefix = 'SE-KS-';
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random rand = Random();
    String randomPart = String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(rand.nextInt(chars.length))),
    );
    return '$prefix$randomPart';
  }

  Future<void> _submit() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    if (!_isLogin && _selectedImage == null) {
      print('Image not selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image.')),
      );
      return;
    }
    _form.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      UserCredential userCredential;
      if (_isLogin) {
        userCredential = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        if (_selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('employee_images')
              .child('$_id.jpg');

          await ref.putFile(_selectedImage!);
          final imageUrl = await ref.getDownloadURL();

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'id': _id,
            'name': _enteredName,
            'email': _enteredEmail,
            'address': _enteredAddress,
            'aadhaar': _enteredAdhar,
            'department': _selectDepartment,
            'password': _enteredPassword,
            'imageUrl': imageUrl,
            'role': 'employee'
          });
        }
      }
      await _saveSession(userCredential.user!.uid, 'employee');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Center(child: Text('Login Successful'))),
      );

      _form.currentState!.reset();
      setState(() {
        _selectedImage = null;
        _id = _genrateUserID();
      });

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const UserTabs(),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-alread-in-use') {}
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authaniction Failed')));
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  Future<void> _saveSession(String uid, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('role', role);
  }

 Future<void> _checkSession() async {
  final prefs = await SharedPreferences.getInstance();
  final uid = prefs.getString('uid');
  final role = prefs.getString('role');

  if (uid != null && role == 'employee') {
    if (mounted) {
      // Push UserTabs and remove all previous routes from the stack.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (ctx) => const UserTabs()),
        (Route<dynamic> route) => false, // Removes all previous routes.
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: Text(_isLogin ? 'User Login' : 'User Registration'),
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
                if (_isLogin) // Show only during login
                  Image.asset(
                    'assets/image/profile.png', // Replace with your asset path
                    height: 160,
                  ),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _form,
                        child: Column(
                          children: [
                            if (!_isLogin)
                              Text(
                                'User Id: $_id',
                              ),
                            if (!_isLogin)
                              UserImagePicker(
                                onImagePicked: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            if (!_isLogin)
                              TextFormField(
                                decoration:
                                    const InputDecoration(label: Text('Name')),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length > 50) {
                                    return 'Character count must be between 1 and 50';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredName = value!;
                                },
                              ),
                            const SizedBox(height: 14),
                            if (!_isLogin)
                              TextFormField(
                                decoration: const InputDecoration(
                                    label: Text('Address')),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.trim().length > 50) {
                                    return 'Character count must be between 1 and 50';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredAddress = value!;
                                },
                              ),
                            const SizedBox(height: 14),
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
                                  return 'Please enter a valid email id';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                _enteredEmail = value!;
                              },
                            ),
                            const SizedBox(height: 14),
                            if (!_isLogin)
                              TextFormField(
                                decoration:
                                    const InputDecoration(labelText: 'Aadhaar'),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty ||
                                      value.length != 12) {
                                    return 'Please enter a valid 12-digit Aadhaar number';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  _enteredAdhar = value!;
                                },
                              ),
                            const SizedBox(height: 14),
                            if (!_isLogin)
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: _selectDepartment,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface),
                                      items: department
                                          .map(
                                            (dept) => DropdownMenuItem<String>(
                                              value: dept,
                                              child: Text(dept),
                                            ),
                                          )
                                          .toList(),
                                      onChanged: (value) {
                                        if (value == null) return;
                                        setState(() {
                                          _selectDepartment = value;
                                        });
                                      },
                                      isExpanded: true,
                                    ),
                                  ),
                                ],
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
                                child: Text(_isLogin ? 'Login' : 'Signup'),
                              ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an account'
                                  : 'I already have an account'),
                            ),
                          ],
                        ),
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
