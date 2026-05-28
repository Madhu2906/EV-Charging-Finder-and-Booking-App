import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddVehiclePage extends StatefulWidget {

  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() =>
      _AddVehiclePageState();
}

class _AddVehiclePageState
    extends State<AddVehiclePage> {

  final _formKey = GlobalKey<FormState>();

  final vehicleNameController =
  TextEditingController();

  final vehicleNumberController =
  TextEditingController();

  final batteryController =
  TextEditingController();

  bool loading = false;

  Future<void> saveVehicle() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      loading = true;
    });

    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance

        .collection('users')

        .doc(uid)

        .collection('vehicles')

        .add({

      'vehicleName':
      vehicleNameController.text.trim(),

      'vehicleNumber':
      vehicleNumberController.text.trim(),

      'batteryCapacity':
      batteryController.text.trim(),

      'createdAt':
      Timestamp.now(),
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Vehicle Added Successfully"),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Add Vehicle"),

        backgroundColor: Colors.green[800],

        foregroundColor: Colors.white,
      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Form(

          key: _formKey,

          child: Column(

            children: [

              TextFormField(

                controller:
                vehicleNameController,

                decoration:
                const InputDecoration(
                  labelText: "Vehicle Name",
                ),

                validator: (v) =>
                v!.isEmpty
                    ? "Enter vehicle name"
                    : null,
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller:
                vehicleNumberController,

                decoration:
                const InputDecoration(
                  labelText: "Vehicle Number",
                ),

                validator: (v) =>
                v!.isEmpty
                    ? "Enter vehicle number"
                    : null,
              ),

              const SizedBox(height: 20),

              TextFormField(

                controller:
                batteryController,

                decoration:
                const InputDecoration(
                  labelText:
                  "Battery Capacity",
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(

                width: double.infinity,

                height: 55,

                child: ElevatedButton(

                  onPressed:
                  loading ? null : saveVehicle,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green[800],
                  ),

                  child: loading

                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )

                      : const Text(

                    "Save Vehicle",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}