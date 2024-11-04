import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:glicoguard/screens/database_helper.dart';
import 'package:glicoguard/screens/add_notification_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    notifications = await DatabaseHelper().getAllNotifications();
    setState(() {});
  }

  String formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy HH:mm').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Detalhes',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text('Medicamento: ${notification['medication_name'] ?? 'N/A'}'),
                Text('Dose: ${notification['dose'] ?? 'N/A'}'),
                Text('Unidade de medida: ${notification['unit'] ?? 'N/A'}'),
                Text('Hora: ${notification['time'] ?? 'N/A'}'),
                Text('Observação: ${notification['observation'] ?? 'Nenhuma observação'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Fechar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteNotification(int id) async {
    await DatabaseHelper().deleteNotification(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Notificações'),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text('Nenhuma notificação salva.'),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: const Color(0xFFE9F4FE),
                  child: ListTile(
                    title: Text(
                      notification['medication_name'] ?? 'Nome do medicamento',
                      style: const TextStyle(
                        color: Color(0xFFFF5722),
                      ),
                    ),
                    subtitle: Text(
                      'Dose: ${notification['dose'] ?? 'N/A'} - Unidade: ${notification['unit'] ?? 'N/A'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteNotification(notification['id']),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showNotificationDetails(notification),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddNotificationScreen(),
            ),
          ).then((_) {
            _loadNotifications();
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
