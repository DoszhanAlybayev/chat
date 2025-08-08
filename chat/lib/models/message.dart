import 'package:equatable/equatable.dart';

class Message extends Equatable {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final String? attachmentType; // 'image', 'file', etc.
  final String? attachmentPath;

  const Message({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.attachmentType,
    this.attachmentPath,
  });

  Message copyWith({
    String? id,
    String? text,
    bool? isMe,
    DateTime? timestamp,
    String? attachmentType,
    String? attachmentPath,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isMe: isMe ?? this.isMe,
      timestamp: timestamp ?? this.timestamp,
      attachmentType: attachmentType ?? this.attachmentType,
      attachmentPath: attachmentPath ?? this.attachmentPath,
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
      ];
}
