// import 'dart:math';

// import 'package:intl/intl.dart'; // For date formatting
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:task/screens/image_view_screen.dart';
// import 'package:task/screens/pdf_view_screen.dart';
// import 'package:http/http.dart' as http;

// class TicketsDetailsScreen extends StatelessWidget {
//   const TicketsDetailsScreen({super.key, required this.ticketData});
//   final QueryDocumentSnapshot ticketData;

//   // This method will be used to fetch data from Firestore and listen to changes in real time
//   Stream<DocumentSnapshot> _getTicketStream(String ticketId) {
//     return FirebaseFirestore.instance
//         .collection('tickets')
//         .doc(ticketId)
//         .snapshots();
//   }

//  Future<void> _processTicketApproval(
//   BuildContext context,
//   Map<String, dynamic> data,
//   FirebaseFirestore firestore,
//   String ticketId,
// ) async {
//   final docRef = firestore.collection('tickets').doc(ticketId);
//   final leaveCountsDocRef = firestore.collection('leaveCounts').doc(data['uid']);

//   try {
//     // Fetch ticket data from Firestore
//     final docSnapshot = await docRef.get();
//     if (!docSnapshot.exists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Ticket not found')),
//       );
//       return;
//     }

//     // Fetch user's leave count data
//     final leaveCountsDocSnapshot = await leaveCountsDocRef.get();
//     if (!leaveCountsDocSnapshot.exists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: User leave count data not found')),
//       );
//       return;
//     }

//     final leaveCounts = leaveCountsDocSnapshot.data() as Map<String, dynamic>;
//     final List<dynamic>? timestamps = data['datesOfRequirement'];
//     final int leaveDays = timestamps?.length ?? 0;

//     // Determine leave category and check balance
//     final String? subCategory = data['subCategory'];
//     if (subCategory == null || !leaveCounts.containsKey('${subCategory}LeaveCount')) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Invalid leave category')),
//       );
//       return;
//     }

//     final int currentLeaveBalance = leaveCounts['${subCategory}LeaveCount'];
//     if (leaveDays > currentLeaveBalance) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Insufficient leave days. You only have $currentLeaveBalance days available in $subCategory.',
//           ),
//         ),
//       );
//       return;
//     }

//     // Update the ticket status to 'Approved'
//     await docRef.update({
//       'status': 'Approved',
//       'isApproved': true,
//     });

//     // Update the leave count
//     await leaveCountsDocRef.update({
//       '${subCategory}LeaveCount': currentLeaveBalance - leaveDays,
//     });

//     final int remainingLeaves = currentLeaveBalance - leaveDays;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           'Leave approved. Applied days: $leaveDays. Remaining $subCategory leave days: $remainingLeaves.',
//         ),
//       ),
//     );
//   } catch (e) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Error processing ticket: $e')),
//     );
//   }
// }


//   Future<void> _acceptTicket(
//       BuildContext context, Map<String, dynamic> data) async {
//     final FirebaseFirestore firestore = FirebaseFirestore.instance;
//     final String ticketId = ticketData.id;

//     final docRef = firestore.collection('tickets').doc(ticketId);

//     if (data['category'] == 'Remuneration') {
//       final String? adminMessage =
//           await _getAdminMessage(context, 'Enter approval message');
//       if (adminMessage == null) return;

//       try {
//         await docRef.update({
//           'status': 'Approved',
//           'adminMessage': adminMessage,
//         });
//         ScaffoldMessenger.of(context)
//             .showSnackBar(const SnackBar(content: Text('Ticket Approved')));
//       } catch (e) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('Error: $e')));
//       }
//     } else {
//       await _processTicketApproval(context, data, firestore, ticketId);
//     }
//   }

// Future<void> _rejectTicket(
//   BuildContext context,
//   Map<String, dynamic> data,
//   FirebaseFirestore firestore,
//   String ticketId,
// ) async {
//   final docRef = firestore.collection('tickets').doc(ticketId);
//   final leaveCountsDocRef = firestore.collection('leaveCounts').doc(data['uid']);

