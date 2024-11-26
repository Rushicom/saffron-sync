import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:task/widgets/admin_image_picker.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

final _firebase = FirebaseAuth.instance;

class NewAdminScreen extends StatefulWidget {
  const NewAdminScreen({super.key});
  @override
  State<NewAdminScreen> createState() {
    return _NewAdminScreenState();
  }
}

class _NewAdminScreenState extends State<NewAdminScreen> {
  final _form = GlobalKey<FormState>();
  final _isLogin = false;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredName = '';
  var _enteredAddress = '';
  var _id = uuid.v4();
  File? _selectedImage;
  @override
  void initState() {
    _id = uuid.v4();
    super.initState();
  }

  var _isAuthenticating = false;

  Future<void> _submit() async {
    final _isValid = _form.currentState!.validate();
    if (!_isValid) {
      return;
    }
    if (!_isLogin && _selectedImage == null) {
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
      if (!_isLogin) {
        
        userCredential = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        
        if (_selectedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child('admin_images')
              .child('$_id.jpg');

          await ref.putFile(_selectedImage!);
          final imageUrl = await ref.getDownloadURL();

         
          await FirebaseFirestore.instance
              .collection('admin')
              .doc(userCredential.user!.uid)
              .set({
            'id': _id,
            'name': _enteredName,
            'email': _enteredEmail,
            'address': _enteredAddress,
            'imageUrl': imageUrl
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Center(child: Text('Admin Registration Successful'))),
          );

          _form.currentState!.reset();
          setState(() {
            _selectedImage = null;
            _id = uuid.v4();
          });
        } else {
          await _firebase.signInWithEmailAndPassword(
              email: _enteredEmail, password: _enteredPassword);
        }
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication Failed')),
      );
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('add Admin'),
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
                              AdminImagePicker(
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
                                decoration:
                                    const InputDecoration(label: Text('Address')),
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
                                child: const Text('Signup'),
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
