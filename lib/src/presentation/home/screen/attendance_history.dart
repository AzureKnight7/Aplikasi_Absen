import 'dart:convert';

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
  DateTime? startDate;
  DateTime? endDate;

  Future<void> fetchAttendanceHistory({DateTime? start, DateTime? end}) async {
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
          var filteredResults = results.where((item) {
            final createdAt = DateTime.parse(item['createdAt']);
            if (start != null && end != null) {
              return createdAt
                      .isAfter(start.subtract(const Duration(days: 1))) &&
                  createdAt.isBefore(end.add(const Duration(days: 1)));
            }
            return true;
          });

          var present = filteredResults.map((item) {
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

          absenceData = present;
        } else {
          throw Exception("API response success is false");
        }
      } else {
        throw Exception(
            "Failed to fetch attendance history: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching attendance history: $error");
    } finally {
      isLoading = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    fetchAttendanceHistory();
    super.initState();
  }

  Future<void> pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
      });
      await fetchAttendanceHistory(start: startDate, end: endDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(width: 10),
            const Text(
              "Attendance History",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: GestureDetector(
                      onTap: pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              startDate != null
                                  ? DateFormat('yyyy/MM/dd').format(startDate!)
                                  : "Start Date",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: GestureDetector(
                      onTap: pickDateRange,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              endDate != null
                                  ? DateFormat('yyyy/MM/dd').format(endDate!)
                                  : "End Date",
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      fetchAttendanceHistory(start: startDate, end: endDate);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xff537FE7),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : absenceData.isEmpty
                      ? const Center(
                          child: Text(
                            "No data found for the selected date range.",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              vertical: 35, horizontal: 20),
                          itemCount: absenceData.length,
                          itemBuilder: (context, index) {
                            var item = absenceData[index];
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      item.abscenceDate,
                                      style: const TextStyle(
                                        color: Color(0xff5D5D65),
                                        fontSize: 12,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.schedule,
                                          color: item.isLate
                                              ? const Color(0xfff45050)
                                              : const Color(0xff5d5d65),
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          item.abscenceTime,
                                          style: TextStyle(
                                            color: item.isLate
                                                ? const Color(0xfff45050)
                                                : const Color(0xff5d5d65),
                                            fontSize: 12,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const Divider()
                              ],
                            );
                          },
                        ),
            ),
          ],
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
