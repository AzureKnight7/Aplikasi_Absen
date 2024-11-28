import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  bool isLoading = true;
  List<AbsenceData> absenceData = [];
  Future<void> fetchAttendanceHistory() async {
    isLoading = true;
    setState(() {});
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
          var present = results.map((item) {
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

          isLoading = false;
          setState(() {});
          absenceData = present;
        } else {
          isLoading = false;
          setState(() {});
          throw Exception("API response success is false");
        }
      } else {
        isLoading = false;
        setState(() {});
        throw Exception(
            "Failed to fetch attendance history: ${response.statusCode}");
      }
    } catch (error) {
      isLoading = false;
      setState(() {});
      print("Error fetching attendance history: $error");
    }
  }

  @override
  void initState() {
    fetchAttendanceHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: GestureDetector(
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
      ),
      body: Container(
        color: Colors.white,
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                padding:
                    const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                itemCount: absenceData.length,
                itemBuilder: (context, index) {
                  var item = absenceData[index];
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.abscenceDate,
                            style: TextStyle(
                              color: Color(0xff5D5D65),
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                color: item.isLate
                                    ? Color(0xfff45050)
                                    : Color(0xff5d5d65),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                item.abscenceTime,
                                style: TextStyle(
                                  color: item.isLate
                                      ? Color(0xfff45050)
                                      : Color(0xff5d5d65),
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
                },
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
