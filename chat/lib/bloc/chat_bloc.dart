import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/message.dart';
import '../models/attachment.dart';
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
    on<AddPendingAttachment>(_onAddPendingAttachment);
    on<RemovePendingAttachment>(_onRemovePendingAttachment);
    on<ClearPendingAttachments>(_onClearPendingAttachments);
    on<ViewAttachment>(_onViewAttachment);
    on<DownloadFile>(_onDownloadFile);
    on<ClearError>(_onClearError);

    // Инициализируем с тестовыми сообщениями для демонстрации времени и дат
    final now = DateTime.now();
    final testMessages = [
      Message(
        id: '1',
        text: 'Привет! Как дела?',
        isMe: false,
        timestamp: now.subtract(Duration(days: 2, hours: 10)),
      ),
      Message(
        id: '2',
        text: 'Привет! Отлично, спасибо!',
        isMe: true,
        timestamp: now.subtract(Duration(days: 2, hours: 9, minutes: 45)),
      ),
      Message(
        id: '3',
        text: 'Что планируешь на выходные?',
        isMe: false,
        timestamp: now.subtract(Duration(days: 1, hours: 14)),
      ),
      Message(
        id: '4',
        text: 'Думаю съездить на дачу 🌲',
        isMe: true,
        timestamp: now.subtract(Duration(days: 1, hours: 13, minutes: 30)),
      ),
      Message(
        id: '5',
        text: 'Отличная идея!',
        isMe: false,
        timestamp: now.subtract(Duration(hours: 2)),
      ),
    ];
    
    emit(ChatLoaded(messages: testMessages));
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      try {
        // Проверяем, есть ли текст или вложения
        if (event.text.trim().isEmpty && currentState.pendingAttachments.isEmpty) return;

        List<Message> newMessages = [];

        // Если есть текст, создаем текстовое сообщение
        if (event.text.trim().isNotEmpty) {
          final textMessage = Message(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: event.text.trim(),
            isMe: true,
            timestamp: DateTime.now(),
          );
          newMessages.add(textMessage);
        }

        // Создаем сообщения для каждого вложения
        for (int i = 0; i < currentState.pendingAttachments.length; i++) {
          final attachment = currentState.pendingAttachments[i];
          final attachmentMessage = Message(
            id: '${DateTime.now().millisecondsSinceEpoch}_${attachment.id}_$i',
            text: '', // Без текста для вложений
            isMe: true,
            timestamp: DateTime.now().add(Duration(milliseconds: i)), // Чуть разное время
            attachmentType: attachment.type,
            attachmentPath: attachment.path,
          );
          newMessages.add(attachmentMessage);
        }

        final updatedMessages = List<Message>.from(currentState.messages)
          ..addAll(newMessages);

        // Очищаем pending attachments и обновляем сообщения
        emit(currentState.copyWith(
          messages: updatedMessages,
          pendingAttachments: [],
          errorMessage: null, // Очищаем предыдущие ошибки
        ));

        // Симуляция ответа только для текстовых сообщений
        if (event.text.trim().isNotEmpty) {
          _simulateResponse(emit);
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при отправке сообщения: $e',
        ));
      }
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
          add(AddPendingAttachment(
            type: 'image',
            path: image.path,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при открытии камеры: ${e.toString()}',
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
          add(AddPendingAttachment(
            type: 'image',
            path: image.path,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при открытии галереи: ${e.toString()}',
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
          add(AddPendingAttachment(
            type: 'file',
            path: file.path!,
            name: file.name,
          ));
        }
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при выборе файла: ${e.toString()}',
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

  void _onAddPendingAttachment(AddPendingAttachment event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final newAttachment = Attachment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: event.type,
        path: event.path,
        name: event.name,
      );

      final updatedAttachments = List<Attachment>.from(currentState.pendingAttachments)
        ..add(newAttachment);

      emit(currentState.copyWith(pendingAttachments: updatedAttachments));
    }
  }

  void _onRemovePendingAttachment(RemovePendingAttachment event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      final updatedAttachments = currentState.pendingAttachments
          .where((attachment) => attachment.id != event.attachmentId)
          .toList();

      emit(currentState.copyWith(pendingAttachments: updatedAttachments));
    }
  }

  void _onClearPendingAttachments(ClearPendingAttachments event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(pendingAttachments: []));
    }
  }

  void _onViewAttachment(ViewAttachment event, Emitter<ChatState> emit) {
    // Этот обработчик может быть использован для логирования или статистики
    // Основная логика открытия вложений будет в UI
  }

  void _onDownloadFile(DownloadFile event, Emitter<ChatState> emit) async {
    final currentState = state;
    if (currentState is ChatLoaded) {
      try {
        // Здесь можно добавить логику скачивания файла
        // Пока что просто показываем уведомление через SnackBar в UI
      } catch (e) {
        emit(currentState.copyWith(
          errorMessage: 'Ошибка при сохранении файла',
        ));
      }
    }
  }

  void _onClearError(ClearError event, Emitter<ChatState> emit) {
    final currentState = state;
    if (currentState is ChatLoaded) {
      emit(currentState.copyWith(errorMessage: null));
    }
  }

  void _simulateResponse(Emitter<ChatState> emit) {
    Future.delayed(const Duration(seconds: 1), () {
      if (!isClosed) {
        final currentState = state;
        if (currentState is ChatLoaded) {
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
      }
    });
  }
}
