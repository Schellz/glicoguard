import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'add_glucose_screen.dart';
import 'database_helper.dart';

class GlucoseEntry {
  final DateTime date;
  final int value;
  final String mealType;
  final String mealTime;
  final String observations;

  GlucoseEntry(this.date, this.value, this.mealType, this.mealTime, this.observations);
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<GlucoseEntry> entries = [];
  List<GlucoseEntry> filteredEntries = [];
  int? selectedMonth;

  @override
  void initState() {
    super.initState();
    _fetchGlucoseEntries();
  }

  Future<void> _fetchGlucoseEntries() async {
    final dbHelper = DatabaseHelper();
    final List<Map<String, dynamic>> data = await dbHelper.getAllGlucose();
    setState(() {
      entries = data.map((entry) {
        return GlucoseEntry(
          DateFormat('dd/MM/yyyy').parse(entry['date']),
          (entry['value'] as num).toInt(),
          entry['meal_type'],
          entry['meal_time'],
          entry['observations'],
        );
      }).toList();
      entries.sort((a, b) => b.date.compareTo(a.date));
      _filterEntries();
    });
  }

  void _filterEntries() {
    if (selectedMonth == null) {
      filteredEntries = List.from(entries);
    } else {
      filteredEntries = entries.where((entry) => entry.date.month == selectedMonth).toList();
    }
  }

  Future<void> _refreshEntries() async {
    await _fetchGlucoseEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Glicemia'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<int>(
              hint: const Text('Filtro'),
              value: selectedMonth,
              icon: const Icon(Icons.filter_alt),
              dropdownColor: Colors.white,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMonth = newValue;
                  _filterEntries();
                });
              },
              items: [
                const DropdownMenuItem<int>(
                  value: null,
                  child: Text(
                    'Todos',
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
                ...List.generate(12, (index) {
                  int month = index + 1;
                  return DropdownMenuItem<int>(
                    value: month,
                    child: Text(
                      _getMonthName(month),
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshEntries,
        child: ListView.builder(
          itemCount: filteredEntries.length,
          itemBuilder: (context, index) {
            final entry = filteredEntries[index];
            return Card(
              color: const Color(0xFFE9F4FE),
              child: ListTile(
                title: Text(DateFormat('dd/MM/yyyy').format(entry.date)),
                subtitle: RichText(
                  text: TextSpan(
                    text: 'Glicemia: ',
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${entry.value} mg/dL',
                        style: const TextStyle(
                          color: Color(0xFFFF5722),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Detalhes'),
                      content: Text(
                        'Data: ${DateFormat('dd/MM/yyyy').format(entry.date)}\n'
                        'Glicemia: ${entry.value} mg/dL\n'
                        'Refeição: ${entry.mealType}\n'
                        'Tempo da Refeição: ${entry.mealTime}\n'
                        'Observações: ${entry.observations}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Fechar'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddGlucoseScreen()),
          ).then((_) {
            _fetchGlucoseEntries();
          });
        },
      ),
    );
  }

  String _getMonthName(int month) {
    const List<String> months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }
}
