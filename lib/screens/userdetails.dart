// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:syncfusion_flutter_calendar/calendar.dart';
// import 'package:task/models/Event_Data_source.dart';
// import 'package:task/screens/holiday_list_screen.dart';

// final formatter = DateFormat.yMd();

// class UserDetailsScreen extends StatefulWidget {
//   const UserDetailsScreen({super.key});

//   @override
//   State<UserDetailsScreen> createState() => _UserDetailsScreenState();
// }

// class _UserDetailsScreenState extends State<UserDetailsScreen> {
//   DateTime? _selectedDate;
//   List<Appointment> _firebaseHolidays = [];
//   List<Appointment> _firebaseEvents = [];
//   List<Appointment> _firebaseLeave = [];

//   @override
//   void initState() {
//     super.initState();
//     _fetchFirebaseHolidays();
//     _fetchFirebaseEvents();
//     _fetchFirebaseLeaves();
//   }

//   Future<void> _fetchFirebaseHolidays() async {
//     final QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('Compney Holiday').get();

//     final List<Appointment> firebaseHolidays = snapshot.docs.map((doc) {
//       DateTime date = (doc['date'] as Timestamp).toDate();
//       String description = doc['description'];

//       return Appointment(
//         startTime: date,
//         endTime: date,
//         subject: description,
//         color: Colors.red,
//       );
//     }).toList();

//     setState(() {
//       _firebaseHolidays = firebaseHolidays;
//     });
//   }
//    Future<void> _fetchFirebaseEvents() async {
//     final QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('Compney Events').get();

//     final List<Appointment> firebaseEvents = snapshot.docs.map((doc) {
//       DateTime date = (doc['date'] as Timestamp).toDate();
//       String description = doc['description'];

//       return Appointment(
//         startTime: date,
//         endTime: date,
//         subject: description,
//         color: Colors.blue,
//       );
//     }).toList();

//     setState(() {
//       _firebaseEvents = firebaseEvents;
//     });
//   }

//   Future<void> _fetchFirebaseLeaves() async {
//   final userId = FirebaseAuth.instance.currentUser!.uid;

//   // Fetch leaves for the logged-in user
//   final QuerySnapshot snapshot = await FirebaseFirestore.instance
//       .collection('tickets')
//       .where('uid', isEqualTo: userId)
//       .where('status', isEqualTo: 'Approved') // Only approved leaves
//       .get();

//   final List<Appointment> firebaseLeaves = snapshot.docs.map((doc) {

//     List<Timestamp> dates = List.from(doc['datesOfRequirement']);
//     String description = doc['description'];

//     return dates.map((date) {
//       DateTime dateTime = date.toDate();
//       return Appointment(
//         startTime: dateTime,
//         endTime: dateTime,
//         subject: description,
//         color: Colors.green,
//       );
//     }).toList();
//   }).expand((i) => i).toList(); // Flatten the list of lists into a single list

//   setState(() {
//     _firebaseLeave = firebaseLeaves;
//   });
// }

//   @override
//   Widget build(BuildContext context) {
//     // Future<void> _logOut(BuildContext context) async {
//     //   await FirebaseAuth.instance.signOut();
//     //   Navigator.of(context).pushReplacement(
//     //       MaterialPageRoute(builder: (ctx) => const OptionScreen()));
//     // }

//     List<Appointment> allEvents = [..._firebaseHolidays,..._firebaseEvents,..._firebaseLeave];

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.orange.shade600,
//         title: const Text("User Calendar"),
//         // actions: [
//         //   // IconButton(
//         //   //   onPressed: () => _logOut(context),
//         //   //   icon: const Icon(Icons.logout),
//         //   // )
//         // ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//               ),
//               child: Center(
//                 child: Card(
//                   margin: const EdgeInsets.all(16),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 400,
//                           child: SfCalendar(
//                             view: CalendarView.month,
//                             dataSource: EventDataSource(allEvents),
//                             monthViewSettings: const MonthViewSettings(
//                               showAgenda: true,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Container(
//               decoration: const BoxDecoration(
//                 color: Colors.white
//               ),
//               child: Column(
//                 children: [
//                   Center(
//                     child: Card(
//                       margin: const EdgeInsets.all(75),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16),
//                         child: ListTile(
//                           onTap: () {
//                             Navigator.of(context).push(MaterialPageRoute(
//                                 builder: (context) =>
//                                     const HolidayListScreen()));
//                           },
//                           title: const Text('View Holiday List'),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task/models/Event_Data_source.dart';
import 'package:task/screens/holiday_list_screen.dart';

