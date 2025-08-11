import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_event.dart';
import 'bloc/chat_state.dart';
import 'models/message.dart';
import 'models/attachment.dart';
import 'widgets/image_viewer_page.dart';
import 'widgets/file_viewer_dialog.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'ru_RU';
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatBloc, ChatState>(
        listener: (context, state) {
          if (state is ChatLoaded) {
            if (state.isAttachmentMenuVisible) {
              _animationController.forward();
            } else {
              _animationController.reverse();
            }
            
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 4),
                  action: SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    },
                  ),
                ),
              );
              
              // Автоматически очищаем ошибку через небольшую задержку
              Future.delayed(Duration(milliseconds: 100), () {
                if (mounted) {
                  context.read<ChatBloc>().add(ClearError());
                }
              });
            }
          }
        },
        builder: (context, state) {
          if (state is ChatLoaded) {
            return Column(
              children: <Widget>[
                Expanded(child: _buildChatBody(state.messages)),
                _buildInputBar(state),
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
        onPressed: () {},
      ),
      title: Text(
        'Иван Бригадиров',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: false,
      elevation: 1,
    );
  }

  Widget _buildChatBody(List<Message> messages) {
    return Column(
      children: [
        // Заявка на услуги (отдельный элемент, не сообщение)
        Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildApplicationCard(),
        ),
        // Список сообщений
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _getMessagesWithDateHeaders(messages).length,
            itemBuilder: (context, index) {
              final item = _getMessagesWithDateHeaders(messages)[index];
              if (item is String) {
                // Это заголовок даты
                return _buildDateHeader(item);
              } else if (item is Message) {
                // Это сообщение
                return _buildMessageBubble(item);
              }
              return Container();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildApplicationCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5.0, spreadRadius: 1.0),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.list_alt, color: Color(0xFF007AFF)),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Заявка на услуги Бригадира:',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Ремонт квартиры',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Message message) {
    // Для сообщений только с вложениями используем компактный стиль
    final bool isAttachmentOnly = (message.attachmentType == 'image' || message.attachmentType == 'file') && message.text.isEmpty;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isAttachmentOnly ? 2.0 : 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
            ),
            SizedBox(width: 8),
          ],
          
          // Основное содержимое сообщения
          isAttachmentOnly
            ? // Для вложений без текста используем компактный режим
              Flexible(
                child: GestureDetector(
                  onTap: () => _handleAttachmentTap(message),
                  child: _buildAttachmentPreview(message),
                ),
              )
            : // Для обычных сообщений и сообщений с текстом
              Flexible(
                child: GestureDetector(
                  onTap: message.attachmentType != null ? () => _handleAttachmentTap(message) : null,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(
                      color: message.isMe ? Color(0xFF007AFF) : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4.0,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (message.attachmentType != null) ...[
                          _buildAttachmentPreview(message),
                          if (message.text.isNotEmpty) SizedBox(height: 8),
                        ],
                        if (message.text.isNotEmpty || message.attachmentType == null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (message.text.isNotEmpty)
                                Flexible(
                                  child: Text(
                                    message.text,
                                    style: TextStyle(
                                      color: message.isMe ? Colors.white : Colors.black87,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              SizedBox(width: 8),
                              Text(
                                _formatMessageTime(message.timestamp),
                                style: TextStyle(
                                  color: message.isMe 
                                    ? Colors.white.withValues(alpha: 0.7) 
                                    : Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          
          if (message.isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFF007AFF),
              child: Icon(Icons.person, size: 18, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatLoaded state) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Показать pending attachments, если они есть
            if (state.pendingAttachments.isNotEmpty)
              _buildPendingAttachments(state.pendingAttachments),
            
            // Анимированное меню вложений
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: state.isAttachmentMenuVisible ? 50 : 0,
              child: ClipRect(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 250),
                  opacity: state.isAttachmentMenuVisible ? 1.0 : 0.0,
                  child: _buildAttachmentMenu(state.isAttachmentMenuVisible),
                ),
              ),
            ),
            // Основная строка ввода
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: <Widget>[
                  AnimatedRotation(
                    turns: state.isAttachmentMenuVisible ? 0.125 : 0.0, // поворот на 45 градусов
                    duration: Duration(milliseconds: 300),
                    child: IconButton(
                      icon: Icon(Icons.add, color: Color(0xFF007AFF), size: 28),
                      onPressed: () {
                        context.read<ChatBloc>().add(const ToggleAttachmentMenu());
                      },
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Написать сообщение...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        onSubmitted: (text) {
                          _sendMessage();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  IconButton(
                    onPressed: _sendMessage,
                    icon: Transform.rotate(
                      angle: -45 * 3.14159265359 / 180,
                      child: Icon(Icons.send, color: Color(0xFF007AFF), size: 24),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentMenu(bool isMenuVisible) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.camera_alt_outlined,
              () => context.read<ChatBloc>().add(const OpenCamera()),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.image_outlined,
              () => context.read<ChatBloc>().add(const OpenGallery()),
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            curve: Curves.elasticOut,
            transform: Matrix4.translationValues(
              0, isMenuVisible ? 0 : 20, 0
            ),
            child: _buildAttachmentIcon(
              Icons.file_copy_outlined,
              () => context.read<ChatBloc>().add(const OpenFilePicker()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentIcon(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Icon(
            icon, 
            size: 28, 
            color: Color(0xFF007AFF),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final currentState = context.read<ChatBloc>().state;
    if (currentState is ChatLoaded) {
      // Отправляем если есть текст или вложения
      if (_messageController.text.trim().isNotEmpty || currentState.pendingAttachments.isNotEmpty) {
        context.read<ChatBloc>().add(SendMessage(_messageController.text));
        _messageController.clear();
      }
    }
  }

  Widget _buildAttachmentPreview(Message message) {
    if (message.attachmentType == null) return Container();
    
    final isImage = message.attachmentType == 'image';
    
    if (isImage && message.attachmentPath != null) {
      // Для изображений показываем компактный thumbnail
      final imageFile = File(message.attachmentPath!);
      
      return Container(
        constraints: BoxConstraints(
          maxWidth: 250,  // Увеличили максимальную ширину
          maxHeight: 300, // Увеличили максимальную высоту
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),  // Уменьшили радиус
              child: imageFile.existsSync() 
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image,
                          color: Colors.grey[400],
                          size: 40,
                        ),
                      );
                    },
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.grey[400],
                          size: 30,
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Файл не найден',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
            ),
            // Время в правом нижнем углу изображения (как в WhatsApp)
            if (message.text.isEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else if (message.attachmentType == 'file' && message.attachmentPath != null) {
      // Для файлов показываем компактный вид как в WhatsApp
      final fileName = message.attachmentPath?.split('/').last ?? 'Файл';
      final bool showTimeInFile = message.text.isEmpty; // Показываем время в файле, если нет текста
      
      return Container(
        width: double.infinity, // Занимаем всю доступную ширину
        constraints: BoxConstraints(
          maxWidth: 280,
          minHeight: 60, // Минимальная высота для файла
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? Color(0xFF007AFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: !message.isMe ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4.0,
              spreadRadius: 0.5,
            ),
          ] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: message.isMe ? Colors.white.withValues(alpha: 0.2) : Color(0xFF007AFF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.description,
                    size: 20,
                    color: message.isMe ? Colors.white : Color(0xFF007AFF),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        fileName,
                        style: TextStyle(
                          color: message.isMe ? Colors.white : Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Документ',
                        style: TextStyle(
                          color: message.isMe ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Icon(
                  Icons.download_outlined,
                  size: 18,
                  color: message.isMe ? Colors.white.withValues(alpha: 0.8) : Colors.grey[600],
                ),
              ],
            ),
            // Показываем время внизу файла, если нет текста
            if (showTimeInFile) ...[
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatMessageTime(message.timestamp),
                  style: TextStyle(
                    color: message.isMe 
                      ? Colors.white.withValues(alpha: 0.7) 
                      : Colors.grey[500],
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }
    
    // Fallback для неизвестных типов вложений
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Неподдерживаемое вложение',
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 12,
        ),
      ),
    );
  }

  void _handleAttachmentTap(Message message) {
    if (message.attachmentType == null || message.attachmentPath == null) {
      return;
    }

    // Отправляем событие в BLoC для логирования
    context.read<ChatBloc>().add(ViewAttachment(
      messageId: message.id,
      attachmentType: message.attachmentType!,
      attachmentPath: message.attachmentPath,
    ));

    // Открываем вложение в зависимости от типа
    if (message.attachmentType == 'image') {
      _openImageViewer(message.attachmentPath!);
    } else if (message.attachmentType == 'file') {
      _openFileViewer(message.attachmentPath!);
    }
  }

  void _openImageViewer(String imagePath) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ImageViewerPage(imagePath: imagePath),
      ),
    );
  }

  void _openFileViewer(String filePath) {
    final fileName = filePath.split('/').last;
    showDialog(
      context: context,
      builder: (context) => FileViewerDialog(
        filePath: filePath,
        fileName: fileName,
      ),
    );
  }

  List<dynamic> _getMessagesWithDateHeaders(List<Message> messages) {
    List<dynamic> result = [];
    String? lastDate;

    for (Message message in messages) {
      String currentDate = _formatDateHeader(message.timestamp);
      
      if (lastDate == null || lastDate != currentDate) {
        result.add(currentDate);
        lastDate = currentDate;
      }
      
      result.add(message);
    }

    return result;
  }

  String _formatDateHeader(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Сегодня';
    } else if (messageDate == yesterday) {
      return 'Вчера';
    } else {
      return DateFormat('d MMMM yyyy', 'ru').format(dateTime);
    }
  }

  String _formatMessageTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  Widget _buildDateHeader(String dateText) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPendingAttachments(List<Attachment> attachments) {
    return Container(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Готово к отправке:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final attachment = attachments[index];
                return _buildPendingAttachmentItem(attachment);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingAttachmentItem(Attachment attachment) {
    return Container(
      width: 70,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: attachment.type == 'image' 
              ? () {
                  final imageFile = File(attachment.path);
                  return imageFile.existsSync()
                    ? Image.file(
                        imageFile,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: Colors.grey[200],
                            child: Icon(Icons.image, color: Colors.grey[400]),
                          );
                        },
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.red[100],
                        child: Icon(Icons.error, color: Colors.red[400]),
                      );
                }()
              : Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[50],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF007AFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(Icons.description, color: Color(0xFF007AFF), size: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        attachment.name?.split('.').last.toUpperCase() ?? 'DOC',
                        style: TextStyle(fontSize: 8, color: Colors.grey[600], fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                context.read<ChatBloc>().add(RemovePendingAttachment(attachment.id));
              },
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
