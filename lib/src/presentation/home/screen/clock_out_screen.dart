import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ClockOutScreen extends StatefulWidget {
  const ClockOutScreen({super.key});

  @override
  State<ClockOutScreen> createState() => _ClockOutScreenState();
}

class _ClockOutScreenState extends State<ClockOutScreen> {
  String strLatLong = 'Belum Mendapatkan Lat dan Long, Silahkan tekan tombol';
  final TextEditingController noteController = TextEditingController();
  String strAlamat = 'Mencari lokasi....';
  double latitude = 0;
  double longitude = 0;
  bool loading = false;

  @override
  void initState() {
    // map.MapboxOptions.setAccessToken(
    //   'pk.eyJ1IjoiZmFqYXJhbnRvbm8wMSIsImEiOiJjbTNwaWoydHUwZDh5MmtzOGNwN20zb2tiIn0.CcGM68jpRTuRoK9NhW83Qw',
    // );
    super.initState();
  }

  Future _getGeoLocationPosition() async {
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
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
      strLatLong =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });

    await getAddressFromLongLat(position);
    return position;
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks[0];
    setState(() {
      strAlamat = '${place.street}, ${place.subLocality}, ${place.locality}';
    });
  }

  Future<void> clockOut() async {
    setState(() {
      loading = true;
    });

    try {
      Position position = await _getGeoLocationPosition();

      final url = Uri.parse('https://hris-api.alfanium.id/v1/presence');
      const String token =
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1Yzk3YWE2OC02YWE0LTRjNGEtOWExNi1kMTVhNjJiZmMyODMiLCJpYXQiOjE3MzE5OTAzNDN9.MsgFfWZKY7ZvVwHMzxwV4hLY0B7z-xTUl1sFd-aEryQ";

      Map<String, dynamic> data = {
        "location": {"x": position.latitude, "y": position.longitude},
        "labelLocation": strAlamat
      };

      Map<String, String> headers = {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      };

      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (!mounted) return; // Periksa apakah widget masih aktif

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.green,
              content: Text("Clock Out berhasil!"),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                "Gagal Clock Out: ${responseData['message']}",
              ),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${response.statusCode}"),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Terjadi kesalahan: $e"),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String tdata = DateFormat("hh:mm: a").format(DateTime.now());
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
                      width: 180,
                      height: 180,
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
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: Color(0xff537FE7)),
                        child: SvgPicture.asset(
                          "assets/icon/circle_left.svg",
                        ),
                      ),
                    ),
                    Text(
                      tdata,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Color(0xff537FE7)),
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
                    top: MediaQuery.of(context).size.height / 3),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        children: [
                          SizedBox(height: 12),
                          Divider(
                            indent: 130,
                            endIndent: 130,
                            thickness: 5,
                          ),
                          SizedBox(height: 21),
                          Text(
                            "Clock Out",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff4266B9),
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Color(0xffD1D1D3),
                              ),
                              Expanded(
                                child: Text(
                                  "Your Location",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            strAlamat,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SvgPicture.asset("assets/icon/align_left.svg"),
                              Expanded(
                                child: TextField(
                                  controller: noteController,
                                  decoration: InputDecoration(
                                    hintText: "Note (optional)",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 100),
                          GestureDetector(
                            // onTap: () async {
                            // await clockOut();
                            // },
                            onTap: loading ? null : clockOut,
                            child: Container(
                              padding: EdgeInsets.only(top: 16, bottom: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: loading
                                    ? Colors.grey
                                    : const Color(0xff537FE7),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Clock Out",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                    fontSize: 16),
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
