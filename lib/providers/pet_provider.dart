import 'dart:io';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
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

  // ✅ CORREGIDO: Subir imagen de mascota - EVITAR BLOB URLs
  Future<String?> uploadPetImage(File? imageFile, String? imageUrl, String userId) async {
    try {
      // ❌ EVITAR blob URLs - siempre subir a Firebase Storage
      if (kIsWeb && imageUrl != null && !imageUrl.startsWith('blob:')) {
        // Solo usar URL si NO es blob (caso raro en web)
        return imageUrl;
      } else if (imageFile != null) {
        // ✅ SIEMPRE subir a Firebase Storage para URLs permanentes
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('pet_images')
            .child(userId)
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        
        await storageRef.putFile(imageFile);
        String downloadUrl = await storageRef.getDownloadURL();
        print('✅ Imagen subida a Firebase Storage: $downloadUrl');
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  // ✅ CORREGIDO: Agregar mascota con imagen - MANEJO MEJORADO
  Future<void> addPet({
    required String ownerId,
    required String name,
    required String species,
    String? birthDate,
    List<Map<String, dynamic>>? vaccines,
    List<Map<String, dynamic>>? appointments,
    bool isAdoptable = false,
    File? imageFile,
    String? imageUrl,
  }) async {
    
    String? uploadedImageUrl;
    
    // ✅ SUBIR IMAGEN SI EXISTE (incluso en web)
    if (imageFile != null || (imageUrl != null && imageUrl.startsWith('blob:'))) {
      print('📤 Subiendo imagen...');
      uploadedImageUrl = await uploadPetImage(imageFile, imageUrl, ownerId);
    } else if (imageUrl != null && !imageUrl.startsWith('blob:')) {
      // Si ya es una URL válida (no blob), usarla directamente
      uploadedImageUrl = imageUrl;
    }

    final newPet = PetModel(
      id: _uuid.v4(),
      ownerId: ownerId,
      name: name,
      species: species,
      birthDate: birthDate ?? '',
      vaccines: vaccines ?? [],
      appointments: appointments ?? [],
      isAdoptable: isAdoptable,
      imageUrl: uploadedImageUrl,
    );

    await _firestore.addPet(newPet);
    notifyListeners();
  }

  // Actualizar mascota
  Future<void> updatePet(PetModel pet) async {
    await _firestore.updatePet(pet);
    notifyListeners();
  }

  // Adoptar mascota
  Future<void> adoptPet(String petId, String newOwnerId) async {
    try {
      final pet = await _firestore.getPetById(petId);
      
      final adoptedPet = PetModel(
        id: pet.id,
        ownerId: newOwnerId,
        name: pet.name,
        species: pet.species,
        birthDate: pet.birthDate,
        vaccines: pet.vaccines,
        appointments: pet.appointments,
        isAdoptable: false,
        imageUrl: pet.imageUrl,
      );

      await _firestore.updatePet(adoptedPet);
      notifyListeners();
      
    } catch (e) {
      print('Error en adopción: $e');
      rethrow;
    }
  }

  // Eliminar mascota
  Future<void> deletePet(String id) async {
    await _firestore.deletePet(id);
    notifyListeners();
  }
}