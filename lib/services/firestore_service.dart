import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Agregar mascota
  Future<void> addPet(PetModel pet) async {
    await _db.collection('pets').doc(pet.id).set(pet.toMap());
  }

  // Obtener mascotas por usuario
  Stream<List<PetModel>> getPetsByUser(String ownerId) {
    return _db
        .collection('pets')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PetModel.fromMap(doc.data()))
            .toList());
  }

  // Eliminar mascota
  Future<void> deletePet(String id) async {
    await _db.collection('pets').doc(id).delete();
  }
}
