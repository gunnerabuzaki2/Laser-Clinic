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
  final String? doctorId;
  final String? doctorName; // Populated from join query
  final int pulses;

  const LaserSession({
    required this.id,
    required this.patientId,
    required this.sessionDate,
    required this.laserArea,
    required this.price,
    required this.laserPower,
    required this.notes,
    this.doctorId,
    this.doctorName,
    this.pulses = 0,
  });

  factory LaserSession.fromJson(Map<String, dynamic> json) {
    // Handle joined doctor data — Supabase returns nested object for FK joins
    String? doctorName;
    if (json['doctors'] != null && json['doctors'] is Map) {
      doctorName = json['doctors']['name'] as String?;
    }

    return LaserSession(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      sessionDate: DateTime.parse(json['session_date'] as String),
      laserArea: json['laser_area'] as String,
      price: (json['price'] as num).toDouble(),
      laserPower: json['laser_power'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      doctorId: json['doctor_id'] as String?,
      doctorName: doctorName,
      pulses: (json['pulses'] as num?)?.toInt() ?? 0,
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
      'doctor_id': doctorId,
      'pulses': pulses,
    };
  }
}
