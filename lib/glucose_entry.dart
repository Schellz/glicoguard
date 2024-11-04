class GlucoseEntry {
  final int? id;
  final DateTime date;
  final int glucose;
  final String mealType;
  final String mealTime;
  final String observations;

  GlucoseEntry({
    this.id,
    required this.date,
    required this.glucose,
    required this.mealType,
    required this.mealTime,
    required this.observations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'glucose': glucose,
      'mealType': mealType,
      'mealTime': mealTime,
      'observations': observations,
    };
  }

  static GlucoseEntry fromMap(Map<String, dynamic> map) {
    return GlucoseEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      glucose: map['glucose'],
      mealType: map['mealType'],
      mealTime: map['mealTime'],
      observations: map['observations'],
    );
  }
}
