import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message.dart';
import '../repositories/file_repository.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FileRepository _fileRepository;

  ChatBloc({required FileRepository fileRepository})
      : _fileRepository = fileRepository,
        super(const ChatInitial()) {
    
    on<SendMessage>(_onSendMessage);
    on<OpenCamera>(_onOpenCamera);
    on<OpenGallery>(_onOpenGallery);
    on<OpenFilePicker>(_onOpenFilePicker);
    on<ToggleAttachmentMenu>(_onToggleAttachmentMenu);
    on<AddAttachment>(_onAddAttachment);

    // Инициализируем с пустым списком сообщений
    emit(const ChatLoaded(messages: []));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      if (event.text.trim().isEmpty) return;

      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text.trim(),
        isMe: true,
        timestamp: DateTime.now(),
      );

      final updatedMessages = List<Message>.from(currentState.messages)
        ..add(newMessage);

      emit(currentState.copyWith(messages: updatedMessages));

      // Симуляция ответа
      _simulateResponse(emit, currentState);
    }
  }

  void _onToggleAttachmentMenu(ToggleAttachmentMenu event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(
        isAttachmentMenuVisible: !currentState.isAttachmentMenuVisible,
      ));
    }
  }

  Future<void> _onOpenCamera(OpenCamera event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      // Закрываем меню
      emit(currentState.copyWith(isAttachmentMenuVisible: false));

      try {
        final image = await _fileRepository.pickImageFromCamera();
        if (image != null) {
          add(AddAttachment(
            text: '📷 Фотография отправлена',
            attachmentType: 'image',
            attachmentPath: image.path,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при открытии камеры',
        ));
      }
    }
  }

  Future<void> _onOpenGallery(OpenGallery event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      // Закрываем меню
      emit(currentState.copyWith(isAttachmentMenuVisible: false));

      try {
        final image = await _fileRepository.pickImageFromGallery();
        if (image != null) {
          add(AddAttachment(
            text: '🖼️ Изображение из галереи',
            attachmentType: 'image',
            attachmentPath: image.path,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при открытии галереи',
        ));
      }
    }
  }

  Future<void> _onOpenFilePicker(OpenFilePicker event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      // Закрываем меню
      emit(currentState.copyWith(isAttachmentMenuVisible: false));

      try {
        final file = await _fileRepository.pickFile();
        if (file != null) {
          add(AddAttachment(
            text: '📎 Файл: ${file.name}',
            attachmentType: 'file',
            attachmentPath: file.path,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при выборе файла',
        ));
      }
    }
  }

  void _onAddAttachment(AddAttachment event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: event.text,
        isMe: true,
        timestamp: DateTime.now(),
        attachmentType: event.attachmentType,
        attachmentPath: event.attachmentPath,
      );

      final updatedMessages = List<Message>.from(currentState.messages)
        ..add(newMessage);

      emit(currentState.copyWith(messages: updatedMessages));
    }
  }

  void _simulateResponse(Emitter<ChatState> emit, ChatLoaded currentState) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        final responseMessage = Message(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Понял, обрабатываю ваш запрос...',
          isMe: false,
          timestamp: DateTime.now(),
        );

        final updatedMessages = List<Message>.from(currentState.messages)
          ..add(responseMessage);

        emit(currentState.copyWith(messages: updatedMessages));
      }
    });
  }
}
