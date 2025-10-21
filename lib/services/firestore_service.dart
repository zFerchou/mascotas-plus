import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/pet_model.dart';
import '../models/message_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ========== MASCOTAS ==========

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

  // ========== SISTEMA DE MENSAJES ==========

  // Obtener conversaciones del usuario
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ConversationModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Obtener mensajes de una conversación
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _db
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return MessageModel.fromMap({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  // Enviar mensaje
  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String content,
    required String petId,
    required String petName,
  }) async {
    try {
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final message = MessageModel(
        id: messageId,
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        timestamp: DateTime.now(),
      );

      print('📤 Enviando mensaje: $content');
      print('📝 ConversationId: $conversationId');
      print('👤 Sender: $senderId, Receiver: $receiverId');

      // Agregar mensaje a la subcolección
      await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .set(message.toMap());

      // Actualizar última información de la conversación
      await _db.collection('conversations').doc(conversationId).update({
        'lastMessage': content,
        'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
        'lastMessageSenderId': senderId,
      });

      print('✅ Mensaje enviado exitosamente');

      // Actualizar contador de no leídos
      await _updateUnreadCount(conversationId);

    } catch (e) {
      print('❌ Error enviando mensaje: $e');
      rethrow;
    }
  }

  // Iniciar conversación
  Future<String> startConversation({
    required String petId,
    required String petName,
    required String ownerId,
    required String interestedUserId,
    required String interestedUserName,
  }) async {
    try {
      final conversationId = '${petId}_$interestedUserId';
      
      print('🚀 Iniciando conversación: $conversationId');
      print('🐾 Mascota: $petName ($petId)');
      print('👤 Dueño: $ownerId, Interesado: $interestedUserId');

      // Verificar si ya existe la conversación
      final existingConv = await _db.collection('conversations').doc(conversationId).get();
      
      if (!existingConv.exists) {
        print('📝 Creando nueva conversación...');
        
        final conversation = {
          'id': conversationId,
          'petId': petId,
          'petName': petName,
          'ownerId': ownerId,
          'interestedUserId': interestedUserId,
          'interestedUserName': interestedUserName,
          'lastMessageTime': DateTime.now().millisecondsSinceEpoch,
          'lastMessage': 'Conversación iniciada sobre $petName',
          'lastMessageSenderId': interestedUserId,
          'participants': [ownerId, interestedUserId],
          'createdAt': DateTime.now().millisecondsSinceEpoch,
          'unreadCount_$ownerId': 1, // El dueño tiene 1 mensaje no leído
          'unreadCount_$interestedUserId': 0, // El interesado no tiene mensajes no leídos
        };

        await _db
            .collection('conversations')
            .doc(conversationId)
            .set(conversation);

        print('✅ Conversación creada exitosamente');
      } else {
        print('ℹ️ Conversación ya existe, usando la existente');
      }

      return conversationId;
    } catch (e) {
      print('❌ Error iniciando conversación: $e');
      rethrow;
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      print('📖 Marcando mensajes como leídos para: $userId');
      
      final messagesSnapshot = await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      print('📨 Mensajes no leídos encontrados: ${messagesSnapshot.docs.length}');

      if (messagesSnapshot.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in messagesSnapshot.docs) {
          batch.update(doc.reference, {'isRead': true});
        }
        await batch.commit();
        
        // Actualizar contador en la conversación
        await _updateUnreadCount(conversationId);
        
        print('✅ Mensajes marcados como leídos');
      }
    } catch (e) {
      print('❌ Error marcando mensajes como leídos: $e');
      rethrow;
    }
  }

  // Actualizar contador de no leídos
  Future<void> _updateUnreadCount(String conversationId) async {
    try {
      final conversationDoc = await _db.collection('conversations').doc(conversationId).get();
      if (conversationDoc.exists) {
        final data = conversationDoc.data() as Map<String, dynamic>;
        final participants = List<String>.from(data['participants'] ?? []);
        
        // Para cada participante, contar mensajes no leídos
        for (final participantId in participants) {
          final unreadCount = await _getUnreadCountForUser(conversationId, participantId);
          await _db.collection('conversations').doc(conversationId).update({
            'unreadCount_$participantId': unreadCount,
          });
        }
        
        print('🔢 Contadores de no leídos actualizados para: $participants');
      }
    } catch (e) {
      print('❌ Error actualizando contadores: $e');
    }
  }

  // Obtener conteo de mensajes no leídos para un usuario específico
  Future<int> _getUnreadCountForUser(String conversationId, String userId) async {
    try {
      final snapshot = await _db
          .collection('conversations')
          .doc(conversationId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      final count = snapshot.docs.length;
      print('📊 Mensajes no leídos para $userId: $count');
      return count;
    } catch (e) {
      print('❌ Error obteniendo contador de no leídos: $e');
      return 0;
    }
  }

  // Obtener conteo total de mensajes no leídos
  Stream<int> getUnreadCount(String userId) {
    return _db
        .collection('conversations')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      int totalUnread = 0;
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final unreadCount = data['unreadCount_$userId'] ?? 0;
        totalUnread += unreadCount as int;
      }
      
      print('🔔 Total mensajes no leídos para $userId: $totalUnread');
      return totalUnread;
    });
  }

  // Método auxiliar para obtener información del usuario
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final doc = await _db.collection('usuarios').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error obteniendo info usuario: $e');
      return null;
    }
  }

  // Adoptar mascota
  Future<void> adoptPet(String petId, String newOwnerId) async {
    try {
      await _db.collection('pets').doc(petId).update({
        'ownerId': newOwnerId,
        'isAdoptable': false,
        'adoptedAt': DateTime.now().millisecondsSinceEpoch,
      });
      print('✅ Mascota $petId adoptada por $newOwnerId');
    } catch (e) {
      print('❌ Error adoptando mascota: $e');
      rethrow;
    }
  }
}