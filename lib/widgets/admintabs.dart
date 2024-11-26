// import 'package:flutter/material.dart';
// import 'package:task/screens/admin_home_screen.dart';
// import 'package:task/screens/admin_profile.dart';
// import 'package:task/screens/admin_show_ticket_screen.dart';
// import 'package:task/screens/admindetails.dart';

// class AdminTabs extends StatefulWidget {
//   const AdminTabs({super.key});

//   @override
//   State<AdminTabs> createState() => _MyWidgetState();
// }

// class _MyWidgetState extends State<AdminTabs> {
//   int _pageIndex = 0;

//   final List<Widget> _pages = [
//     const AdminHomeScreen(),
//     const AdminShowTicketScreen(),
//     const AdminDetailsScreen(),
//     const AdminProfile()
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _pageIndex,
//         onTap: (value) {
//           setState(() {
//             _pageIndex = value;
//           });
//         },
//         selectedItemColor: Colors.orange.shade700,
//         unselectedItemColor: Colors.black,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.confirmation_num),
//             label: 'TICKETS',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_month),
//             label: 'Holidays',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle_rounded),
//             label: 'ADMIN PROFILE',
//           ),
//         ],
//       ),
//       body: _pages[_pageIndex],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:task/screens/admin_home_screen.dart';
import 'package:task/screens/admin_profile.dart';
import 'package:task/screens/admin_show_ticket_screen.dart';
import 'package:task/screens/admindetails.dart';
import 'dart:io'; // For exit(0)

class AdminTabs extends StatefulWidget {
  const AdminTabs({super.key});

  @override
  State<AdminTabs> createState() => _AdminTabsState();
}

class _AdminTabsState extends State<AdminTabs> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const AdminHomeScreen(),
    const AdminShowTicketScreen(),
    const AdminDetailsScreen(),
    const AdminProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show a confirmation dialog before exiting the app
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App'),
            content: const Text('Are you sure you want to exit the app?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit'),
              ),
            ],
          ),
        );

        return shouldExit ?? false;
      },
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _pageIndex,
          onTap: (value) {
            setState(() {
              _pageIndex = value;
            });
          },
          selectedItemColor: Colors.orange.shade700,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.white,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num),
              label: 'TICKETS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Holidays',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_rounded),
              label: 'ADMIN PROFILE',
            ),
          ],
        ),
        body: _pages[_pageIndex],
      ),
    );
  }
}
