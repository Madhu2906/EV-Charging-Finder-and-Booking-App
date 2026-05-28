import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

import 'login_page.dart';
import 'booking_screen.dart';
import 'profile_check_page.dart';
import 'profile_page.dart';
import 'add_vehicle_page.dart';
import 'booking_history_page.dart';
import 'review_page.dart';
import 'auth_gate.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(

    MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),

      home: const AuthGate(),

      routes: {

        '/map': (context) =>
        const MapPage(),

        '/profilePage': (context) =>
        const ProfilePage(),

        '/addVehicle': (context) =>
        const AddVehiclePage(),
      },
    ),
  );
}

class MapPage extends StatefulWidget {

  const MapPage({super.key});

  @override
  State<MapPage> createState() =>
      _MapPageState();
}

class _MapPageState extends State<MapPage> {

  final MapController _mapController =
  MapController();

  final TextEditingController
  _searchController =
  TextEditingController();

  final String myApiKey =
      'aa1f57f8-73e6-405e-affb-1d7f74e61600';

  final String myIdentity =
      'VoltSpot/contact@voltspot.in';

  LatLng? userLocation;

  List<Marker> stationMarkers = [];

  bool isLoading = false;

  @override
  void initState() {

    super.initState();

    _setupGPS();
  }

  double _calculateDistance(
      LatLng p1,
      LatLng p2,
      ) {

    const double earthRadius = 6371;

    double dLat =
        (p2.latitude - p1.latitude) *
            (math.pi / 180);

    double dLon =
        (p2.longitude - p1.longitude) *
            (math.pi / 180);

    double a =
        math.sin(dLat / 2) *
            math.sin(dLat / 2) +
            math.cos(
                p1.latitude *
                    (math.pi / 180)) *
                math.cos(
                    p2.latitude *
                        (math.pi / 180)) *
                math.sin(dLon / 2) *
                math.sin(dLon / 2);

    double c =
        2 * math.atan2(
          math.sqrt(a),
          math.sqrt(1 - a),
        );

    return earthRadius * c;
  }

  Future<void> _setupGPS() async {

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission ==
        LocationPermission.denied) {

      permission =
      await Geolocator.requestPermission();
    }

