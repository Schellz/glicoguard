import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class AddGlucoseScreen extends StatefulWidget {
  const AddGlucoseScreen({super.key});

  @override
  _AddGlucoseScreenState createState() => _AddGlucoseScreenState();
}

class _AddGlucoseScreenState extends State<AddGlucoseScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController glucoseController = TextEditingController();
  final TextEditingController observationsController = TextEditingController();
  String? selectedMealType;
  String? selectedMealTime;

  List<String> mealTypes = ['Café da manhã', 'Almoço', 'Jantar'];
  List<String> mealTimes = ['Antes', 'Depois'];
  bool isGlucoseValid = false;
  bool isMealTypeValid = false;
  bool isMealTimeValid = false;
  final FocusNode glucoseFocusNode = FocusNode();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _clearForm() {
    glucoseController.clear();
    observationsController.clear();
    selectedMealType = null;
    selectedMealTime = null;
    selectedDate = DateTime.now();
    isGlucoseValid = false;
    isMealTypeValid = false;
    isMealTimeValid = false;
    setState(() {});
  }

  bool _isValidGlucose(String value) {
    if (value.isEmpty) return false;
    double? glucoseValue = double.tryParse(value);
    return glucoseValue != null &&
        glucoseValue >= 30 &&
        glucoseValue <= 700 &&
        value.length >= 2 &&
        value.length <= 3;
  }

  Future<void> _addGlucoseEntry() async {
    if (!isGlucoseValid || !isMealTypeValid || !isMealTimeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
      return;
    }

    Map<String, dynamic> data = {
      'date': DateFormat('dd/MM/yyyy').format(selectedDate),
      'value': int.parse(glucoseController.text),
      'meal_type': selectedMealType,
      'meal_time': selectedMealTime,
      'observations': observationsController.text,
    };

    final dbHelper = DatabaseHelper();
    await dbHelper.insertGlucose(data);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Entrada de glicose adicionada com sucesso!')),
    );

    _clearForm();
  }

  void _showGlucoseError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text(
              'Valor de glicemia incorreto. Deve ter 2 a 3 dígitos e estar entre 30 e 700 mg/dL.')),
    );
  }

  void _showMealError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Por favor, selecione um tipo de refeição.')),
    );
  }

  void _showMealTimeError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Por favor, selecione se foi antes ou depois da refeição.')),
    );
  }

  @override
  void initState() {
    super.initState();
    glucoseFocusNode.addListener(() {
      if (!glucoseFocusNode.hasFocus) {
        if (!isGlucoseValid) {
          FocusScope.of(context).requestFocus(glucoseFocusNode);
          _showGlucoseError();
        }
      }
    });
  }

  @override
  void dispose() {
    glucoseFocusNode.dispose();
    glucoseController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Voltar',
                      style: TextStyle(color: Colors.blue, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Data de hoje',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2196F3)),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Color(0xFF2196F3)),
                    const SizedBox(width: 10),
                    Text(
                      DateFormat('dd/MM/yyyy').format(selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Qual o valor da glicemia?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
            ),
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: glucoseController,
                focusNode: glucoseFocusNode,
                decoration: InputDecoration(
                  hintText: 'Informe o valor (mg/dL)',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    isGlucoseValid = _isValidGlucose(value);
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foi medido perto de qual refeição?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
            ),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                value: isMealTypeValid ? selectedMealType : null,
                items: mealTypes.map((String mealType) {
                  return DropdownMenuItem<String>(
                    value: mealType,
                    child: Text(mealType),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMealType = value;
                    isMealTypeValid = value != null;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Foi antes ou depois da refeição?',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
            ),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                value: isMealTimeValid ? selectedMealTime : null,
                items: mealTimes.map((String mealTime) {
                  return DropdownMenuItem<String>(
                    value: mealTime,
                    child: Text(mealTime),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMealTime = value;
                    isMealTimeValid = value != null;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Observações',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2196F3)),
            ),
            TextField(
              controller: observationsController,
              decoration: InputDecoration(
                hintText: 'Observações (opcional)',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Color(0xFF2196F3)),
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: Colors.blue[50],
              ),
              maxLines: 3,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (isGlucoseValid && isMealTypeValid && isMealTimeValid) {
                    _addGlucoseEntry();
                  } else {
                    if (!isGlucoseValid) _showGlucoseError();
                    if (!isMealTypeValid) _showMealError();
                    if (!isMealTimeValid) _showMealTimeError();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2196F3),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Salvar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
