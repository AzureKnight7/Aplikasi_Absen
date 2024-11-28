import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  String strLatLong = 'Belum Mendapatkan Lat dan Long, Silahkan tekan tombol';
  final TextEditingController noteController = TextEditingController();
  String strAlamat = 'Mencari lokasi....';
  bool loading = false;
  double latitude = 0.0;
  double longitude = 0.0;

  @override
  void initState() {
    super.initState();
    _getGeoLocationPosition();
  }

  Future<void> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location service Not Enabled');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permission denied');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    if (mounted) {
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
        strLatLong = 'Latitude: $latitude, Longitude: $longitude';
      });
      await getAddressFromLongLat(position);
    }
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    if (mounted) {
      setState(() {
        strAlamat = '${place.street}, ${place.subLocality}, ${place.locality}';
      });
    }
  }

  Future<void> _submitClockIn() async {
    setState(() {
      loading = true;
    });

    const String apiUrl = "https://hris-api.alfanium.id/v1/presence";
    const String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1Yzk3YWE2OC02YWE0LTRjNGEtOWExNi1kMTVhNjJiZmMyODMiLCJpYXQiOjE3MzE5OTAzNDN9.MsgFfWZKY7ZvVwHMzxwV4hLY0B7z-xTUl1sFd-aEryQ";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "location": {
            "x": latitude,
            "y": longitude,
          },
          "labelLocation": strAlamat,
          "note": noteController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          // _showDialog("Success", "Clock In berhasil!");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text("Clock In berhasil!"),
            ),
          );
        } else {
          // _showDialog("Error", "Clock In gagal: ${data['message']}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Gagal Clock In: ${data['message']}",
              ),
            ),
          );
        }
      } else {
        // _showDialog(
        // "Error", "Clock In gagal dengan status: ${response.statusCode}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.statusCode}"),
          ),
        );
      }
    } catch (error) {
      _showDialog("Error", "Terjadi kesalahan: $error");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _showDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String tdata = DateFormat("hh:mm a").format(DateTime.now());
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 200,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(
                  -6.2240383,
                  106.662275,
                ), // Center the map over London
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.mapbox.com/styles/v1/fajarantono01/cm3piu8ae000e01sd1zpc9a6l/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiZmFqYXJhbnRvbm8wMSIsImEiOiJjbTNwaTkwdTEwZWg5MmxwczV4bmVyenV0In0.fFaoyAdp2ZqO3s-lgzFaXw',
                  additionalOptions: {
                    'accessToken':
                        'pk.eyJ1IjoiZmFqYXJhbnRvbm8wMSIsImEiOiJjbTNwaTkwdTEwZWg5MmxwczV4bmVyenV0In0.fFaoyAdp2ZqO3s-lgzFaXw',
                    'id': 'mapbox.satellite',
                  },
                  // Plenty of other options available!
                ),
                // TileLayer( // Display map tiles from any source

                //   urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // OSMF's Tile Server
                //   userAgentPackageName: 'com.example.app',
                //   // And many more recommended properties!
                // ),
                // RichAttributionWidget( // Include a stylish prebuilt attribution widget that meets all requirments
                //   attributions: [
                //     TextSourceAttribution(
                //       'OpenStreetMap contributors',
                //       onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')), // (external)
                //     ),
                //     // Also add images...
                //   ],
                // ),

                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(-6.2240383, 106.662275),
                      width: 80,
                      height: 80,
                      child: Icon(
                        Icons.location_on_rounded,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Image.asset("assets/icon/shadow.png"),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Image.asset("assets/icon/ellipse_4.png"),
            ],
          ),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xff537FE7),
                        ),
                        child: SvgPicture.asset(
                          "assets/icon/circle_left.svg",
                        ),
                      ),
                    ),
                    Text(
                      tdata,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: const Color(0xff537FE7),
                      ),
                      child: SvgPicture.asset(
                        "assets/icon/circle_notch.svg",
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 2,
                margin: EdgeInsets.only(
                  left: 15,
                  right: 15,
                  top: MediaQuery.of(context).size.height / 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          const Divider(
                            indent: 130,
                            endIndent: 130,
                            thickness: 5,
                          ),
                          const SizedBox(height: 21),
                          const Text(
                            "Clock In",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff4266B9),
                            ),
                          ),
                          Row(
                            children: const [
                              Icon(
                                Icons.location_on,
                                color: Color(0xffD1D1D3),
                              ),
                              Text(
                                "Your Location",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            strAlamat,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextField(
                            controller: noteController,
                            decoration: const InputDecoration(
                              labelText: "Note (optional)",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: loading ? null : _submitClockIn,
                            child: Container(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: loading
                                    ? Colors.grey
                                    : const Color(0xff537FE7),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                "Clock In",
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
