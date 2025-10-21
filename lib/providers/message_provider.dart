import 'package:flutter/foundation.dart';
import '../models/message_model.dart';
import '../services/firestore_service.dart';

class MessageProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ConversationModel> _conversations = [];
  List<MessageModel> _currentMessages = [];

  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get currentMessages => _currentMessages;

  // Obtener conversaciones del usuario
  Stream<List<ConversationModel>> getConversations(String userId) {
    return _firestoreService.getConversations(userId);
  }

  // Obtener mensajes de una conversación
  Stream<List<MessageModel>> getMessages(String conversationId) {
    return _firestoreService.getMessages(conversationId);
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
      await _firestoreService.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        receiverId: receiverId,
        content: content,
        petId: petId,
        petName: petName,
      );
      notifyListeners();
    } catch (e) {
      print('Error en MessageProvider.sendMessage: $e');
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
      return await _firestoreService.startConversation(
        petId: petId,
        petName: petName,
        ownerId: ownerId,
        interestedUserId: interestedUserId,
        interestedUserName: interestedUserName,
      );
    } catch (e) {
      print('Error en MessageProvider.startConversation: $e');
      rethrow;
    }
  }

  // Marcar mensajes como leídos
  Future<void> markMessagesAsRead(String conversationId, String userId) async {
    try {
      await _firestoreService.markMessagesAsRead(conversationId, userId);
      notifyListeners();
    } catch (e) {
      print('Error en MessageProvider.markMessagesAsRead: $e');
    }
  }

  // Obtener conteo de mensajes no leídos
  Stream<int> getUnreadCount(String userId) {
    return _firestoreService.getUnreadCount(userId);
  }

  // Cargar conversaciones (para uso inmediato)
  Future<void> loadConversations(String userId) async {
    try {
      final conversationsStream = getConversations(userId);
      _conversations = await conversationsStream.first;
      notifyListeners();
    } catch (e) {
      print('Error cargando conversaciones: $e');
    }
  }

  // Cargar mensajes (para uso inmediato)
  Future<void> loadMessages(String conversationId) async {
    try {
      final messagesStream = getMessages(conversationId);
      _currentMessages = await messagesStream.first;
      notifyListeners();
    } catch (e) {
      print('Error cargando mensajes: $e');
    }
  }

  // Limpiar datos
  void clearData() {
    _conversations.clear();
    _currentMessages.clear();
    notifyListeners();
  }
}