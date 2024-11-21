import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:new_attandance/src/presentation/izin/Tambah_izin_screen.dart';

class IzinScreen extends StatefulWidget {
  const IzinScreen({super.key});

  @override
  State<IzinScreen> createState() => _IzinScreenState();
}

class _IzinScreenState extends State<IzinScreen> {
  List<DataIzin> listIzin = [
    DataIzin(
        nama: "Adella Fajriliya Berliana",
        periodAwal: "2024-10-15",
        periodAkhir: "2024-10-15",
        keterangan: "Izin Sakit"),
    DataIzin(
        nama: "Adella Fajriliya Berliana",
        periodAwal: "2024-10-15",
        periodAkhir: "2024-10-15",
        keterangan: "Izin Sakit"),
    DataIzin(
        nama: "Adella Fajriliya Berliana",
        periodAwal: "2024-10-15",
        periodAkhir: "2024-10-15",
        keterangan: "Izin Sakit"),
  ];

  @override
  void initState() {
    super.initState();

    initializeDateFormatting("id_ID", null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Halaman Izin"),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        child: ListView.builder(
            itemCount: listIzin.length,
            itemBuilder: (context, index) {
              var item = listIzin[index];
              var formattedTime = DateFormat("EEEE, d MMMM yyyy", "id_ID");
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                margin: const EdgeInsets.only(bottom: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.green.withOpacity(0.3),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.keterangan,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Dari",
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      formattedTime.format(DateTime.parse(item.periodAwal)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Sampai",
                      style: TextStyle(fontSize: 11),
                    ),
                    Text(
                      formattedTime.format(DateTime.parse(item.periodAwal)),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TambahIzinScreen()),
          );
        },
        backgroundColor: const Color(0xffb0f5be),
        child: Icon(Icons.add),
      ),
    );
  }
}

class DataIzin {
  String nama;
  String periodAwal;
  String periodAkhir;
  String keterangan;

  DataIzin({
    required this.nama,
    required this.periodAwal,
    required this.periodAkhir,
    required this.keterangan,
  });
}