    try {

      Position pos =
      await Geolocator.getCurrentPosition(
        desiredAccuracy:
        LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {

        userLocation =
            LatLng(
              pos.latitude,
              pos.longitude,
            );
      });

      _mapController.move(
        userLocation!,
        13,
      );

      _fetchStations(userLocation!);

    } catch (e) {

      setState(() {

        userLocation =
        const LatLng(
          19.0873,
          72.8310,
        );
      });

      _fetchStations(userLocation!);
    }
  }

  Future<void> _searchPlace(
      String query,
      ) async {

    if (query.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1';

    try {

      final response =
      await http.get(

        Uri.parse(url),

        headers: {
          'User-Agent': myIdentity,
        },
      );

      if (response.statusCode == 200) {

        final data =
        json.decode(response.body);

        if (data.isNotEmpty) {

          LatLng searchPos =
          LatLng(
            double.parse(data[0]['lat']),
            double.parse(data[0]['lon']),
          );

          _mapController.move(
            searchPos,
            13,
          );

          _fetchStations(searchPos);
        }
      }

    } catch (e) {

      debugPrint("Search Error: $e");
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchStations(
      LatLng area,
      ) async {

    final url =
        'https://api.openchargemap.io/v3/poi/?output=json&latitude=${area.latitude}&longitude=${area.longitude}&distance=30&distanceunit=KM&maxresults=50&compact=true';

    try {

      final response =
      await http.get(

        Uri.parse(url),

        headers: {

          'X-API-Key': myApiKey,
          'User-Agent': myIdentity,
        },
      );

      if (response.statusCode == 200) {

        final List data =
        json.decode(response.body);

        setState(() {

          stationMarkers =
              data.map((item) {

                LatLng stationPos =
                LatLng(
                  item['AddressInfo']['Latitude'],
                  item['AddressInfo']['Longitude'],
                );

                double dist =
                userLocation != null
                    ? _calculateDistance(
                  userLocation!,
                  stationPos,
                )
                    : 0.0;

                return Marker(

                  point: stationPos,

                  width: 45,
                  height: 45,

                  child: GestureDetector(

                    onTap: () =>
                        _showEnhancedPopUp(
                          item,
                          dist,
                        ),

                    child: const Icon(
                      Icons.ev_station,
                      color: Colors.green,
                      size: 35,
                    ),
                  ),
                );
              }).toList();
        });
      }

    } catch (e) {

      debugPrint(
          "Station API Error: $e");
    }
  }

  void _showEnhancedPopUp(
      dynamic data,
      double distance,
      ) {

    final String stationName =
        data['AddressInfo']['Title']
            ??
            'EV Station';

    final List connections =
        data['Connections'] ?? [];

    final firstConn =
    connections.isNotEmpty
        ? connections[0]
        : {};

    final String plug =
        firstConn['ConnectionType']
        ?['Title'] ??
            'Universal';

    final String kw =
    (firstConn['PowerKW'] == null ||
        firstConn['PowerKW'] == 0)
        ? "25 kW"
        : "${firstConn['PowerKW']} kW";

    final String slots =
    (firstConn['Quantity'] == null ||
        firstConn['Quantity'] == 0)
        ? "10"
        : "${firstConn['Quantity']}";

    showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape:
      const RoundedRectangleBorder(

        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),

      builder: (_) => Padding(

        padding:
        const EdgeInsets.fromLTRB(
          20,
          20,
          20,
          30,
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            Center(

              child: Container(

                width: 40,
                height: 4,

                decoration: BoxDecoration(

                  color: Colors.grey[300],

                  borderRadius:
                  BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(

              stationName,

              style: const TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            Text(

              "${distance.toStringAsFixed(1)} km away",

              style: const TextStyle(
                color: Colors.blue,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const Divider(height: 20),

            Text(
              "Details:",
              style: TextStyle(
                fontWeight:
                FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),

            Text("• Plug Type: $plug"),
            Text("• Power: $kw"),
            Text("• Available Slots: $slots"),

            const SizedBox(height: 20),

            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          BookingPage(

                            stationName:
                            stationName,

                            address:
                            data['AddressInfo']
                            ['AddressLine1'] ??
                                "Unknown Address",

                            plugType: plug,

                            power: kw,

                            timing:
                            "24/7 Available",

                            price:
                            "₹18/unit",
                          ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                ),

                label: const Text(
                  "Book Charging Slot",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.green[800],

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () {

                  Navigator.push(

                    context,

                    MaterialPageRoute(

                      builder: (_) =>
                          ReviewPage(
                            stationName:
                            stationName,
                          ),
                    ),
                  );
                },

                icon: const Icon(
                  Icons.star,
                  color: Colors.white,
                ),

                label: const Text(
                  "Reviews",
                ),

                style:
                ElevatedButton.styleFrom(

                  backgroundColor:
                  Colors.orange,

                  foregroundColor:
                  Colors.white,

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),


            // NAVIGATION BUTTON
            SizedBox(

              width: double.infinity,
              height: 50,

              child: OutlinedButton.icon(

                onPressed: () async {

                  final lat =
                  data['AddressInfo']['Latitude'];

                  final lon =
                  data['AddressInfo']['Longitude'];

                  final googleUrl =
                      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lon";

                  final uri = Uri.parse(googleUrl);

                  if (await canLaunchUrl(uri)) {

                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },

                icon: const Icon(
                  Icons.directions,
                ),

                label: const Text(
                  "Navigate Now",
                ),

                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ),

            const SizedBox(height: 10),

// REPORT BUTTON
            SizedBox(

              width: double.infinity,
              height: 50,

              child: ElevatedButton.icon(

                onPressed: () async {

                  final lat =
                  data['AddressInfo']['Latitude'];

                  final lon =
                  data['AddressInfo']['Longitude'];

                  final reportUrl =
                      "https://map.openchargemap.io/?latitude=$lat&longitude=$lon&zoom=16";

                  final uri = Uri.parse(reportUrl);

                  if (await canLaunchUrl(uri)) {

                    await launchUrl(
                      uri,
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },

                icon: const Icon(
                  Icons.report,
                  color: Colors.white,
                ),

                label: const Text(
                  "Report Station",
                ),

                style: ElevatedButton.styleFrom(

                  backgroundColor: Colors.red,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      drawer: Drawer(

        child: Column(

          children: [

            UserAccountsDrawerHeader(

              decoration: BoxDecoration(
                color: Colors.green[800],
              ),

              currentAccountPicture:
              const CircleAvatar(

                backgroundColor:
                Colors.white,

                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.green,
                ),
              ),

              accountName:
              const Text("EV User"),

              accountEmail:
              Text(
                FirebaseAuth.instance
                    .currentUser
                    ?.email ??
                    "",
              ),
            ),

            ListTile(

              leading:
              const Icon(Icons.person),

              title:
              const Text("My Profile"),

              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/profilePage',
                );
              },
            ),

            ListTile(

              leading:
              const Icon(Icons.history),

              title: const Text(
                "Booking History",
              ),

              onTap: () {

                Navigator.push(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                    const BookingHistoryPage(),
                  ),
                );
              },
            ),

            ListTile(

              leading:
              const Icon(Icons.electric_car),

              title:
              const Text("Add Vehicle"),

              onTap: () {

                Navigator.pushNamed(
                  context,
                  '/addVehicle',
                );
              },
            ),


            const Spacer(),

            ListTile(

              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),

              title:
              const Text("Logout"),

              onTap: () async {

                await FirebaseAuth.instance
                    .signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(

                  context,

                  MaterialPageRoute(
                    builder: (_) =>
                    const LoginPage(),
                  ),

                      (route) => false,
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      body: userLocation == null

          ? const Center(
        child:
        CircularProgressIndicator(
          color: Colors.green,
        ),
      )

          : Stack(

        children: [

          Positioned.fill(

            child: FlutterMap(

              mapController:
              _mapController,

              options: MapOptions(

                initialCenter:
                userLocation!,

                initialZoom: 13,
              ),

              children: [

                TileLayer(

                  urlTemplate:
                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",

                  tileProvider:
                  CancellableNetworkTileProvider(),

                  userAgentPackageName:
                  myIdentity,
                ),

                MarkerLayer(

                  markers: [

                    Marker(

                      point:
                      userLocation!,

                      width: 35,
                      height: 35,

                      child: const Icon(
                        Icons.person_pin_circle,
                        color: Colors.blue,
                        size: 40,
                      ),
                    ),

                    ...stationMarkers,
                  ],
                ),
              ],
            ),
          ),

          Column(

            children: [

              Container(

                width: double.infinity,

                padding: EdgeInsets.only(

                  top:
                  MediaQuery.of(context)
                      .padding
                      .top +
                      10,

                  bottom: 15,
                  left: 15,
                  right: 15,
                ),

                decoration: BoxDecoration(

                  color: Colors.green[800],

                  boxShadow: const [

                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                    ),
                  ],
                ),

                child: Row(

                  children: [

                    Builder(

                      builder: (context) =>
                          IconButton(

                            onPressed: () {

                              Scaffold.of(context)
                                  .openDrawer();
                            },

                            icon: const Icon(
                              Icons.menu,
                              color: Colors.white,
                            ),
                          ),
                    ),

                    const SizedBox(width: 10),

                    Container(

                      width: 40,
                      height: 40,

                      decoration:
                      const BoxDecoration(

                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),

                      child: const Icon(
                        Icons.electric_car,
                        color: Colors.green,
                      ),
                    ),

                    const SizedBox(width: 15),

                    const Text(

                      "EVS Finder & Book",

                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(

                padding:
                const EdgeInsets.all(15),

                child: Container(

                  decoration: BoxDecoration(

                    color: Colors.white,

                    borderRadius:
                    BorderRadius.circular(30),

                    boxShadow: const [

                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                      ),
                    ],
                  ),

                  child: TextField(

                    controller:
                    _searchController,

                    decoration:
                    InputDecoration(

                      hintText:
                      "Search city...",

                      prefixIcon:
                      const Icon(
                        Icons.search,
                        color: Colors.green,
                      ),

                      border:
                      InputBorder.none,

                      contentPadding:
                      const EdgeInsets.symmetric(
                        vertical: 15,
                      ),

                      suffixIcon:
                      isLoading

                          ? const Padding(

                        padding:
                        EdgeInsets.all(12),

                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )

                          : null,
                    ),

                    onSubmitted:
                    _searchPlace,
                  ),
                ),
              ),
            ],
          ),
          // ================= BOTTOM BUTTONS =================
          Positioned(

            bottom: 20,
            right: 15,

            child: Column(

              children: [

                FloatingActionButton(

                  heroTag: "location",

                  backgroundColor: Colors.green,

                  onPressed: () async {

                    try {

                      Position pos =
                      await Geolocator.getCurrentPosition(
                        desiredAccuracy:
                        LocationAccuracy.high,
                      );

                      final currentLocation =
                      LatLng(
                        pos.latitude,
                        pos.longitude,
                      );

                      _mapController.move(
                        currentLocation,
                        15,
                      );

                      setState(() {

                        userLocation =
                            currentLocation;
                      });

                    } catch (e) {

                      debugPrint(
                        "Location Error: $e",
                      );
                    }
                  },

                  child: const Icon(
                    Icons.my_location,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 12),


              ],
            ),
          ),
        ],
      ),
    );
  }
}