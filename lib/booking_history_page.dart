import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class BookingHistoryPage extends StatelessWidget {
  const BookingHistoryPage({super.key});

  Future<void> cancelBooking(
      String bookingId,
      String slot,
      ) async {

    final uid =
        FirebaseAuth.instance
            .currentUser!
            .uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('bookings')
        .doc(bookingId)
        .update({

      'status':
      'cancelled',
    });

    await FirebaseFirestore.instance
        .collection('stations')
        .doc('station_1')
        .update({

      'slots.$slot':
      true,
    });
  }

  @override
  Widget build(BuildContext context) {

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Booking History",
        ),

        backgroundColor: Colors.green[800],

        foregroundColor: Colors.white,
      ),

      body: StreamBuilder<QuerySnapshot>(

        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('bookings')
            .orderBy(
          'timestamp',
          descending: true,
        )
            .snapshots(),

        builder: (context, snapshot) {

          if (!snapshot.hasData) {

            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          final bookings =
              snapshot.data!.docs;

          if (bookings.isEmpty) {

            return const Center(
              child: Text(
                "No bookings found",
              ),
            );
          }

          return ListView.builder(

            itemCount: bookings.length,

            itemBuilder: (context, index) {

              var booking =
              bookings[index];

              String status =
              booking.data().toString()
                  .contains('status')

                  ? booking['status']
                  : 'active';

              return Card(

                elevation: 4,

                margin:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),

                child: Padding(

                  padding:
                  const EdgeInsets.all(12),

                  child: Column(

                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [

                      // STATION NAME
                      Text(
                        booking['stationName'],

                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // DATE
                      Row(
                        children: [

                          Icon(
                            Icons.calendar_today,
                            size: 18,
                            color:
                            Colors.green[800],
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Date: ${booking['date']}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // SLOT
                      Row(
                        children: [

                          Icon(
                            Icons.access_time,
                            size: 18,
                            color:
                            Colors.orange,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Slot: ${booking['slot']}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // AMOUNT
                      Row(
                        children: [

                          Icon(
                            Icons.currency_rupee,
                            size: 18,
                            color:
                            Colors.blue,
                          ),

                          const SizedBox(width: 8),

                          Text(
                            "Amount: ₹${booking['amount']}",
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // STATUS
                      Row(
                        children: [

                          Icon(

                            status == 'active'
                                ? Icons.check_circle
                                : Icons.cancel,

                            size: 18,

                            color:
                            status == 'active'
                                ? Colors.green
                                : Colors.red,
                          ),

                          const SizedBox(width: 8),

                          Text(

                            "Status: $status",

                            style: TextStyle(

                              fontWeight:
                              FontWeight.bold,

                              color:
                              status == 'active'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // CANCEL BUTTON
                            status == 'active'

                          ? SizedBox(

                        width: double.infinity,
                        height: 45,

                        child: ElevatedButton.icon(

                          onPressed: () async {

                            await cancelBooking(
                              booking.id,
                              booking['slot'],
                            );

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(

                              const SnackBar(
                                content: Text(
                                  "Booking Cancelled",
                                ),
                              ),
                            );
                          },

                          style:
                          ElevatedButton.styleFrom(

                            backgroundColor:
                            Colors.red,

                            foregroundColor:
                            Colors.white,

                            shape:
                            RoundedRectangleBorder(

                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),

                          icon: const Icon(
                            Icons.cancel,
                          ),

                          label: const Text(
                            "Cancel Booking",
                          ),
                        ),
                      )

                          : Container(

                        width: double.infinity,
                        padding:
                        const EdgeInsets.all(12),

                        decoration: BoxDecoration(

                          color: Colors.red[50],

                          borderRadius:
                          BorderRadius.circular(
                            10,
                          ),
                        ),

                        child: const Center(

                          child: Text(

                            "Booking Cancelled",

                            style: TextStyle(
                              color: Colors.red,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}