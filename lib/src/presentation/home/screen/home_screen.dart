import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:new_attandance/src/presentation/auth/widget/q_dialog_error.dart';
import 'package:new_attandance/src/presentation/home/bloc/location/location_cubit.dart';
import 'package:new_attandance/src/presentation/home/bloc/user_status/user_status_cubit.dart';
import 'package:new_attandance/src/presentation/home/screen/attendance_history.dart';
import 'package:new_attandance/src/presentation/home/screen/clock_in_screen.dart';
import 'package:new_attandance/src/presentation/home/screen/clock_out_screen.dart';
import 'package:new_attandance/src/presentation/home/screen/q_absen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:new_attandance/src/presentation/izin/izin_screen.dart';
import 'package:new_attandance/src/shared/util/q_export.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  final String email;
  final String profile;
  const HomeScreen({
    super.key,
    required this.username,
    required this.email,
    required this.profile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double latitude = 0;
  double longitude = 0;

  bool locationLoaded = false;
  bool inArea = false;
  String deviceName = "";
  String username = "";
  String email = "";
  String profile = "";
  double? _latitude;
  double? _longitude;
  bool isLoading = true;
  List<AbsenceData> absenceData = [];
  // List<AbsenceData> absenceData = [
  //   AbsenceData(
  //       abscenceDate: "Fri, 04 Oct 2024",
  //       abscenceTime: "08:00 AM - 05:00 PM",
  //       isLate: false),
  //   AbsenceData(
  //       abscenceDate: "Thu, 03 Oct 2024",
  //       abscenceTime: "08:45 AM - 05:00 PM",
  //       isLate: true),
  //   AbsenceData(
  //       abscenceDate: "Wed, 02 Oct 2024",
  //       abscenceTime: "07:55 AM - 05:00 PM",
  //       isLate: false),
  //   AbsenceData(
  //       abscenceDate: "Tue, 01 Oct 2024",
  //       abscenceTime: "07:58 AM - 05:00 PM",
  //       isLate: false),
  //   AbsenceData(
  //       abscenceDate: "Mon, 30 Sep 2024",
  //       abscenceTime: "08:15 AM - 05:00 PM",
  //       isLate: true),
  //   AbsenceData(
  //       abscenceDate: "Sun, 29 Sep 2024",
  //       abscenceTime: "08:00 AM - 05:00 PM",
  //       isLate: false)
  // ];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    fetchAttendanceHistory().then((data) {
      setState(() {
        absenceData = data;
        isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching attendance history: $error");
    });
  }

  @override
  void initState() {
    super.initState();
    username = widget.username;
    email = widget.email;
    profile = widget.profile;
    getPermission();
    setState(() {});
    getLocation().then((_) {});
    context.read<UserStatusCubit>().cekData();
    deviceInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAttendanceHistory().then((data) {
        setState(() {
          absenceData = data;
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
        print("Error fetching attendance history: $error");
      });
    });
  }

   Future<List<AbsenceData>> fetchAttendanceHistory() async {
    const String apiUrl = "https://hris-api.alfanium.id/v1/presence";
    const String token =
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOiI1Yzk3YWE2OC02YWE0LTRjNGEtOWExNi1kMTVhNjJiZmMyODMiLCJpYXQiOjE3MzE5MDA1ODR9.qAgb_VpIvd-iwHnZW_o3ZoF6O2XD1jCe6Wh-wIZdFoE";

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          final results = data['results'] as List;

          return results.map((item) {
            final clockIn = item['clockIn'];
            final clockOut = item['clockOut'];
            final clockInStatus = item['clockInStatus'] ?? "Unknown";

            return AbsenceData(
              abscenceDate: DateFormat('EEE, dd MMM yyyy').format(
                DateTime.parse(item['createdAt']),
              ),
              abscenceTime: clockOut != null && clockOut.isNotEmpty
                  ? "${DateFormat('hh:mm a').format(DateTime.parse(clockIn))} - ${DateFormat('hh:mm a').format(DateTime.parse(clockOut))}"
                  : "${DateFormat('hh:mm a').format(DateTime.parse(clockIn))} - Not Checked Out",
              isLate: clockInStatus.toLowerCase() == "telat",
            );
          }).toList();
        } else {
          throw Exception("API response success is false");
        }
      } else {
        throw Exception(
            "Failed to fetch attendance history: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching attendance history: $error");
      return [];
    }
  }

  Future<void> getLocation() async {
    Position position = await Geolocator.getCurrentPosition();
    latitude = position.latitude;
    longitude = position.longitude;
    locationLoaded = true;
    setState(() {});
    debugPrint("out latitude = $latitude longitude = $longitude");
  }

  Future<void> getPermission() async {
    await [Permission.notification, Permission.location, Permission.camera]
        .request();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      return;
    }

    // ignore: deprecated_member_use
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    if (mounted) {
      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
    }

    print("Lokasi saat ini: Lat: $_latitude, Long: $_longitude");
    // _saveLocationToFirestore();
  }

  deviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final anroidInfo = "${deviceInfo.brand} ${deviceInfo.model}";
    setState(() {
      deviceName = anroidInfo;
    });
  }

  onRefrest() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var auth = context.read<AuthBloc>();
    var theme = context.read<ThemeCubit>();
    var location = context.read<LocationCubit>();
    var userStatus = context.read<UserStatusCubit>();
    String tdata = DateFormat("HH:mm").format(DateTime.now());
    String currentTime = DateFormat('EEEE, d MMMM y').format(DateTime.now());
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          bloc: auth,
          listener: (context, state) {
            state.maybeMap(
              orElse: () {},
              authenticate: (value) {
                setState(() {
                  username = value.name;
                  email = value.email;
                  profile = value.profile;
                  print(username);
                  print(email);
                  print(profile);
                });
              },
              unauthenticate: (value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            );
          },
        ),
        BlocListener<LocationCubit, LocationState>(
          bloc: location,
          listener: (context, state) {
            state.maybeMap(
              orElse: () {},
              inLocation: (value) {
                setState(() {
                  inArea = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => QAbsen(
                          latitude: latitude,
                          longitude: longitude,
                          deviceName: deviceName)),
                );
              },
              outLocation: (value) {
                dialogError(context, "Di luar kawansan kantor");
                setState(() {
                  inArea = false;
                });
              },
              failed: (value) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              },
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            try {
              final data = await fetchAttendanceHistory();
              setState(() {
                absenceData = data;
              });
            } catch (error) {
              print("Error refreshing data: $error");
            }
          },
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "assets/icon/Ellipse_2.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width,
                    child: Image.asset(
                      "assets/icon/Ellipse_3.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.sizeOf(context).width,
                        padding: EdgeInsets.only(
                            top: 50, bottom: 20, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage:
                                      AssetImage("assets/icon/profile.jpg"),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.80 -
                                          70,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        username,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 18),
                                      ),
                                      Text(
                                        "00000050961 - Junior Frontend Developer",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                            fontSize: 18),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            InkWell(
                              onTap: () async {
                                bool confirm = false;
                                await showDialog<void>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Center(
                                        child: Text('Logout'),
                                      ),
                                      content: const SingleChildScrollView(
                                        child: ListBody(
                                          children: <Widget>[
                                            Text('Do you wish to logout?'),
                                          ],
                                        ),
                                      ),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[600],
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "No",
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blueGrey,
                                            ),
                                            onPressed: () {
                                              confirm = true;
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              "Yes",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            )),
                                      ],
                                    ).animate().shake().fadeIn();
                                  },
                                );

                                if (confirm) {
                                  auth.add(const AuthEvent.logout());
                                }
                              },
                              child: const Icon(
                                Icons.logout,
                                size: 24.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 15.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            const Text(
                              "Live Attendance",
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              tdata,
                              style: TextStyle(
                                  fontSize: 50.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff4266B9)),
                            ),
                            Text(
                              currentTime,
                              style: TextStyle(
                                  fontSize: 18.0, color: Color(0xff5D5D65)),
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 35),
                              child: Divider(),
                            ),
                            SizedBox(
                              height: 40,
                            ),
                            Text(
                              "Office Hours",
                              style: TextStyle(
                                  fontSize: 18.0, color: Color(0xff5D5D65)),
                            ),
                            const Text(
                              "08:00 AM - 05:00 PM",
                              style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClockInScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width / 2 -
                                            50,
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color(0xff537FE7)),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "Clock In",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ClockOutScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.sizeOf(context).width / 2 -
                                            50,
                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Color(0xff537FE7)),
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
                                Divider(
                                  color: Colors.black,
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 35, right: 35, top: 30, bottom: 20),
                              child: Divider(),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                          "assets/icon/Vector.svg"),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        "Attendance History",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    ],
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            AttendanceHistory(),
                                      ));
                                    },
                                    child: Text(
                                      "See All",
                                      style: TextStyle(
                                          color: Color(0xff4266B9),
                                          fontWeight: FontWeight.w500),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                              ),
                              height: 300,
                              child: isLoading
                                  ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : absenceData.isEmpty
                                      ? const Center(
                                          child: Text(
                                              "No attendance history available."),
                                        )
                                      : ListView.builder(
                                          itemCount: absenceData.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            var item = absenceData[index];
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      item.abscenceDate,
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff5D5D65),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.schedule,
                                                          color: item.isLate
                                                              ? Color(
                                                                  0xfff45050)
                                                              : Color(
                                                                  0xff5d5d65),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          item.abscenceTime,
                                                          style: TextStyle(
                                                            color: item.isLate
                                                                ? Color(
                                                                    0xfff45050)
                                                                : Color(
                                                                    0xff5d5d65),
                                                            fontSize: 12,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Divider()
                                              ],
                                            );
                                          }),
                            )
                            // BlocBuilder<UserStatusCubit, UserStatusState>(
                            //   bloc: userStatus,
                            //   builder: (context, state) {
                            //     return state.maybeWhen(
                            //       orElse: () {
                            //         return Container();
                            //       },
                            //       signIn: () {
                            //         return SizedBox(
                            //           height: 50,
                            //           child: ElevatedButton(
                            //             style: ElevatedButton.styleFrom(
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.circular(12),
                            //               ),
                            //             ),
                            //             onPressed: () {
                            //               debugPrint("Nama Device =$deviceName");
                            //               location.checkLocation(
                            //                   latitude: latitude,
                            //                   longitude: longitude);
                            //               setState(() {});
                            //               if (inArea = true) {
                            //                 debugPrint("aman");
                            //               } else {
                            //                 debugPrint("tidak aman");
                            //               }
                            //             },
                            //             child: const Text(
                            //               "CHECK IN",
                            //               style: TextStyle(
                            //                 fontSize: 20.0,
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //       signOut: (data) {
                            //         return SizedBox(
                            //           height: 50,
                            //           child: ElevatedButton(
                            //             style: ElevatedButton.styleFrom(
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.circular(12),
                            //               ),
                            //             ),
                            //             onPressed: () {
                            //               location.checkLocation(
                            //                   latitude: latitude,
                            //                   longitude: longitude);
                            //               setState(() {});
                            //               if (inArea = true) {
                            //                 debugPrint("aman");
                            //               } else {
                            //                 debugPrint("tidak aman");
                            //               }
                            //             },
                            //             child: const Text(
                            //               "CHECK OUT",
                            //               style: TextStyle(
                            //                 fontSize: 20.0,
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //       complate: (data) {
                            //         return SizedBox(
                            //           height: 50,
                            //           child: ElevatedButton(
                            //             style: ElevatedButton.styleFrom(
                            //               shape: RoundedRectangleBorder(
                            //                 borderRadius: BorderRadius.circular(12),
                            //               ),
                            //             ),
                            //             onPressed: null,
                            //             child: const Text(
                            //               "PEKERJAAN TELAH SELESAI",
                            //               style: TextStyle(
                            //                 fontSize: 20.0,
                            //               ),
                            //             ),
                            //           ),
                            //         );
                            //       },
                            //     );
                            //   },
                            // ),
                          ],
                        ),
                      ),
                    ],
                  )
                      .animate()
                      .slideX(delay: const Duration(milliseconds: 2))
                      .fadeIn(),
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     CardHomePage(
                  //         title: "Check In",
                  //         icon: Icons.login,
                  //         time: "10:20 am",
                  //         subtitle: "On Time"),
                  //     CardHomePage(
                  //         title: "Check Out",
                  //         icon: Icons.logout,
                  //         time: "18:20 am",
                  //         subtitle: "Go Home")
                  //   ],
                  // ).animate().slideX(delay: 150.ms, begin: 0.5).fadeIn(),
                  // const SizedBox(
                  //   height: 20.0,
                  // ),
                  // const CardHomePage(
                  //         title: "Working Time",
                  //         icon: Icons.lock_clock,
                  //         time: "08:00 am",
                  //         subtitle: "Your Late to home")
                  //     .animate()
                  //     .slideX(delay: 200.ms, begin: -0.5)
                  //     .fadeIn()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AbsenceData {
  String abscenceDate;
  String abscenceTime;
  bool isLate;

  AbsenceData({
    required this.abscenceDate,
    required this.abscenceTime,
    required this.isLate,
  });
}