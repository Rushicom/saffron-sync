
import 'package:flutter/material.dart';
import 'package:task/screens/new_admin_add.dart';
import 'package:task/screens/search_user_name_screen.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    void addAdmin() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const NewAdminScreen()));
    }
    void searchEmployees(){
      Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => const SearchUserNameScreen()));
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text('Admin Home Screen'),
        // actions: [
        //   IconButton(
        //     onPressed: addAdmin,
        //     icon: const Icon(Icons.add),
        //   ),
        // ],
      ),
      body: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(10),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          children: [
            GestureDetector(
              onTap: addAdmin,
              child: Card(
                color: Colors.orange.shade100,
                elevation: 4,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_add,
                      size: 50,
                      color: Colors.orange,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Add New Admin',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: searchEmployees,
              child: Card(
                color: Colors.blue.shade100,
                elevation: 4,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search,size: 50,color: Colors.blue,),
                    SizedBox(height: 10,),
                    Text(
                      'Search Employees',
                      style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
