// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:task/screens/tickets_details_screen.dart';

// class AdminShowTicketScreen extends StatelessWidget {
//   const AdminShowTicketScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.orange.shade600,
//         title: const Text('User Tickets'),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//            color: Colors.white
//             ),
//         child: StreamBuilder(
//           stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
//           builder: (context, Snapshot) {
//             if (Snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(
//                 child: CircularProgressIndicator(),
//               );
//             }
//             if (!Snapshot.hasData || Snapshot.data!.docs.isEmpty) {
//               return const Center(
//                 child: Text('no tickets available'),
//               );
//             }
//             final tickets = Snapshot.data!.docs;
//             return ListView.builder(
//               itemCount: tickets.length,
//               itemBuilder: (context, Index) {
//                 final ticket = tickets[Index];

//                 return GestureDetector(
//                   onTap: () {
//                     Navigator.of(context).push(MaterialPageRoute(
//                         builder: (ctx) => TicketsDetailsScreen(
//                               ticketData: ticket,
//                             )));
//                   },
//                   child: Card(
//                     color: Colors.white,
//                     elevation: 4,
//                     margin:
//                         const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Ticket Name: ${ticket['title'] ?? 'no name'}',
//                             style: const TextStyle(
//                                 fontWeight: FontWeight.bold, fontSize: 18),
//                           ),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text(
//                               'Description: ${ticket['description'] ?? 'no description'}'),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text('Ticket Id: ${ticket['ticketId'] ?? 'no ticket id'}'),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text('send by employed: ${ticket['name']}'),
//                           const SizedBox(
//                             height: 8,
//                           ),
//                           Text('Status: ${ticket['status']}'),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }




import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:task/screens/tickets_details_screen.dart';

class AdminShowTicketScreen extends StatelessWidget {
  const AdminShowTicketScreen({super.key});

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.orange.shade600,
      title: const Text('User Tickets'),
    ),
    body: Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tickets').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No tickets available'));
          }

          final tickets = snapshot.data!.docs;
          return ListView.builder(
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final ticket = tickets[index];

              // Determine color based on ticket status
              Color statusColor;
              if (ticket['status'] == 'Approved') {
                statusColor = Colors.green;
              } else if (ticket['status'] == 'Rejected') {
                statusColor = Colors.red;
              } else {
                statusColor = Colors.blue; // For 'Pending' or any other status
              }

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => TicketsDetailsScreen(
                      ticketData: ticket,
                    ),
                  ));
                },
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: statusColor, // Color indicator based on status
                      child: const Icon(
                        Icons.confirmation_num,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Ticket Name: ${ticket['title'] ?? 'No Name'}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: ${ticket['description'] ?? 'No Description'}'),
                        const SizedBox(height: 8),
                        Text('Ticket ID: ${ticket['ticketId'] ?? 'No Ticket Id'}'),
                        const SizedBox(height: 8),
                        Text('Submitted by: ${ticket['name'] ?? 'Unknown'}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Status: ${ticket['status'] ?? 'Unknown'}'),
                        const SizedBox(width: 8),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
}