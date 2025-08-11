import 'package:equatable/equatable.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class SendMessage extends ChatEvent {
  final String text;

  const SendMessage(this.text);

  @override
  List<Object?> get props => [text];
}

class OpenCamera extends ChatEvent {
  const OpenCamera();
}

class OpenGallery extends ChatEvent {
  const OpenGallery();
}

class OpenFilePicker extends ChatEvent {
  const OpenFilePicker();
}

class ToggleAttachmentMenu extends ChatEvent {
  const ToggleAttachmentMenu();
}

class AddAttachment extends ChatEvent {
  final String text;
  final String attachmentType;
  final String? attachmentPath;

  const AddAttachment({
    required this.text,
    required this.attachmentType,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [text, attachmentType, attachmentPath];
}

class AddPendingAttachment extends ChatEvent {
  final String type;
  final String path;
  final String? name;

  const AddPendingAttachment({
    required this.type,
    required this.path,
    this.name,
  });

  @override
  List<Object?> get props => [type, path, name];
}

class RemovePendingAttachment extends ChatEvent {
  final String attachmentId;

  const RemovePendingAttachment(this.attachmentId);

  @override
  List<Object?> get props => [attachmentId];
}

class ClearPendingAttachments extends ChatEvent {
  const ClearPendingAttachments();
}

class ViewAttachment extends ChatEvent {
  final String messageId;
  final String attachmentType;
  final String? attachmentPath;

  const ViewAttachment({
    required this.messageId,
    required this.attachmentType,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [messageId, attachmentType, attachmentPath];
}

class DownloadFile extends ChatEvent {
  final String messageId;
  final String? attachmentPath;

  const DownloadFile({
    required this.messageId,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [messageId, attachmentPath];
}

class ClearError extends ChatEvent {
  const ClearError();
}
