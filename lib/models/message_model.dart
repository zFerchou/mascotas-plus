class MessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
    };
  }

  static MessageModel fromMap(Map<String, dynamic> map) {
    return MessageModel(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isRead: map['isRead'] ?? false,
    );
  }
}

class ConversationModel {
  final String id;
  final String petId;
  final String petName;
  final String ownerId;
  final String interestedUserId;
  final String interestedUserName;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String lastMessageSenderId;
  final List<String> participants;
  final DateTime createdAt;

  ConversationModel({
    required this.id,
    required this.petId,
    required this.petName,
    required this.ownerId,
    required this.interestedUserId,
    required this.interestedUserName,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.participants,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'ownerId': ownerId,
      'interestedUserId': interestedUserId,
      'interestedUserName': interestedUserName,
      'lastMessageTime': lastMessageTime.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'participants': participants,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  static ConversationModel fromMap(Map<String, dynamic> map) {
    return ConversationModel(
      id: map['id'] ?? '',
      petId: map['petId'] ?? '',
      petName: map['petName'] ?? '',
      ownerId: map['ownerId'] ?? '',
      interestedUserId: map['interestedUserId'] ?? '',
      interestedUserName: map['interestedUserName'] ?? '',
      lastMessageTime: DateTime.fromMillisecondsSinceEpoch(map['lastMessageTime'] ?? 0),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageSenderId: map['lastMessageSenderId'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  // Helper para obtener el nombre del otro usuario
  String getOtherUserName(String currentUserId) {
    if (currentUserId == ownerId) {
      return interestedUserName;
    } else {
      return 'Dueño de $petName';
    }
  }

  // Helper para obtener el ID del otro usuario
  String getOtherUserId(String currentUserId) {
    if (currentUserId == ownerId) {
      return interestedUserId;
    } else {
      return ownerId;
    }
  }

  // Obtener contador de no leídos para este usuario
  int getUnreadCountForUser(String userId, Map<String, dynamic> data) {
    return data['unreadCount_$userId'] ?? 0;
  }
}