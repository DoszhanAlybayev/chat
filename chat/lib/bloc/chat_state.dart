import 'package:equatable/equatable.dart';
import '../models/message.dart';
import '../models/attachment.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoaded extends ChatState {
  final List<Message> messages;
  final bool isAttachmentMenuVisible;
  final String? errorMessage;
  final List<Attachment> pendingAttachments;

  const ChatLoaded({
    required this.messages,
    this.isAttachmentMenuVisible = false,
    this.errorMessage,
    this.pendingAttachments = const [],
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isAttachmentMenuVisible,
    String? errorMessage,
    List<Attachment>? pendingAttachments,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isAttachmentMenuVisible: isAttachmentMenuVisible ?? this.isAttachmentMenuVisible,
      errorMessage: errorMessage,
      pendingAttachments: pendingAttachments ?? this.pendingAttachments,
    );
  }

  @override
  List<Object?> get props => [messages, isAttachmentMenuVisible, errorMessage, pendingAttachments];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
