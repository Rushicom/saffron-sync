// import 'package:flutter/material.dart';
// import 'package:task/screens/UserProfile.dart';
// import 'package:task/screens/user_home.dart';
// import 'package:task/screens/user_ticket.dart';
// import 'package:task/screens/userdetails.dart';

// class UserTabs extends StatefulWidget {
//   const UserTabs({super.key});

//   @override
//   State<UserTabs> createState() => _UserTabsState();
// }

// class _UserTabsState extends State<UserTabs> {
//   int _pageIndex = 0;

//   final List<Widget> _pages = [
//     const UserHomeScreen(),
//     const UserTicketScreen(),
//     const UserDetailsScreen(),
//     const UserprofileScreen(),
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
//         items: const  [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'HOME',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.confirmation_num),
//             label: 'TICKET',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calendar_month),
//             label: 'CALENDER',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: 'PROFILE',
//           ),
//         ],
//       ),
//       body: _pages[_pageIndex],
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:task/screens/UserProfile.dart';
import 'package:task/screens/user_home.dart';
import 'package:task/screens/user_ticket.dart';
import 'package:task/screens/userdetails.dart';

class UserTabs extends StatefulWidget {
  const UserTabs({super.key});

  @override
  State<UserTabs> createState() => _UserTabsState();
}

class _UserTabsState extends State<UserTabs> {
  int _pageIndex = 0;

  final List<Widget> _pages = [
    const UserHomeScreen(),
    const UserTicketScreen(),
    const UserDetailsScreen(),
    const UserprofileScreen(),
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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num),
              label: 'TICKET',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'CALENDAR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'PROFILE',
            ),
          ],
        ),
        body: _pages[_pageIndex],
      ),
    );
  }
}
