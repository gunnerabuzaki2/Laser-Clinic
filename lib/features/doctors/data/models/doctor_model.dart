// =============================================================================
//  features/doctors/data/models/doctor_model.dart
//  Data model representing a row in the `doctors` Supabase table.
//  Doctors are managed exclusively through the Supabase dashboard.
// =============================================================================

class Doctor {
  final String id;
  final String name;
  final String education;
  final DateTime joinDate;
  final int age;

  const Doctor({
    required this.id,
    required this.name,
    required this.education,
    required this.joinDate,
    required this.age,
  });

  /// Deserialize from Supabase JSON response.
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'] as String,
      name: json['name'] as String,
      education: json['education'] as String? ?? '',
      joinDate: DateTime.parse(json['join_date'] as String),
      age: (json['age'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  String toString() => 'Doctor(id: $id, name: $name)';
}
