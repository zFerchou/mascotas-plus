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

  // Obtener mascotas disponibles para adopción (excluyendo las propias)
  Stream<List<PetModel>> getAdoptablePets(String currentUserId) {
    return _firestore.getPetsForAdoption(currentUserId);
  }

  // Agregar mascota con todos los campos necesarios
  Future<void> addPet({
    required String ownerId,
    required String name,
    required String species,
    String? birthDate,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? appointments,
    bool isAdoptable = false, // Nueva propiedad para adopción
  }) async {
    final newPet = PetModel(
      id: _uuid.v4(),
      ownerId: ownerId,
      name: name,
      species: species,
      birthDate: birthDate ?? '',
      vaccines: vaccines ?? [],
      appointments: appointments ?? [],
      isAdoptable: isAdoptable,
    );

    await _firestore.addPet(newPet);
    notifyListeners();
  }

  // Actualizar mascota (para adopción u otros cambios)
  Future<void> updatePet(PetModel pet) async {
    await _firestore.updatePet(pet);
    notifyListeners();
  }

  // Adoptar mascota: cambia ownerId y marca como no adoptable
  Future<void> adoptPet(String petId, String newOwnerId) async {
    final pet = await _firestore.getPetById(petId);
    pet.ownerId = newOwnerId;
    pet.isAdoptable = false;
    await _firestore.updatePet(pet);
    notifyListeners();
  }

  // Eliminar mascota
  Future<void> deletePet(String id) async {
    await _firestore.deletePet(id);
    notifyListeners();
  }
}
