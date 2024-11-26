import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/screens/option.dart';

class UserprofileScreen extends StatefulWidget {
  const UserprofileScreen({super.key});

  @override
  _UserprofileScreenState createState() => _UserprofileScreenState();
}

class _UserprofileScreenState extends State<UserprofileScreen> {
  Map<String, dynamic>? _userData;
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
          .collection('users')
          .doc(user.uid)
          .get();

      setState(() {
        _userData = userData.data();
        _isLoading = false;
      });
    }
  }

  Future<void> _logOut(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const OptionScreen()));
  }

  Future<void> _showEditModel() async {
    final nameController = TextEditingController(text: _userData?['name']);
    final emailController = TextEditingController(text: _userData?['email']);
    final addressController =
        TextEditingController(text: _userData?['address']);
    final aadhaarController =
        TextEditingController(text: _userData?['aadhaar']);
    final departmentController =
        TextEditingController(text: _userData?['department']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildTextField('Name', nameController),
                _buildTextField('Email', emailController),
                _buildTextField('Address', addressController),
                _buildTextField('Aadhaar', aadhaarController),
                _buildTextField('Department', departmentController),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({
                        'name': nameController.text,
                        'email': emailController.text,
                        'address': addressController.text,
                        'aadhaar': aadhaarController.text,
                        'department': departmentController.text,
                      });
                      setState(() {
                        _userData = {
                          'name': nameController.text,
                          'email': emailController.text,
                          'address': addressController.text,
                          'aadhaar': aadhaarController.text,
                          'department': departmentController.text,
                        };
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
            labelText: label, border: const OutlineInputBorder()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text('User Profile'),
        actions: [
           IconButton(onPressed: _showEditModel, icon: const Icon(Icons.edit),),
          IconButton(
            onPressed: () => _logOut(context),
            icon: const Icon(Icons.logout),
          ),
         
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _userData == null
              ? const Center(child: Text('No user data found'))
              : Container(
                  decoration: const BoxDecoration(color: Colors.white),
                  child: SingleChildScrollView(
                    child: Center(
                      child: Card(
                        color: Colors.white,
                        elevation: 8,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.03,
                            horizontal: screenWidth * 0.05,
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.15,
                                backgroundImage: _userData!['imageUrl'] != null
                                    ? NetworkImage(_userData!['imageUrl'])
                                    : null,
                                child: _userData!['imageUrl'] == null
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              _buildInfoCard('ID', _userData!['id'] ?? 'No ID'),
                              _buildInfoCard(
                                  'Name', _userData!['name'] ?? 'No Name'),
                              _buildInfoCard(
                                  'Email', _userData!['email'] ?? 'No Email'),
                              _buildInfoCard('Address',
                                  _userData!['address'] ?? 'No Address'),
                              _buildInfoCard('Aadhaar',
                                  _userData!['aadhaar'] ?? 'No Aadhaar'),
                              _buildInfoCard('Department',
                                  _userData!['department'] ?? 'No Department'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: Colors.white,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(Icons.info, color: Colors.orange.shade600),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
      ),
    );
  }
}












// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:task/screens/option.dart';

// class UserprofileScreen extends StatefulWidget {
//   const UserprofileScreen({super.key});

//   @override
//   _UserprofileScreenState createState() => _UserprofileScreenState();
// }

// class _UserprofileScreenState extends State<UserprofileScreen> {
//   Map<String, dynamic>? _userData;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserData();
//   }

//   Future<void> _fetchUserData() async {
//     final user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       final userData = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .get();

//       setState(() {
//         _userData = userData.data();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     Future<void> _logOut(BuildContext context) async {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.clear();
//       await FirebaseAuth.instance.signOut();
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (ctx) => const OptionScreen()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.orange.shade600,
//         title: const Text('User Profile'),
//         actions: [
//           IconButton(
//             onPressed: () => _logOut(context),
//             icon: const Icon(Icons.logout),
//           )
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _userData == null
//               ? const Center(child: Text('No user data found'))
//               : Container(
//                   decoration:  BoxDecoration(
//                     gradient: LinearGradient(
//                         colors: [Colors.orange.shade200,Colors.orange.shade300],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight),
//                   ),
//                   child: Center(
//                     child: Card(
//                       margin: const EdgeInsets.all(16),
//                       child: Padding(
//                         padding: const EdgeInsets.all(50),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Text(
//                               _userData!['id'] ?? 'No id',
//                               style: Theme.of(context).textTheme.titleSmall,
//                             ),
//                             CircleAvatar(
//                               radius: 50,
//                               backgroundImage: _userData!['imageUrl'] != null
//                                   ? NetworkImage(_userData!['imageUrl'])
//                                   : null,
//                               child: _userData!['imageUrl'] == null
//                                   ? const Icon(Icons.person, size: 50)
//                                   : null,
//                             ),
//                             const SizedBox(height: 16),
//                             Text(
//                               _userData!['name'] ?? 'No Name',
//                               style: Theme.of(context).textTheme.titleLarge,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _userData!['email'] ?? 'No Email',
//                               style: Theme.of(context).textTheme.titleMedium,
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Address: ${_userData!['address'] ?? 'No Address'}',
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Aadhaar: ${_userData!['aadhaar'] ?? 'No Aadhaar'}',
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Department: ${_userData!['department'] ?? 'No Department'}',
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//     );
//   }
// }