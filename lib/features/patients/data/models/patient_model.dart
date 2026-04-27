// =============================================================================
//  features/patients/data/models/patient_model.dart
//  Data model representing a row in the `patients` Supabase table.
// =============================================================================

class Patient {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.createdAt,
  });

  /// Deserialize from Supabase JSON response.
  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Serialize to JSON for inserting into Supabase (id & created_at are auto-generated).
  Map<String, dynamic> toInsertJson() {
    return {
      'name': name,
      'phone_number': phoneNumber,
    };
  }

  @override
  String toString() => 'Patient(id: $id, name: $name, phone: $phoneNumber)';
}
