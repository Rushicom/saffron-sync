// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class HolidayListScreen extends StatefulWidget {
//   const HolidayListScreen({super.key});

//   @override
//   State<HolidayListScreen> createState() => _HolidayListScreenState();
// }

// class _HolidayListScreenState extends State<HolidayListScreen> {
//   final List _holiday = [];
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   bool _isloading = true;

//  getHoliday(){
//   return _firestore.collection('Compney Holiday').get().then((QuerySnapshot querySnapshot){
//     querySnapshot.docs.forEach((doc){
//       setState(() {
//         _holiday.add(doc['description']);
//       });
//     });
//   });
//  }

//  @override
//   void initState() {
//     getHoliday();
//     super.initState();
//   }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Compeny Holiday List'),
//       ),
//       body: ListView.builder(itemBuilder: (context, Index) {
//         return ListTile(
//           title: Text(
//             _holiday[Index]
//           ),
//         );
//       }),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HolidayListScreen extends StatefulWidget {
  const HolidayListScreen({super.key});

  @override
  State<HolidayListScreen> createState() => _HolidayListScreenState();
}

class _HolidayListScreenState extends State<HolidayListScreen> {
  final List _holiday = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;  // To track loading state

  getHoliday() async {
    await _firestore.collection('Compney Holiday').get().then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        setState(() {
          _holiday.add(doc['description']);
        });
      });
      setState(() {
        _isLoading = false;  
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getHoliday();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange.shade600,
        title: const Text('Company Holiday List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())  
          : _holiday.isEmpty  
              ? const Center(child: Text("No holidays found"))
              : ListView.builder(
                  itemCount: _holiday.length,  
                  itemBuilder: (context, index) {
                    return Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          child: ListTile(
                            title: Text(
                              _holiday[index],
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
