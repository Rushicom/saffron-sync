// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:task/screens/add_ticket_screen.dart';

// class UserTicketScreen extends StatelessWidget {
//   const UserTicketScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;
//     void addTicket() {
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (ctx) => const AddTicketScreen(),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text(
//           'Ticket Screen',
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.all(10.0),
//             child: FloatingActionButton.extended(
//               onPressed: addTicket,
//               backgroundColor: Colors.blue,
//               label: const Icon(
//                 Icons.add,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//         ],
//       ),
//       body: user != Null ? StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection('tickets').where('uid',isEqualTo: user?.uid).snapshots(), builder: (context, snapshot){
//           if(snapshot.connectionState == ConnectionState.waiting){
//             return const Center(child:  CircularProgressIndicator(),);
//           }
//           if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
//             return const Center(
//               child: Text('No Tickets are genrated'),
//             );
//           }
//           final tickets = snapshot.data!.docs;
//           return ListView.builder(itemCount: tickets.length,itemBuilder: (context, Index){
//             final ticket = tickets[Index];
//             return ListTile(
//               title: Text(ticket['title']),
//               subtitle: Text(ticket['description']),
//               trailing: Text(ticket['status']),
//               onTap: (){

//               },
//             );
//           });
//       }) :const Text("plese login to view your tickets....")
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'add_ticket_screen.dart';
import 'user_ticket_details_screen.dart';

class UserTicketScreen extends StatelessWidget {
  const UserTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    void addTicket() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (ctx) => const AddTicketScreen(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text(
          'My Tickets',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: FloatingActionButton.extended(
              onPressed: addTicket,
              backgroundColor: Colors.blue,
              label: const Row(
                children:  [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Add Ticket',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: user != null
          ? Container(
              decoration:  BoxDecoration(color: Colors.grey.shade200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tickets')
                    .where('uid', isEqualTo: user!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'No Tickets have been generated.',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  final tickets = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: tickets.length,
                    itemBuilder: (context, index) {
                      final ticket = tickets[index].data() as Map<String, dynamic>;

                      return Card(
                        color: Colors.white,
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: ticket['status'] == 'Approved'
                                ? Colors.green
                                : ticket['status'] == 'Rejected'
                                    ? Colors.red
                                    : Colors.orange,
                            child: const Icon(
                              Icons.confirmation_num,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            ticket['title'] ?? 'No Title',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ticket['description'] ?? 'No Description',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (ticket.containsKey('adminMessage'))
                                Text(
                                  ticket['status'] == 'Approved'
                                      ? 'Admin Message: ${ticket['adminMessage']}'
                                      : 'Rejection Reason: ${ticket['adminMessage']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: ticket['status'] == 'Approved'
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            ticket['status'] ?? 'Pending',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: ticket['status'] == 'Approved'
                                  ? Colors.green
                                  : ticket['status'] == 'Rejected'
                                      ? Colors.red
                                      : Colors.orange,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => UserTicketDetailsScreen(
                                  ticket: ticket,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            )
          : const Center(
              child: Text(
                "Please login to view your tickets.",
                style: TextStyle(fontSize: 16),
              ),
            ),
    );
  }
}