//   // Check if the ticket exists
//   final docSnapshot = await docRef.get();
//   if (!docSnapshot.exists) {
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Ticket not found')));
//     return;
//   }

//   // Check if ticketId is valid
//   if (ticketId.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: Invalid Ticket ID')));
//     return;
//   }

//   // Get the rejection reason from admin
//   final String? rejectionReason = await _getAdminMessage(context, 'Enter rejection reason');
//   if (rejectionReason == null) return;

//   try {
//     // Fetch leave counts data
//     final leaveCountsDocSnapshot = await leaveCountsDocRef.get();
//     if (!leaveCountsDocSnapshot.exists) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Error: User leave count data not found')),
//       );
//       return;
//     }

//     final leaveCounts = leaveCountsDocSnapshot.data() as Map<String, dynamic>;

//     // Get the leave days requested
//     final List<dynamic>? timestamps = data['datesOfRequirement'];
//     final int leaveDays = timestamps?.length ?? 0;

//     final String subCategory = data['subCategory'] ?? '';
//     print('Rejection: Leave Category - $subCategory');
//     print('Requested Leave Days: $leaveDays');
//     print('Current Leave Count: ${leaveCounts['${subCategory}LeaveCount']}');

//     // Update the leave count based on the subcategory
//     // if (subCategory == 'unpaid') {
//     //   await leaveCountsDocRef.update({
//     //     'unpaidLeaveCount': (leaveCounts['unpaidLeaveCount'] ?? 0) - leaveDays,
//     //   });
//     // } else if (subCategory == 'casual') {
//     //   await leaveCountsDocRef.update({
//     //     'casualLeaveCount': (leaveCounts['casualLeaveCount'] ?? 0) - leaveDays,
//     //   });
//     // } else if (subCategory == 'medical') {
//     //   await leaveCountsDocRef.update({
//     //     'medicalLeaveCount': (leaveCounts['medicalLeaveCount'] ?? 0) - leaveDays,
//     //   });
//     // }

//     // Update the ticket status to rejected
//     await docRef.update({
//       'status': 'Rejected',
//       'adminMessage': rejectionReason,
//     });

//     // Show confirmation snack bar
//     ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Ticket Rejected')));

//     // Print final leave counts after update (for debugging purposes)
//     final updatedLeaveCounts = await leaveCountsDocRef.get();
//     print('Updated Leave Counts: ${updatedLeaveCounts.data()}');
//   } catch (e) {
//     ScaffoldMessenger.of(context)
//         .showSnackBar(SnackBar(content: Text('Error: $e')));
//   }
// }



//   // Method for real-time Firestore data update
//   Future<String?> _getAdminMessage(BuildContext context, String prompt) async {
//     final TextEditingController controller = TextEditingController();

//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(prompt),
//         content: TextField(
//           controller: controller,
//           decoration: const InputDecoration(hintText: 'Enter message here'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(null),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(controller.text),
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'approved':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       case 'open':
//       default:
//         return Colors.blue;
//     }
//   }

//   Future<String?> _getFileType(String url) async {
//     try {
//       final response = await http.head(Uri.parse(url));
//       return response.headers['content-type'];
//     } catch (e) {
//       return null; // Handle errors gracefully
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String ticketId = ticketData.id;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ticket Details'),
//         centerTitle: true,
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: _getTicketStream(ticketId), // Listen to ticket document updates
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Ticket not found'));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>;
//           final String status = data['status'] ?? 'Open';

