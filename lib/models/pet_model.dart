class PetModel {
  String id;
  String ownerId;
  String name;
  String species;
  String? birthDate;
  List<Map<String, dynamic>> vaccines;
  List<Map<String, dynamic>> appointments;

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    this.birthDate,
    this.vaccines = const [],
    this.appointments = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'species': species,
      'birthDate': birthDate,
      'vaccines': vaccines,
      'appointments': appointments,
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      birthDate: map['birthDate'],
      vaccines: List<Map<String, dynamic>>.from(map['vaccines'] ?? []),
      appointments: List<Map<String, dynamic>>.from(map['appointments'] ?? []),
    );
  }
}
