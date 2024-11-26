// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class UserHomeScreen extends StatefulWidget {
//   const UserHomeScreen({super.key});

//   @override
//   State<UserHomeScreen> createState() => _UserHomeScreenState();
// }

// class _UserHomeScreenState extends State<UserHomeScreen> {
//   int casualLeaveLeft = 0;
//   int medicalLeaveLeft = 0;
//   int unpaidLeavesTaken = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchLeaveData();
//   }

//   Future<void> _fetchLeaveData() async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) {
//         print('No user logged in');
//         return;
//       }
//       final uid = user.uid;

//       // Fetch the user's leaveCounts data (from leaveCounts collection)
//       final leaveCountDoc = await FirebaseFirestore.instance
//           .collection('leaveCounts')
//           .doc(uid)
//           .get();

//       if (!leaveCountDoc.exists) {
//         print('No leave counts data found for user');
//         return;
//       }

//       final leaveData = leaveCountDoc.data() as Map<String, dynamic>;

//       final casualLeaveCount =
//           (leaveData['casualLeaveCount'] as num?)?.toInt() ?? 0;
//       final medicalLeaveCount =
//           (leaveData['medicalLeaveCount'] as num?)?.toInt() ?? 0;

//       // Fetch all approved tickets for leaves (from tickets collection)
//       final ticketSnapshot = await FirebaseFirestore.instance
//           .collection('tickets')
//           .where('uid', isEqualTo: uid)
//           .where('mainCategory', isEqualTo: 'leaves')
//           .where('isApproved', isEqualTo: true)
//           .get();

//       int approvedCasualLeave = 0;
//       int approvedMedicalLeave = 0;
//       int unpaidLeaves = 0;

//       for (var doc in ticketSnapshot.docs) {
//         final data =  doc.data() as Map<String, dynamic>;
//         final subCategory = data['subCategory'] as String?;

//         // Count approved leaves by subCategory
//         if (subCategory == 'casual') {
//           approvedCasualLeave++;
//         } else if (subCategory == 'medical') {
//           approvedMedicalLeave++;
//         } else {
//           unpaidLeaves++;
//         }
//       }

//       if (!mounted) return; // Ensure the widget is still in the widget tree

