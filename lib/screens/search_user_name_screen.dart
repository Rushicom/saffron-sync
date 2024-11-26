import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task/screens/admin_serch_details_screen.dart';

class SearchUserNameScreen extends StatefulWidget {
  const SearchUserNameScreen({super.key});

  @override
  State<SearchUserNameScreen> createState() => _SearchUserNameScreenState();
}

class _SearchUserNameScreenState extends State<SearchUserNameScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .get();

    print('Fetched Documents:');
    for (var doc in querySnapshot.docs) {
      print(doc.data());
    }

    setState(() {
      _searchResults =
          querySnapshot.docs.map((doc) => doc.data()).where((data) {
        final employeeName = data['name']?.toString() ?? '';
        return employeeName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Search User'),
      ),
      body: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                    labelText: 'Enter Employee Name',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    )),
                onChanged: _performSearch,
              ),
              const SizedBox(
                height: 30,
              ),
              Expanded(
                child: _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        itemCount: _searchResults.length,
                        itemBuilder: (ctx, index) {
                          final employee = _searchResults[index];
                          return Card(
                            color: Colors.white,
                            elevation: 4,
                            child: ListTile(
                              title: Text(employee['name'] ?? 'N/A'),
                              subtitle: Text(employee['email'] ?? 'N/A'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (ctx) =>
                                        AdminSerchDetailsScreen(user: employee),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
