import 'package:flutter/material.dart';

class AdminSerchDetailsScreen extends StatelessWidget {
  const AdminSerchDetailsScreen({super.key, required this.user});
  final Map<String, dynamic> user;

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('User Information'),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        user['imageUrl'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Image.network(
                                  user['imageUrl'],
                                  height: 160,
                                  width: 160,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(
                                Icons.account_circle,
                                size: 100,
                                color: Colors.grey,
                              ),
                        const SizedBox(height: 16),
                        Text(
                          user['name'] ?? 'No Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInfoCard('Email', user['email'] ?? 'No Email'),
                _buildInfoCard('Address', user['address'] ?? 'No Address'),
                _buildInfoCard('Department', user['department'] ?? 'No Department'),
                _buildInfoCard('ID', user['id'] ?? 'No ID'),
                _buildInfoCard('Aadhaar', user['aadhaar'] ?? 'No Aadhaar'),
                _buildInfoCard('Role', user['role'] ?? 'No Role'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
