// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:task/screens/add_events_screen.dart';
// import 'package:task/screens/add_holiday.dart';


// class AdminDetailsScreen extends StatefulWidget {
//   const AdminDetailsScreen({super.key});

//   @override
//   State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
// }

// class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
//   late Map<DateTime, List<String>> _events = {};
//   DateTime _selectedDay = DateTime.now();
//   List<String> _selectedEvents = [];
//   @override
//   void initState() {
//     super.initState();
//     _fetchEvents();
//   }

//   Future<void> _fetchEvents() async {
//     final eventsSnapshot =
//         await FirebaseFirestore.instance.collection('Compney Events').get();
//     final holidaysSnapshot =
//         await FirebaseFirestore.instance.collection('Compney Holidays').get();
//          final leavesSnapshot =
//         await FirebaseFirestore.instance.collection('Compney Holidays').get();

//     Map<DateTime, List<String>> loadedEvents = {};

//     for (var doc in eventsSnapshot.docs) {
//       DateTime date = (doc['date'] as Timestamp).toDate();
//       String description = doc['description'];
//       loadedEvents[date] = [...?loadedEvents[date], description];
//     }

//     for (var doc in holidaysSnapshot.docs) {
//       DateTime date = (doc['date'] as Timestamp).toDate();
//       String description = doc['description'];
//       loadedEvents[date] = [...?loadedEvents[date], description];
//     }
//     for (var doc in leavesSnapshot.docs) {
//       DateTime date = (doc['datesOfRequirement'] as Timestamp).toDate();
//       String description = doc['description'];
//       loadedEvents[date] = [...?loadedEvents[date], description];
//     }

//     setState(() {
//       _events = loadedEvents;
//       _selectedEvents = _getEventsForDay(_selectedDay);
//     });
//   }

//   List<String> _getEventsForDay(DateTime day) {
//     return _events[DateTime(day.year, day.month, day.day)] ?? [];
//   }

//   @override
//   Widget build(BuildContext context) {
  

//     void addHoliday() {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (ctx) => const AddHolidayScreen()));
//     }

//     void addEvents() {
//       Navigator.of(context)
//           .push(MaterialPageRoute(builder: (ctx) => const AddEventsScreen()));
//     }

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.orange.shade600,
//         title: const Text('Holidays'),
       
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           color: Colors.white,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: SingleChildScrollView(
//             // Make the entire body scrollable
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 4,
//                   child: ListTile(
//                     leading: Icon(
//                       Icons.calendar_today,
//                       color: Colors.red.shade700,
//                     ),
//                     title: const Text(
//                       'Add company Holiday', // Fixed typo (company)
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     onTap: addHoliday,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Card(
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 4,
//                   child: ListTile(
//                     leading: Icon(Icons.event, color: Colors.blue.shade700),
//                     title: const Text(
//                       'Add company Events', // Fixed typo (company)
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     onTap: addEvents,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 const Text(
//                   'Company Calendar',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 TableCalendar(
//                   firstDay: DateTime.utc(2023, 1, 1),
//                   lastDay: DateTime.utc(2025, 12, 31),
//                   focusedDay: _selectedDay,
//                   selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
//                   onDaySelected: (selectedDay, focusedDay) {
//                     setState(() {
//                       _selectedDay = selectedDay;
//                       _selectedEvents = _getEventsForDay(selectedDay);
//                     });
//                   },
//                   calendarStyle: CalendarStyle(
//                     holidayDecoration: BoxDecoration(
//                       color: Colors.green.shade200,
//                       shape: BoxShape.circle,
//                     ),
//                     weekendDecoration: BoxDecoration(
//                       color: Colors.red.shade200,
//                       shape: BoxShape.circle,
//                     ),
//                     markersMaxCount: 1,
//                   ),
//                   eventLoader: _getEventsForDay,
//                   headerStyle: const HeaderStyle(
//                     formatButtonVisible: false,
//                     titleCentered: true,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _selectedEvents.isEmpty
//                     ? const Center(child: Text('No events for this day.'))
//                     : ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: _selectedEvents.length,
//                         itemBuilder: (context, index) => ListTile(
//                           leading: const Icon(Icons.event),
//                           title: Text(_selectedEvents[index]),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:task/models/Event_Data_source.dart';
import 'package:task/screens/add_events_screen.dart';
import 'package:task/screens/add_holiday.dart';

class AdminDetailsScreen extends StatefulWidget {
  const AdminDetailsScreen({super.key});

  @override
  State<AdminDetailsScreen> createState() => _AdminDetailsScreenState();
}

class _AdminDetailsScreenState extends State<AdminDetailsScreen> {
  
  final List<String> _selectedEvents = [];

  List<Appointment> _firebaseHolidays = [];
  List<Appointment> _firebaseEvents = [];
  List<Appointment> _firebaseLeaves = [];

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
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('tickets')
        .where('status', isEqualTo: 'Approved')
        .get();

    final List<Appointment> firebaseLeaves = snapshot.docs
        .map((doc) {
          List<Timestamp> dates = List.from(doc['datesOfRequirement']);
          String description = doc['name']; // description added past 

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
      _firebaseLeaves = firebaseLeaves;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> allEvents = [
      ..._firebaseHolidays,
      ..._firebaseEvents,
      ..._firebaseLeaves
    ];

    void addHoliday() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const AddHolidayScreen()));
    }

    void addEvents() {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (ctx) => const AddEventsScreen()));
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.orange.shade600,
        title: const Text('Holidays'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            // Make the entire body scrollable
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(
                      Icons.calendar_today,
                      color: Colors.red.shade700,
                    ),
                    title: const Text(
                      'Add company Holiday', // Fixed typo (company)
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: addHoliday,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  child: ListTile(
                    leading: Icon(Icons.event, color: Colors.blue.shade700),
                    title: const Text(
                      'Add company Events', // Fixed typo (company)
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: addEvents,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Company Calendar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 400,
                      child: SfCalendar(
                        view: CalendarView.month,
                        dataSource: EventDataSource(allEvents),
                        monthViewSettings: const MonthViewSettings(
                          showAgenda: true,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _selectedEvents.isEmpty
                    ? const Center(child: Text('No events for this day.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedEvents.length,
                        itemBuilder: (context, index) => ListTile(
                          leading: const Icon(Icons.event),
                          title: Text(_selectedEvents[index]),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
