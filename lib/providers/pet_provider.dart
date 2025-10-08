import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../services/firestore_service.dart';

class PetProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final Uuid _uuid = const Uuid();

  // Obtener mascotas de un usuario
  Stream<List<PetModel>> getPets(String ownerId) {
    return _firestore.getPetsByUser(ownerId);
  }

  // Agregar mascota con todos los campos necesarios
  Future<void> addPet({
    required String ownerId,
    required String name,
    required String species,
    String? birthDate,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? appointments,
  }) async {
    final newPet = PetModel(
      id: _uuid.v4(),
      ownerId: ownerId,
      name: name,
      species: species,
      birthDate: birthDate ?? '',
      vaccines: vaccines ?? [],
      appointments: appointments ?? [],
    );

    await _firestore.addPet(newPet);
  }

  // Eliminar mascota
  Future<void> deletePet(String id) async {
    await _firestore.deletePet(id);
  }
}