//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(data, status),
//                 const SizedBox(height: 16),
//                 _buildDetailRow('User ID:', data['uid']),
//                 _buildDetailRow('User Name:', data['name']),
//                 _buildDetailRow('Description:', data['description']),
//                 _buildDetailRow('Main Category:', data['mainCategory']),
//                 _buildDetailRow('Sub Category:', data['subCategory']),
//                 _buildDetailRow('Date of Requirement:',
//                     _formatDate(data['datesOfRequirement'])),
//                 const SizedBox(height: 16),
//                 if (data['fileUrl'] != null)
//                   _buildFileViewButton(context, data['fileUrl']),
//                 if (status.toLowerCase() == 'rejected')
//                   Padding(
//                     padding: const EdgeInsets.only(top: 8.0),
//                     child: Text(
//                       'Rejection Reason: ${data['adminMessage'] ?? 'No Reason Provided'}',
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ),
//                 if (status.toLowerCase() != 'approved' &&
//                     status.toLowerCase() != 'rejected')
//                   _buildActionButtons(context, data),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildHeader(Map<String, dynamic> data, String status) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Flexible(
//           child: Text(
//             'Ticket: ${data['title'] ?? 'No Title'}',
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Chip(
//           label: Text(
//             status.toUpperCase(),
//             style: const TextStyle(color: Colors.white),
//           ),
//           backgroundColor: _getStatusColor(status),
//         ),
//       ],
//     );
//   }

//   Widget _buildDetailRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '$label ',
//             style: const TextStyle(fontWeight: FontWeight.bold),
//           ),
//           Expanded(
//             child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFileViewButton(BuildContext context, String fileUrl) {
//     return ElevatedButton(
//       onPressed: () async {
//         final fileType = await _getFileType(fileUrl);
//         if (fileType == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Could not determine file type')),
//           );
//           return;
//         }

//         if (fileType.contains('pdf')) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => PdfViewerScreen(fileUrl: fileUrl),
//             ),
//           );
//         } else if (fileType.contains('image')) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => ImageViewerScreen(fileUrl: fileUrl),
//             ),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Unsupported file type')),
//           );
//         }
//       },
//       child: const Text('View File'),
//     );
//   }

//   Widget _buildActionButtons(BuildContext context, Map<String, dynamic> data) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         ElevatedButton(
//           onPressed: () => _acceptTicket(context, data),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
//           child: const Text('Accept'),
//         ),
//         ElevatedButton(
//           onPressed: () => _rejectTicket(context,data,FirebaseFirestore.instance, ticketData.id),
//           style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//           child: const Text('Reject'),
//         ),
//       ],
//     );
//   }

//   String _formatDate(dynamic timestamp) {
//     if (timestamp is List) {
//       return timestamp.isEmpty
//           ? 'No Date'
//           : timestamp.map((ts) {
//               if (ts is Timestamp) {
//                 final DateTime date = ts.toDate();
//                 return DateFormat('yyyy-MM-dd').format(date);
//               }
//               return '';
//             }).join(', ');
//     } else if (timestamp is Timestamp) {
//       final DateTime date = timestamp.toDate();
//       return DateFormat('yyyy-MM-dd').format(date);
//     }
//     return 'No Date';
//   }
// }



import 'package:intl/intl.dart'; // For date formatting
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task/screens/image_view_screen.dart';
import 'package:task/screens/pdf_view_screen.dart';
import 'package:http/http.dart' as http;

class TicketsDetailsScreen extends StatelessWidget {
  const TicketsDetailsScreen({super.key, required this.ticketData});
  final QueryDocumentSnapshot ticketData;

  // This method will be used to fetch data from Firestore and listen to changes in real time
  Stream<DocumentSnapshot> _getTicketStream(String ticketId) {
    return FirebaseFirestore.instance
        .collection('tickets')
        .doc(ticketId)
        .snapshots();
  }

  Future<void> _processTicketApproval(
    BuildContext context,
    Map<String, dynamic> data,
    FirebaseFirestore firestore,
    String ticketId,
  ) async {
    final docRef = firestore.collection('tickets').doc(ticketId);
    final leaveCountsDocRef =
        firestore.collection('leaveCounts').doc(data['uid']);

    try {
      // Fetch ticket data from Firestore
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Ticket not found')),
        );
        return;
      }

      // Fetch user's leave count data
      final leaveCountsDocSnapshot = await leaveCountsDocRef.get();
      if (!leaveCountsDocSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: User leave count data not found')),
        );
        return;
      }

      final leaveCounts = leaveCountsDocSnapshot.data() as Map<String, dynamic>;
      final List<dynamic>? timestamps = data['datesOfRequirement'];
      final int leaveDays = timestamps?.length ?? 0;

      // Determine leave category and check balance
      final String? subCategory = data['subCategory'];
      if (subCategory == null ||
          !leaveCounts.containsKey('${subCategory}LeaveCount')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid leave category')),
        );
        return;
      }

      final int currentLeaveBalance = leaveCounts['${subCategory}LeaveCount'];
      if (leaveDays > currentLeaveBalance) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient leave days. You only have $currentLeaveBalance days available in $subCategory.',
            ),
          ),
        );
        return;
      }

      // Update the ticket status to 'Approved'
      await docRef.update({
        'status': 'Approved',
        'isApproved': true,
      });

      // Update the leave count
      await leaveCountsDocRef.update({
        '${subCategory}LeaveCount': currentLeaveBalance - leaveDays,
      });

      final int remainingLeaves = currentLeaveBalance - leaveDays;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Leave approved. Applied days: $leaveDays. Remaining $subCategory leave days: $remainingLeaves.',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing ticket: $e')),
      );
    }
  }

  Future<void> _acceptTicket(
      BuildContext context, Map<String, dynamic> data) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String ticketId = ticketData.id;

    final docRef = firestore.collection('tickets').doc(ticketId);

    if (data['category'] == 'Remuneration') {
      final String? adminMessage =
          await _getAdminMessage(context, 'Enter approval message');
      if (adminMessage == null) return;

      try {
        await docRef.update({
          'status': 'Approved',
          'adminMessage': adminMessage,
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Ticket Approved')));
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      await _processTicketApproval(context, data, firestore, ticketId);
    }
  }

  Future<void> _rejectTicket(
    BuildContext context,
    Map<String, dynamic> data,
    FirebaseFirestore firestore,
    String ticketId,
  ) async {
    final docRef = firestore.collection('tickets').doc(ticketId);
    final leaveCountsDocRef =
        firestore.collection('leaveCounts').doc(data['uid']);

    // Check if the ticket exists
    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Ticket not found')));
      return;
    }

    // Check if ticketId is valid
    if (ticketId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Invalid Ticket ID')));
      return;
    }

    // Get the rejection reason from admin
    final String? rejectionReason =
        await _getAdminMessage(context, 'Enter rejection reason');
    if (rejectionReason == null) return;

    try {
      // Fetch leave counts data
      final leaveCountsDocSnapshot = await leaveCountsDocRef.get();
      if (!leaveCountsDocSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: User leave count data not found')),
        );
        return;
      }

      final leaveCounts = leaveCountsDocSnapshot.data() as Map<String, dynamic>;

      // Get the leave days requested
      final List<dynamic>? timestamps = data['datesOfRequirement'];
      final int leaveDays = timestamps?.length ?? 0;

      final String subCategory = data['subCategory'] ?? '';
      print('Rejection: Leave Category - $subCategory');
      print('Requested Leave Days: $leaveDays');
      print('Current Leave Count: ${leaveCounts['${subCategory}LeaveCount']}');

      // Update the leave count based on the subcategory
      // if (subCategory == 'unpaid') {
      //   await leaveCountsDocRef.update({
      //     'unpaidLeaveCount': (leaveCounts['unpaidLeaveCount'] ?? 0) - leaveDays,
      //   });
      // } else if (subCategory == 'casual') {
      //   await leaveCountsDocRef.update({
      //     'casualLeaveCount': (leaveCounts['casualLeaveCount'] ?? 0) - leaveDays,
      //   });
      // } else if (subCategory == 'medical') {
      //   await leaveCountsDocRef.update({
      //     'medicalLeaveCount': (leaveCounts['medicalLeaveCount'] ?? 0) - leaveDays,
      //   });
      // }

      // Update the ticket status to rejected
      await docRef.update({
        'status': 'Rejected',
        'adminMessage': rejectionReason,
      });

      // Show confirmation snack bar
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Ticket Rejected')));

      // Print final leave counts after update (for debugging purposes)
      final updatedLeaveCounts = await leaveCountsDocRef.get();
      print('Updated Leave Counts: ${updatedLeaveCounts.data()}');
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  // Method for real-time Firestore data update
  Future<String?> _getAdminMessage(BuildContext context, String prompt) async {
    final TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(prompt),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter message here'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'open':
      default:
        return Colors.blue;
    }
  }

  Future<String?> _getFileType(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.headers['content-type'];
    } catch (e) {
      return null; // Handle errors gracefully
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   final String ticketId = ticketData.id;

  //   return Scaffold(
  //     appBar: AppBar(
  //       title: const Text('Ticket Details'),
  //       centerTitle: true,
  //     ),
  //     body: StreamBuilder<DocumentSnapshot>(
  //       stream: _getTicketStream(ticketId), // Listen to ticket document updates
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.waiting) {
  //           return const Center(child: CircularProgressIndicator());
  //         }

  //         if (snapshot.hasError) {
  //           return Center(child: Text('Error: ${snapshot.error}'));
  //         }

  //         if (!snapshot.hasData || !snapshot.data!.exists) {
  //           return const Center(child: Text('Ticket not found'));
  //         }

  //         final data = snapshot.data!.data() as Map<String, dynamic>;
  //         final String status = data['status'] ?? 'Open';
  //         final String userId = data['uid'];

  //         return StreamBuilder<DocumentSnapshot>(
  //             stream: FirebaseFirestore.instance
  //                 .collection('users')
  //                 .doc(userId)
  //                 .snapshots(),
  //             builder: (context, userSnapshot) {
  //               if (userSnapshot.connectionState == ConnectionState.waiting) {
  //                 return const Center(child: CircularProgressIndicator());
  //               }

  //               if (userSnapshot.hasError) {
  //                 return Center(child: Text('Error: ${userSnapshot.error}'));
  //               }

  //               if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
  //                 return const Center(child: Text('User not found'));
  //               }

  //               final userData =
  //                   userSnapshot.data!.data() as Map<String, dynamic>;
  //               final String userIdField =
  //                   userData['id'] ?? 'N/A'; // Get the `id` field
  //               return SingleChildScrollView(
  //                   padding: const EdgeInsets.all(16.0),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       _buildHeader(data, status),
  //                       const SizedBox(height: 16),
  //                       _buildDetailRow('User ID:', userIdField),
  //                       _buildDetailRow('User Name:', data['name']),
  //                       _buildDetailRow('Description:', data['description']),
  //                       _buildDetailRow('Main Category:', data['mainCategory']),
  //                       _buildDetailRow('Sub Category:', data['subCategory']),
  //                       _buildDetailRow('Date of Requirement:',
  //                           _formatDate(data['datesOfRequirement'])),
  //                       const SizedBox(height: 16),
  //                       if (data['fileUrl'] != null)
  //                         _buildFileViewButton(context, data['fileUrl']),
  //                       if (status.toLowerCase() == 'rejected')
  //                         Padding(
  //                           padding: const EdgeInsets.only(top: 8.0),
  //                           child: Text(
  //                             'Rejection Reason: ${data['adminMessage'] ?? 'No Reason Provided'}',
  //                             style: const TextStyle(color: Colors.red),
  //                           ),
  //                         ),
  //                       if (status.toLowerCase() != 'approved' &&
  //                           status.toLowerCase() != 'rejected')
  //                         _buildActionButtons(context, data),
  //                     ],
  //                   ));
  //             });
  //       },
  //     ),
  //   );
  // }

  @override
Widget build(BuildContext context) {
  final String ticketId = ticketData.id;

  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.orange.shade600,
      title: const Text('Ticket Details'),
      centerTitle: true,
    ),
    body: StreamBuilder<DocumentSnapshot>(
      stream: _getTicketStream(ticketId), // Listen to ticket document updates
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Ticket not found'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final String status = data['status'] ?? 'Open';
        final String userId = data['uid'];

        return StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .snapshots(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(child: Text('User not found'));
              }

              final userData =
                  userSnapshot.data!.data() as Map<String, dynamic>;
              final String userIdField =
                  userData['id'] ?? 'N/A'; // Get the `id` field

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ticket Header Card
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(data, status),
                          ],
                        ),
                      ),
                    ),
                    // User Details Card
                    Card(
                      color: Colors.white,
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('User ID:', userIdField),
                            _buildDetailRow('User Name:', data['name']),
                            _buildDetailRow('Description:', data['description']),
                            _buildDetailRow('Main Category:', data['mainCategory']),
                            _buildDetailRow('Sub Category:', data['subCategory']),
                            _buildDetailRow('Date of Requirement:',
                                _formatDate(data['datesOfRequirement'])),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // File Attachment Card
                    if (data['fileUrl'] != null)
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildFileViewButton(context, data['fileUrl']),
                        ),
                      ),
                    // Rejection Reason Card
                    if (status.toLowerCase() == 'rejected')
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Rejection Reason: ${data['adminMessage'] ?? 'No Reason Provided'}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),
                    // Action Buttons Card
                    if (status.toLowerCase() != 'approved' &&
                        status.toLowerCase() != 'rejected')
                      Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _buildActionButtons(context, data),
                        ),
                      ),
                  ],
                ),
              );
            });
      },
    ),
  );
}

  Widget _buildHeader(Map<String, dynamic> data, String status) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Ticket: ${data['title'] ?? 'No Title'}',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Chip(
          label: Text(
            status.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: _getStatusColor(status),
        ),
      ],
    );
  }

  // Widget _buildDetailRow(String label, String? value) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           '$label ',
  //           style: const TextStyle(fontWeight: FontWeight.bold),
  //         ),
  //         Expanded(
  //           child: Text(value ?? 'N/A', style: const TextStyle(fontSize: 16)),
  //         ),
  //       ],
  //     ),
  //   );
  // }
