import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'main.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() =>
      _ProfileSetupPageState();
}

class _ProfileSetupPageState
    extends State<ProfileSetupPage> {

  final nameController =
  TextEditingController();

  final vehicleNumberController =
  TextEditingController();

  final vehicleModelController =
  TextEditingController();

  final batteryController =
  TextEditingController();

  String vehicleType = "Car";

  String chargerType =
      "CCS2 (Fast Charger)";

  Future<void> saveProfile() async {

    final uid =
        FirebaseAuth.instance
            .currentUser!
            .uid;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({

      'vehicleName':
      vehicleModelController.text.trim(),

      'vehicleNumber':
      vehicleNumberController.text.trim(),

      'batteryCapacity':
      batteryController.text.trim(),

      'vehicleType':
      vehicleType,

      'chargerType':
      chargerType,

    }, SetOptions(merge: true));

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('vehicles')
        .add({

      'vehicleName':
      vehicleModelController
          .text
          .trim(),

      'vehicleNumber':
      vehicleNumberController
          .text
          .trim(),

      'batteryCapacity':
      batteryController
          .text
          .trim(),

      'vehicleType':
      vehicleType,

      'chargerType':
      chargerType,
    });

    Navigator.pushReplacement(

      context,

      MaterialPageRoute(
        builder:
            (_) =>
        const MapPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title:
        const Text(
          "Vehicle Profile",
        ),

        backgroundColor:
        Colors.green[800],

        foregroundColor:
        Colors.white,
      ),

      body: SingleChildScrollView(

        padding:
        const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            const Text(

              "Tell us about your EV",

              style: TextStyle(

                fontSize: 32,

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 5,
            ),

            const Text(

              "This helps us find compatible stations for you.",

              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            Text(

              "Owner Details",

              style: TextStyle(

                color:
                Colors.green[800],

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            TextField(

              controller:
              nameController,

              decoration:
              InputDecoration(

                prefixIcon:
                const Icon(
                  Icons.person,
                ),

                hintText:
                "Full Name",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(

              "Vehicle Details",

              style: TextStyle(

                color:
                Colors.green[800],

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Row(

              children: [

                Expanded(

                  child:
                  DropdownButtonFormField(

                    value:
                    vehicleType,

                    decoration:
                    InputDecoration(

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),

                    items:

                    [

                      "Car",
                      "Bike",
                      "Scooter"

                    ]

                        .map(

                          (e) => DropdownMenuItem(

                        value:e,

                        child:
                        Text(e),
                      ),
                    )

                        .toList(),

                    onChanged:(v){

                      setState(() {

                        vehicleType =
                        v!;
                      });
                    },
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(

                  child: TextField(

                    controller:
                    vehicleNumberController,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Vehicle No.",

                      border:
                      OutlineInputBorder(

                        borderRadius:
                        BorderRadius.circular(
                          15,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
              vehicleModelController,

              decoration:
              InputDecoration(

                hintText:
                "Vehicle Model (e.g Nexon EV)",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(

              controller:
              batteryController,

              decoration:
              InputDecoration(

                hintText:
                "Battery Capacity (kWh) - Optional",

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 25,
            ),

            Text(

              "Charging Preference",

              style: TextStyle(

                color:
                Colors.green[800],

                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            DropdownButtonFormField(

              value:
              chargerType,

              decoration:
              InputDecoration(

                border:
                OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(
                    15,
                  ),
                ),
              ),

              items:

              [

                "CCS2 (Fast Charger)",

                "Type 2",

                "CHAdeMO"
              ]

                  .map(

                    (e)=>

                    DropdownMenuItem(

                      value:e,

                      child:
                      Text(e),
                    ),
              )

                  .toList(),

              onChanged:(v){

                setState(() {

                  chargerType =
                  v!;
                });
              },
            ),

            const SizedBox(
              height: 40,
            ),

            SizedBox(

              width:
              double.infinity,

              height:55,

              child:
              ElevatedButton(

                onPressed:
                saveProfile,

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green[800],

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(
                      15,
                    ),
                  ),
                ),

                child:
                const Text(

                  "Save & Continue",

                  style:
                  TextStyle(

                    fontSize:18,

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
  }
}