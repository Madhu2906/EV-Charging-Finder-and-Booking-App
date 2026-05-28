import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_setup.dart';
import 'main.dart';

class ProfileCheckPage extends StatelessWidget {

  const ProfileCheckPage({super.key});

  @override
  Widget build(BuildContext context) {

    final uid =
        FirebaseAuth.instance
            .currentUser!
            .uid;

    return FutureBuilder<DocumentSnapshot>(

      future:
      FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get(),

      builder:(context,snapshot){

        if(!snapshot.hasData){

          return const Scaffold(

            body: Center(
              child:
              CircularProgressIndicator(),
            ),
          );
        }

        final data =
        snapshot.data!.data()
        as Map<String,dynamic>?;

        final vehicleName =
        data?['vehicleName'];

        if(vehicleName == null ||
            vehicleName
                .toString()
                .trim()
                .isEmpty){

          return const ProfileSetupPage();
        }

        return const MapPage();
      },
    );
  }
}