//       setState(() {
//         // Calculate the remaining leave counts
//         casualLeaveLeft = casualLeaveCount - approvedCasualLeave;
//         medicalLeaveLeft = medicalLeaveCount - approvedMedicalLeave;
//         unpaidLeavesTaken = unpaidLeaves;
//       });
//     } catch (e) {
//       print('Error fetching leave data: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('User Home'),
//         backgroundColor: Colors.orange.shade600,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             _buildLeaveCard(
//               'Casual Leaves Left',
//               casualLeaveLeft,
//               Colors.blue,
//             ),
//             const SizedBox(height: 16),
//             _buildLeaveCard(
//               'Medical Leaves Left',
//               medicalLeaveLeft,
//               Colors.green,
//             ),
//             const SizedBox(height: 16),
//             _buildLeaveCard(
//               'Unpaid Leaves Taken',
//               unpaidLeavesTaken,
//               Colors.red,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLeaveCard(String title, int count, Color color) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             Text(
//               count.toString(),
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Importing intl package

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  int casualLeaveLeft = 0;
  int medicalLeaveLeft = 0;
  int unpaidLeavesTaken = 0;

  @override
  void initState() {
    super.initState();
    _fetchLeaveData();
  }

  // Future<void> _fetchLeaveData() async {
  //   try {
  //     final user = FirebaseAuth.instance.currentUser;
  //     if (user == null) {
  //       print('No user logged in');
  //       return;
  //     }
  //     final uid = user.uid;

  //     // Fetch the user's leaveCounts data (from leaveCounts collection)
  //     final leaveCountDoc = await FirebaseFirestore.instance
  //         .collection('leaveCounts')
  //         .doc(uid)
  //         .get();


  //     if (!leaveCountDoc.exists) {
  //       print('No leave counts data found for user');
  //       return;
  //     }

  //     final leaveData = leaveCountDoc.data() as Map<String, dynamic>;

  //     final casualLeaveCount = (leaveData['casualLeaveCount'] as num?)?.toInt() ?? 0;
  //     final medicalLeaveCount = (leaveData['medicalLeaveCount'] as num?)?.toInt() ?? 0;

  //     // Fetch all approved tickets for leaves (from tickets collection)
  //     final ticketSnapshot = await FirebaseFirestore.instance
  //         .collection('tickets')
  //         .where('uid', isEqualTo: uid)
  //         .where('mainCategory', isEqualTo: 'leaves')
  //         .where('isApproved', isEqualTo: true)
  //         .get();

  //     int approvedCasualLeave = 0;
  //     int approvedMedicalLeave = 0;
  //     int unpaidLeaves = 0;

  //     for (var doc in ticketSnapshot.docs) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final subCategory = data['subCategory'] as String?;

  //       // Count approved leaves by subCategory
  //       if (subCategory == 'casual') {
  //         approvedCasualLeave++;
  //       } else if (subCategory == 'medical') {
  //         approvedMedicalLeave++;
  //       } else {
  //         unpaidLeaves++;
  //       }
  //     }

  //     if (!mounted) return; // Ensure the widget is still in the widget tree

  //     setState(() {
  //       // Calculate the remaining leave counts
  //       casualLeaveLeft = casualLeaveCount - approvedCasualLeave;
  //       medicalLeaveLeft = medicalLeaveCount - approvedMedicalLeave;
  //       unpaidLeavesTaken = unpaidLeaves;
  //     });
  //   } catch (e) {
  //     print('Error fetching leave data: $e');
  //   }
  // }

  

 Future<void> _fetchLeaveData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      return;
    }
    final uid = user.uid;

    final leaveCountDoc = FirebaseFirestore.instance.collection('leaveCounts').doc(uid);

    final docSnapshot = await leaveCountDoc.get();

    // If document doesn't exist, set default leave counts
    if (!docSnapshot.exists) {
      await leaveCountDoc.set({
        'casualLeaveCount': 28,
        'medicalLeaveCount': 28,
      });
      print('Default leave counts initialized for new user.');
    }

    final leaveData = docSnapshot.data() as Map<String, dynamic>? ?? {};
    final casualLeaveCount = (leaveData['casualLeaveCount'] as num?)?.toInt() ?? 28;
    final medicalLeaveCount = (leaveData['medicalLeaveCount'] as num?)?.toInt() ?? 28;

    if (!mounted) return;

    setState(() {
      casualLeaveLeft = casualLeaveCount;
      medicalLeaveLeft = medicalLeaveCount;
      unpaidLeavesTaken = 0; // Unpaid leaves are not tracked in this collection.
    });
  } catch (e) {
    print('Error fetching leave data: $e');
  }
}
 

  // Show history of leaves taken in a bottom sheet
  void _showLeaveHistory(String leaveType) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('No user logged in');
      return;
    }
    final uid = user.uid;

    // Fetch the tickets for the selected leave type (casual, medical, unpaid)
    final ticketSnapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('uid', isEqualTo: uid)
        .where('mainCategory', isEqualTo: 'leaves')
        .where('subCategory', isEqualTo: leaveType)
        .where('isApproved', isEqualTo: true)
        .get();

    List<String> leaveDates = [];

    for (var doc in ticketSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final dates = data['datesOfRequirement'] as List<dynamic>?;

      // Add the leave dates to the list, formatted to show only the date part
      if (dates != null) {
        for (var date in dates) {
          DateTime dateTime = date.toDate();
          String formattedDate = DateFormat('MM/dd/yyyy').format(dateTime); // Format date to only show MM/dd/yyyy
          leaveDates.add(formattedDate);
        }
      }
    }

    
 showModalBottomSheet(
  context: context,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  backgroundColor: Colors.white,
  isScrollControlled: true, 
  builder: (context) {
    return FractionallySizedBox(
      heightFactor: 0.6,
      widthFactor: 1.0, 
      
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$leaveType Leave History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (leaveDates.isEmpty)
              const Text('No leave history available.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: leaveDates.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(leaveDates[index]), // Show formatted date
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  },
);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('User Home'),
        backgroundColor: Colors.orange.shade600,
      ),
      body: Container(
        decoration: const BoxDecoration(color: Colors.white),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => _showLeaveHistory('casual'),
                child: _buildLeaveCard(
                  'Casual Leaves Left',
                  casualLeaveLeft,
                  Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showLeaveHistory('medical'),
                child: _buildLeaveCard(
                  'Medical Leaves Left',
                  medicalLeaveLeft,
                  Colors.green,
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => _showLeaveHistory('unpaid'),
                child: _buildLeaveCard(
                  'Unpaid Leaves Taken',
                  unpaidLeavesTaken,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(String title, int count, Color color) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


























































//  Future<void> _fetchLeaveData() async {
//   try {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       print('No user logged in');
//       return;
//     }
//     final uid = user.uid;

//     final leaveCountDoc = FirebaseFirestore.instance
//         .collection('leaveCounts')
//         .doc(uid);

//     final docSnapshot = await leaveCountDoc.get();

//     // If document doesn't exist, set default leave counts
//     if (!docSnapshot.exists) {
//       await leaveCountDoc.set({
//         'casualLeaveCount': 28,
//         'medicalLeaveCount': 28,
//       });
//       print('Default leave counts initialized for new user.');
//     }

//     final leaveData = docSnapshot.data() as Map<String, dynamic>? ?? {};
//     final casualLeaveCount = (leaveData['casualLeaveCount'] as num?)?.toInt() ?? 28;
//     final medicalLeaveCount = (leaveData['medicalLeaveCount'] as num?)?.toInt() ?? 28;

//     // Fetch all approved tickets for leaves
//     final ticketSnapshot = await FirebaseFirestore.instance
//         .collection('tickets')
//         .where('uid', isEqualTo: uid)
//         .where('mainCategory', isEqualTo: 'leaves')
//         .where('isApproved', isEqualTo: true)
//         .get();

//     int approvedCasualLeave = 0;
//     int approvedMedicalLeave = 0;
//     int unpaidLeaves = 0;

//     for (var doc in ticketSnapshot.docs) {
//       final data = doc.data() as Map<String, dynamic>;
//       final subCategory = data['subCategory'] as String?;

//       if (subCategory == 'casual') {
//         approvedCasualLeave++;
//       } else if (subCategory == 'medical') {
//         approvedMedicalLeave++;
//       } else {
//         unpaidLeaves++;
//       }
//     }

//     if (!mounted) return;

//     setState(() {
//       casualLeaveLeft = casualLeaveCount - approvedCasualLeave;
//       medicalLeaveLeft = medicalLeaveCount - approvedMedicalLeave;
//       unpaidLeavesTaken = unpaidLeaves;
//     });
//   } catch (e) {
//     print('Error fetching leave data: $e');
//   }
// }