final formatter = DateFormat.yMd();

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  List<Appointment> _firebaseHolidays = [];
  List<Appointment> _firebaseEvents = [];
  List<Appointment> _firebaseLeave = [];

  @override
  void initState() {
    super.initState();
    _fetchFirebaseHolidays();
    _fetchFirebaseEvents();
    _fetchFirebaseLeaves();
  }

  Future<void> _fetchFirebaseHolidays() async {
    final QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('Compney Holiday').get();

    final List<Appointment> firebaseHolidays = snapshot.docs.map((doc) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      String description = doc['description'];

      return Appointment(
        startTime: date,
        endTime: date,
        subject: description,
        color: Colors.red,
      );
    }).toList();

    setState(() {
      _firebaseHolidays = firebaseHolidays;
    });
  }

  // Future<void> _fetchFirebaseEvents() async {
  //   final QuerySnapshot snapshot =
  //       await FirebaseFirestore.instance.collection('Company Events').get();

  //   final List<Appointment> firebaseEvents = snapshot.docs.map((doc) {
  //     DateTime date = (doc['date'] as Timestamp).toDate();
  //     String description = doc['description'];

  //     return Appointment(
  //       startTime: date,
  //       endTime: date,
  //       subject: description,
  //       color: Colors.blue,
  //     );
  //   }).toList();

  //   setState(() {
  //     _firebaseEvents = firebaseEvents;
  //   });
  // }

  Future<void> _fetchFirebaseEvents() async {
  final QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('Company Events').get();

  final List<Appointment> firebaseEvents = snapshot.docs.map((doc) {
    DateTime date = (doc['date'] as Timestamp).toDate();
    String description = doc['description'];

    // Parse the start and end times from strings
    String startTimeString = doc['startTime'];
    String endTimeString = doc['endTime'];

    TimeOfDay startTime = TimeOfDay(
      hour: int.parse(startTimeString.split(':')[0]),
      minute: int.parse(startTimeString.split(':')[1].split(' ')[0]),
    );
    if (startTimeString.contains('PM') && startTime.hour != 12) {
      startTime = startTime.replacing(hour: startTime.hour + 12);
    } else if (startTimeString.contains('AM') && startTime.hour == 12) {
      startTime = startTime.replacing(hour: 0);
    }

    TimeOfDay endTime = TimeOfDay(
      hour: int.parse(endTimeString.split(':')[0]),
      minute: int.parse(endTimeString.split(':')[1].split(' ')[0]),
    );
    if (endTimeString.contains('PM') && endTime.hour != 12) {
      endTime = endTime.replacing(hour: endTime.hour + 12);
    } else if (endTimeString.contains('AM') && endTime.hour == 12) {
      endTime = endTime.replacing(hour: 0);
    }

    // Combine date with time
    DateTime startDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      startTime.hour,
      startTime.minute,
    );

    DateTime endDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      endTime.hour,
      endTime.minute,
    );

    return Appointment(
      startTime: startDateTime,
      endTime: endDateTime,
      subject: description,
      color: Colors.blue,
    );
  }).toList();

  setState(() {
    _firebaseEvents = firebaseEvents;
  });
}

  Future<void> _fetchFirebaseLeaves() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('uid', isEqualTo: userId)
        .where('status', isEqualTo: 'Approved')
        .get();

    final List<Appointment> firebaseLeaves = snapshot.docs
        .map((doc) {
          List<Timestamp> dates = List.from(doc['datesOfRequirement']);
          String description = doc['name'];// only change '' value

          return dates.map((date) {
            DateTime dateTime = date.toDate();
            return Appointment(
              startTime: dateTime,
              endTime: dateTime,
              subject: description,
              color: Colors.green,
            );
          }).toList();
        })
        .expand((i) => i)
        .toList();

    setState(() {
      _firebaseLeave = firebaseLeaves;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> allEvents = [
      ..._firebaseHolidays,
      ..._firebaseEvents,
      ..._firebaseLeave
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text("User Calendar"),
      ),
      body: Container(
        color: Colors.white,
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWideScreen = constraints.maxWidth > 600;
        
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isWideScreen
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: _buildCalendarCard(allEvents),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildHolidayListButton(context),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _buildCalendarCard(allEvents),
                          const SizedBox(height: 16),
                          _buildHolidayListButton(context),
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCalendarCard(List<Appointment> allEvents) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 400,
          child: SfCalendar(
            view: CalendarView.month,
            dataSource: EventDataSource(allEvents),
            monthViewSettings: const MonthViewSettings(showAgenda: true),
          ),
        ),
      ),
    );
  }

  Widget _buildHolidayListButton(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 4,
      child: ListTile(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const HolidayListScreen(),
            ),
          );
        },
        title: const Text('View Holiday List'),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }
}
