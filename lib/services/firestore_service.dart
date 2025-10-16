import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar mascota
  Future<void> addPet(PetModel pet) async {
    await _db.collection('pets').doc(pet.id).set(pet.toMap());
  }

  // Actualizar mascota existente
  Future<void> updatePet(PetModel pet) async {
    await _db.collection('pets').doc(pet.id).update(pet.toMap());
  }

  // Obtener mascota por ID
  Future<PetModel> getPetById(String petId) async {
    final doc = await _db.collection('pets').doc(petId).get();
    if (!doc.exists) throw Exception('Mascota no encontrada');
    return PetModel.fromMap({...doc.data()!, 'id': doc.id});
  }

  // Obtener mascotas por usuario
  Stream<List<PetModel>> getPetsByUser(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromMap({...doc.data(), 'id': doc.id}))
            .toList());
  }

  // Obtener mascotas disponibles para adopción (excluyendo las del usuario actual)
  Stream<List<PetModel>> getPetsForAdoption(String currentUserId) {
    return _db
        .collection('pets')
        .where('isAdoptable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final pets = snapshot.docs
          .map((doc) => PetModel.fromMap({...doc.data(), 'id': doc.id}))
          // Filtramos en memoria para evitar problemas de índice
          .where((pet) => pet.ownerId != currentUserId)
          .toList();
      print("🐾 Mascotas adoptables encontradas: ${pets.length}");
      return pets;
    });
  }

  // Eliminar mascota
  Future<void> deletePet(String id) async {
    await _db.collection('pets').doc(id).delete();
  }
}
