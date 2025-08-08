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
