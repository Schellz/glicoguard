import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';

class GlucoseEntry {
  final DateTime date;
  final int value;
  final String mealType;
  final String mealTime;
  final String observations;

  GlucoseEntry(this.date, this.value, this.mealType, this.mealTime, this.observations);
}

class ShareScreen extends StatefulWidget {
  const ShareScreen({super.key});

  @override
  _ShareScreenState createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  List<GlucoseEntry> entries = [];
  Map<String, List<GlucoseEntry>> groupedEntries = {};

  @override
  void initState() {
    super.initState();
    _fetchGlucoseEntries();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    var notificationStatus = await Permission.notification.status;
    if (!notificationStatus.isGranted) {
      await Permission.notification.request();
    }

    var locationStatus = await Permission.locationWhenInUse.status;
    if (!locationStatus.isGranted) {
      await Permission.locationWhenInUse.request();
    }
  }

  Future<void> _fetchGlucoseEntries() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> data = await dbHelper.getAllGlucose();
    List<GlucoseEntry> fetchedEntries = data.map((entry) {
      return GlucoseEntry(
        DateFormat('dd/MM/yyyy').parse(entry['date']),
        (entry['value'] as num).toInt(),
        entry['meal_type'],
        entry['meal_time'],
        entry['observations'],
      );
    }).toList();

    fetchedEntries.sort((a, b) => b.date.compareTo(a.date));

    Map<String, List<GlucoseEntry>> tempGroupedEntries = {};
    for (var entry in fetchedEntries) {
      String monthYear = DateFormat('MMMM yyyy', 'pt_BR').format(entry.date);
      if (tempGroupedEntries.containsKey(monthYear)) {
        tempGroupedEntries[monthYear]!.add(entry);
      } else {
        tempGroupedEntries[monthYear] = [entry];
      }
    }

    setState(() {
      entries = fetchedEntries;
      groupedEntries = tempGroupedEntries;
    });
  }

  Future<void> _refreshEntries() async {
    await _fetchGlucoseEntries();
  }

  Future<void> _generateExcel(String monthYear, List<GlucoseEntry> monthEntries) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel[monthYear];

    sheetObject.appendRow([
      "Data",
      "Glicemia (mg/dL)",
      "Refeição",
      "Hora da Refeição",
      "Observações"
    ]);

    for (var entry in monthEntries) {
      sheetObject.appendRow([
        DateFormat('dd/MM/yyyy').format(entry.date),
        entry.value,
        entry.mealType,
        entry.mealTime,
        entry.observations
      ]);
    }

    String downloadsPath = "/storage/emulated/0/Download";
    Directory downloadsDirectory = Directory(downloadsPath);
    if (!await downloadsDirectory.exists()) {
      await downloadsDirectory.create(recursive: true);
    }

    String filePath = "$downloadsPath/$monthYear.xlsx";

    File file = File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(excel.save()!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Arquivo $monthYear.xlsx salvo em $filePath')),
    );

    OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compartilhar Histórico'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEntries,
        child: groupedEntries.isEmpty
            ? Center(
                child: Text(
                  'Nenhuma entrada de glicemia encontrada.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              )
            : ListView(
                children: groupedEntries.entries.map((entry) {
                  String monthYear = entry.key;
                  List<GlucoseEntry> monthEntries = entry.value;

                  return ListTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthYear,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(33, 150, 243, 1),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download, color: Color.fromRGBO(33, 150, 243, 1)),
                          onPressed: () {
                            _generateExcel(monthYear, monthEntries);
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }
}
