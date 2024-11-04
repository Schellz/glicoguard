import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const AddNotificationScreen(),
              ),
            );
          },
          child: const Text('Adicionar Notificação'),
        ),
      ),
    );
  }
}

class AddNotificationScreen extends StatefulWidget {
  const AddNotificationScreen({super.key});

  @override
  _AddNotificationScreenState createState() => _AddNotificationScreenState();
}

class _AddNotificationScreenState extends State<AddNotificationScreen> {
  final TextEditingController medicationController = TextEditingController();
  final TextEditingController dosageController = TextEditingController();
  final TextEditingController observationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  String? selectedUnit;
  final _formKey = GlobalKey<FormState>();

  final List<String> units = ['mg', 'g', 'mL', 'gotas', 'comprimido'];

  Future<void> _addMedicationEntry(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      String medication = medicationController.text;
      String dosage = dosageController.text;
      String unit = selectedUnit ?? '';
      String observation = observationController.text;
      String time = timeController.text;

      Map<String, dynamic> data = {
        'medication_name': medication,
        'dose': dosage,
        'unit': unit,
        'observation': observation,
        'time': time,
      };

      final dbHelper = DatabaseHelper();
      await dbHelper.insertNotification(data);

      _clearFields();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notificação cadastrada com sucesso!'),
        ),
      );

      Navigator.pop(context);
    }
  }

  void _clearFields() {
    medicationController.clear();
    dosageController.clear();
    observationController.clear();
    timeController.clear();
    selectedUnit = null;
  }

  String? _validateNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        timeController.text = selectedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Text('Voltar', style: TextStyle(color: Colors.blue, fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Medicamento',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              TextFormField(
                controller: medicationController,
                decoration: InputDecoration(
                  hintText: 'Insira o nome do medicamento',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 16),
              const Text(
                'Dose',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              TextFormField(
                controller: dosageController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d+)?')),
                ],
                decoration: InputDecoration(
                  hintText: 'Insira a quantidade',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                validator: _validateNotEmpty,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unidade de Medida',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              DropdownButtonFormField<String>(
                value: selectedUnit,
                items: units.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                decoration: InputDecoration(
                  hintText: 'Exemplo: mg',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
                onChanged: (value) {
                  setState(() {
                    selectedUnit = value;
                  });
                },
                validator: (value) => value == null ? 'Selecione uma unidade' : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Hora',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: timeController,
                    decoration: InputDecoration(
                      hintText: 'Insira a hora (HH:mm)',
                      border: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Colors.blue[50],
                    ),
                    validator: _validateNotEmpty,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Observação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
              ),
              TextFormField(
                controller: observationController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Observações (opcional)',
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF2196F3)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () => _addMedicationEntry(context),
                  child: const Text(
                    'Salvar',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
