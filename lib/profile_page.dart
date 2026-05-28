import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(

      backgroundColor: Colors.grey[100],

      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),

      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get(),

        builder: (context, userSnapshot) {

          if (!userSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          var userData =
              userSnapshot.data!.data()
              as Map<String, dynamic>? ?? {};

          return SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(

              children: [

                Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 10,
                        color: Colors.black12,
                      ),
                    ],
                  ),

                  child: Column(

                    children: [

                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.green[100],
                        child: Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.green[800],
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        userData['name'] ?? "User",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      _infoTile(
                        Icons.phone,
                        "Mobile",
                        userData['mobile'] ?? "Not added",
                      ),

                      const SizedBox(height: 12),

                      _infoTile(
                        Icons.email,
                        "Email",
                        user.email ?? "",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Registered Vehicle",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ✅ FIXED VEHICLE SECTION
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('vehicles')
                      .snapshots(),

                  builder: (context, snapshot) {

                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final vehicles = snapshot.data!.docs;

                    if (vehicles.isEmpty) {
                      return const Text("No Vehicle Registered");
                    }

                    return Column(
                      children: vehicles.map((doc) {

                        final data =
                        doc.data() as Map<String, dynamic>;

                        return Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: ListTile(

                            leading: CircleAvatar(
                              backgroundColor: Colors.green[100],
                              child: const Icon(
                                Icons.electric_car,
                                color: Colors.green,
                              ),
                            ),

                            title: Text(
                              data['vehicleName'] ?? "No Vehicle",
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "Number: ${data['vehicleNumber'] ?? '-'}",
                                ),

                                Text(
                                  "Battery: ${data['batteryCapacity'] ?? '-'} kWh",
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(
      IconData icon,
      String title,
      String value,
      ) {

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),

      child: Row(
        children: [

          Icon(icon, color: Colors.green),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}