class PetModel {
  String id;
  String ownerId;
  String name;
  String species;
  String birthDate;
  List<Map<String, dynamic>> vaccines;
  List<Map<String, dynamic>> appointments;
  bool isAdoptable;
  String? imageUrl; // ✅ NUEVO CAMPO

  PetModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.species,
    required this.birthDate,
    required this.vaccines,
    required this.appointments,
    required this.isAdoptable,
    this.imageUrl, // ✅ NUEVO CAMPO
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
      'isAdoptable': isAdoptable,
      'imageUrl': imageUrl, // ✅ NUEVO CAMPO
    };
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      birthDate: map['birthDate'] ?? '',
      vaccines: List<Map<String, dynamic>>.from(map['vaccines'] ?? []),
      appointments: List<Map<String, dynamic>>.from(map['appointments'] ?? []),
      isAdoptable: map['isAdoptable'] ?? false,
      imageUrl: map['imageUrl'], // ✅ NUEVO CAMPO
    );
  }
}