Widget _buildDetailRow(String title, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2, // Adjust flex value to allocate space
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            softWrap: true,
            overflow: TextOverflow.ellipsis, // Truncate if too long
            maxLines: 2, // Allows for wrapping if necessary
          ),
        ),
      ],
    ),
  );
}
  Widget _buildFileViewButton(BuildContext context, String fileUrl) {
    return ElevatedButton(
      onPressed: () async {
        final fileType = await _getFileType(fileUrl);
        if (fileType == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not determine file type')),
          );
          return;
        }

        if (fileType.contains('pdf')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfViewerScreen(fileUrl: fileUrl),
            ),
          );
        } else if (fileType.contains('image')) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ImageViewerScreen(fileUrl: fileUrl),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unsupported file type')),
          );
        }
      },
      child: const Text('View File'),
    );
  }

  Widget _buildActionButtons(BuildContext context, Map<String, dynamic> data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => _acceptTicket(context, data),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('Accept'),
        ),
        ElevatedButton(
          onPressed: () => _rejectTicket(
              context, data, FirebaseFirestore.instance, ticketData.id),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Reject'),
        ),
      ],
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is List) {
      return timestamp.isEmpty
          ? 'No Date'
          : timestamp.map((ts) {
              if (ts is Timestamp) {
                final DateTime date = ts.toDate();
                return DateFormat('yyyy-MM-dd').format(date);
              }
              return '';
            }).join(', ');
    } else if (timestamp is Timestamp) {
      final DateTime date = timestamp.toDate();
      return DateFormat('yyyy-MM-dd').format(date);
    }
    return 'No Date';
  }
}
