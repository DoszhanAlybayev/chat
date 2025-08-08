import 'package:equatable/equatable.dart';
import '../models/message.dart';

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

  const ChatLoaded({
    required this.messages,
    this.isAttachmentMenuVisible = false,
    this.errorMessage,
  });

  ChatLoaded copyWith({
    List<Message>? messages,
    bool? isAttachmentMenuVisible,
    String? errorMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      isAttachmentMenuVisible: isAttachmentMenuVisible ?? this.isAttachmentMenuVisible,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [messages, isAttachmentMenuVisible, errorMessage];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
