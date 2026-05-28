import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class BookingPage extends StatefulWidget {
  final String stationName;
  final String address;
  final String plugType;
  final String power;
  final String timing;
  final String price;

  const BookingPage({
    super.key,
    required this.stationName,
    required this.address,
    required this.plugType,
    required this.power,
    required this.timing,
    required this.price,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String stationId = "station_1";

  String? selectedSlot;


  int unitsToCharge = 10;

  final double pricePerUnit = 18.0;

  DateTime selectedDate = DateTime.now();

  bool isFavorite = false;

  final user = FirebaseAuth.instance.currentUser;







  void _callSupport() {
    launchUrl(Uri.parse("tel:+919876543210"));
  }

  void _emailSupport() {
    launchUrl(
      Uri.parse(
        "mailto:support@voltspot.in?subject=Help with ${widget.stationName}",
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 30),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> startUPIPayment(double amount) async {

    final upiUrl = Uri.parse(
      "upi://pay"
          "?pa=UPI ID"
          "&pn=VoltSpot"
          "&tn=EV Charging Booking"
          "&am=${amount.toStringAsFixed(2)}"
          "&cu=INR",
    );

    bool launched = await launchUrl(
      upiUrl,
      mode: LaunchMode.externalApplication,
    );

    if (!launched) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No UPI app found"),
        ),
      );
      return;
    }

    // WAIT until user comes back to app
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;

    bool? paid = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Payment Status"),
          content: const Text(
            "Have you completed the payment?",
          ),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("No"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    if (paid == true) {

      await _bookSlot(amount);

      _showReceipt(amount);

    } else {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment Cancelled"),
        ),
      );
    }
  }


  // BOOK SLOT
  Future<void> _bookSlot(double amount) async {
    if (selectedSlot == null) return;

    try {
      // UPDATE SLOT
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('stations')
          .doc(stationId)
          .update({
        'slots.$selectedSlot': false,
      });
      await FirebaseFirestore.instance
          .collection('bookings')
          .add({

        'userId': user!.uid,
        'stationName': widget.stationName,
        'slot': selectedSlot,
        'amount': amount,
        'status': 'active',
        'date': selectedDate.toString(),
        'createdAt': Timestamp.now(),
      });


      // SAVE BOOKING HISTORY
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('bookings')
          .add({
        'stationName': widget.stationName,
        'address': widget.address,
        'slot': selectedSlot,
        'date':
        "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
        'amount': amount,
        'units': unitsToCharge,
        'status':'active',
        'timestamp': Timestamp.now(),
      });


    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Booking Failed: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalAmount = unitsToCharge * pricePerUnit;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.electric_car),
            const SizedBox(width: 10),
            const Text("Booking & Payment"),
            const Spacer(),

          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              widget.stationName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              widget.address,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // LIVE AVAILABILITY
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                children: const [
                  Icon(Icons.ev_station, color: Colors.green),
                  SizedBox(width: 10),

                  Text(
                    "Live Charger Status Available",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Station Details",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                _detailTile(
                  Icons.electrical_services,
                  "Plug",
                  widget.plugType,
                ),

                _detailTile(
                  Icons.bolt,
                  "Power",
                  widget.power,
                ),
              ],
            ),

            const SizedBox(height: 15),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [
                _detailTile(
                  Icons.access_time,
                  "Timing",
                  widget.timing,
                ),

                _detailTile(
                  Icons.currency_rupee,
                  "Price",
                  widget.price,
                ),
              ],
            ),

            const Divider(height: 35),

            // HELP SECTION
            const Text(
              "Need Help?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _callSupport,
                    icon: const Icon(Icons.phone),
                    label: const Text("Call Us"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _emailSupport,
                    icon: const Icon(Icons.email),
                    label: const Text("Email"),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // DATE PICKER
            const Text(
              "Select Booking Date",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            InkWell(
              onTap: () => _selectDate(context),

              child: Container(
                padding: const EdgeInsets.all(15),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),

                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,

                  children: [

                    Text(
                      "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text("Change"),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // SLOT SECTION
            const Text(
              "Select Time Slot",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('stations')
                  .doc(stationId)
                  .snapshots(),

              builder: (context, snapshot) {

                if (!snapshot.hasData ||
                    snapshot.data!.data() == null) {

                  return const Text(
                    "No slot data found",
                  );
                }

                var data =
                snapshot.data!.data()
                as Map<String, dynamic>;

                Map<String, dynamic> slots =
                Map<String, dynamic>.from(
                  data['slots'] ?? {},
                );

                return Wrap(
                  spacing: 8,

                  children:
                  slots.entries.map((slot) {

                    bool available =
                        slot.value == true;

                    return ChoiceChip(
                      label: Text(slot.key),

                      selected:
                      selectedSlot == slot.key,

                      selectedColor:
                      Colors.green[100],

                      disabledColor:
                      Colors.red[100],

                      onSelected: available
                          ? (val) {
                        setState(() {
                          selectedSlot =
                          val
                              ? slot.key
                              : null;
                        });
                      }
                          : null,
                    );

                  }).toList(),
                );
              },
            ),

            const SizedBox(height: 30),

            // UNIT SELECTOR
            const Text(
              "Units to Charge",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.center,

              children: [

                IconButton(
                  onPressed: () {
                    setState(() {
                      if (unitsToCharge > 1) {
                        unitsToCharge--;
                      }
                    });
                  },

                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                  ),
                ),

                Text(
                  "$unitsToCharge kWh",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: () {
                    setState(() {
                      unitsToCharge++;
                    });
                  },

                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // TOTAL
            Container(
              padding: const EdgeInsets.all(15),

              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),

              child: Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,

                children: [

                  const Text(
                    "Grand Total",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "₹${totalAmount.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // PAYMENT BUTTON
            SizedBox(
              width: double.infinity,
              height: 55,

              child: ElevatedButton.icon(
                onPressed:
                selectedSlot == null
                    ? null
                    : () => startUPIPayment(
                    totalAmount),

                icon: const Icon(
                  Icons.payment,
                  color: Colors.white,
                ),

                label: Text(
                  selectedSlot == null
                      ? "Select Slot First"
                      : "Pay ₹${totalAmount.toStringAsFixed(2)}",

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(
      IconData icon,
      String label,
      String value,
      ) {

    return SizedBox(
      width:
      MediaQuery.of(context).size.width * 0.42,

      child: Row(
        children: [

          Icon(
            icon,
            color: Colors.green[800],
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showReceipt(double amount){

    showDialog(

      context: context,

      builder:(context){

        return Dialog(

          shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(20),
          ),

          child: Padding(

            padding:
            const EdgeInsets.all(20),

            child: Column(

              mainAxisSize:
              MainAxisSize.min,

              children:[

                const CircleAvatar(

                  radius:35,

                  backgroundColor:
                  Colors.green,

                  child: Icon(

                    Icons.check,

                    color: Colors.white,

                    size:40,
                  ),
                ),

                const SizedBox(height:15),

                const Text(

                  "Payment Successful",

                  style: TextStyle(

                    fontSize:22,

                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height:20),

                _receiptRow(
                  "Station",
                  widget.stationName,
                ),

                _receiptRow(
                  "Slot",
                  selectedSlot ?? "",
                ),

                _receiptRow(
                  "Date",

                  "${selectedDate.day}/"
                      "${selectedDate.month}/"
                      "${selectedDate.year}",
                ),

                _receiptRow(
                  "Units",
                  "$unitsToCharge kWh",
                ),

                _receiptRow(
                  "Amount",
                  "₹${amount.toStringAsFixed(2)}",
                ),

                const Divider(),

                const Text(

                  "Thank you for booking",

                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height:15),

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      Colors.green,
                    ),

                    onPressed:(){

                      Navigator.pop(context);

                      Navigator.pop(context);
                    },

                    child: const Text(

                      "DONE",

                      style: TextStyle(
                        color: Colors.white,
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
  }

  Widget _receiptRow(
      String title,
      String value){

    return Padding(

      padding:
      const EdgeInsets.symmetric(
        vertical:6,
      ),

      child: Row(

        mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,

        children:[

          Text(

            title,

            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          Text(

            value,

            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}