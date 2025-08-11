import 'package:equatable/equatable.dart';

enum MessageStatus {
  sending,    // отправляется (часы)
  sent,       // отправлено (одна галочка)
  delivered,  // доставлено (две галочки)
  read,       // прочитано (две синие галочки)
}

class Message extends Equatable {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? attachmentType; // 'image', 'file', etc.
  final String? attachmentPath;
  final MessageStatus status;

  const Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.attachmentType,
    this.attachmentPath,
    this.status = MessageStatus.sent,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    String? attachmentType,
    String? attachmentPath,
    MessageStatus? status,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        text,
        isMe,
        timestamp,
        attachmentType,
        attachmentPath,
        status,
      ];
}
