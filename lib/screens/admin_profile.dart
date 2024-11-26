import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/screens/option.dart';

class AdminProfile extends StatefulWidget {
  const AdminProfile({super.key});

  @override
  State<AdminProfile> createState() => _AdminProfileState();
}

class _AdminProfileState extends State<AdminProfile> {
  Map<String, dynamic>? _adminData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('admin')
          .doc(user.uid)
          .get();

      setState(() {
        _adminData = userData.data();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<void> logOut(BuildContext context) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (ctx) => const OptionScreen(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text('Admin Profile'),
        actions: [
          IconButton(
            onPressed: () => logOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _adminData == null
              ? const Center(child: Text('No Admin data found'))
              : Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: _adminData!['imageUrl'] != null
                                    ? NetworkImage(_adminData!['imageUrl'])
                                    : null,
                                child: _adminData!['imageUrl'] == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _adminData!['name'] ?? 'No Name',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _adminData!['email'] ?? 'No Email',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Address: ${_adminData!['address'] ?? 'No Address'}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 16,),
                               Text(
                                _adminData!['id'] ?? 'No id',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
