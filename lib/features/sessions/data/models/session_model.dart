// =============================================================================
//  features/sessions/data/models/session_model.dart
// =============================================================================

class LaserSession {
  final String id;
  final String patientId;
  final DateTime sessionDate;
  final String laserArea;
  final double price;
  final String laserPower; // e.g. "18 J/cm²", "20W", etc.
  final String notes;

  const LaserSession({
    required this.id,
    required this.patientId,
    required this.sessionDate,
    required this.laserArea,
    required this.price,
    required this.laserPower,
    required this.notes,
  });

  factory LaserSession.fromJson(Map<String, dynamic> json) {
    return LaserSession(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      laserArea: json['laser_area'] as String,
      price: (json['price'] as num).toDouble(),
      laserPower: json['laser_power'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toInsertJson() {
    return {
      'patient_id': patientId,
      'session_date': sessionDate.toIso8601String(),
      'laser_area': laserArea,
      'price': price,
      'laser_power': laserPower,
      'notes': notes,
    };
  }
}
