import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/chat_bloc.dart';
import 'bloc/chat_event.dart';
import 'bloc/chat_state.dart';
import 'models/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
                  duration: Duration(seconds: 3),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is ChatLoaded) {
            return Column(
              children: <Widget>[
                Expanded(child: _buildChatBody(state.messages)),
                _buildInputBar(state.isAttachmentMenuVisible),
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
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              return _buildMessageBubble(message);
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 18, color: Colors.grey[600]),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: message.isMe ? Color(0xFF007AFF) : Colors.white,
                borderRadius: BorderRadius.circular(20.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
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

  Widget _buildInputBar(bool isMenuVisible) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Анимированное меню вложений
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: isMenuVisible ? 50 : 0,
              child: ClipRect(
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: 250),
                  opacity: isMenuVisible ? 1.0 : 0.0,
                  child: _buildAttachmentMenu(isMenuVisible),
                ),
              ),
            ),
            // Основная строка ввода
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
              child: Row(
                children: <Widget>[
                  AnimatedRotation(
                    turns: isMenuVisible ? 0.125 : 0.0, // поворот на 45 градусов
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
    if (_messageController.text.trim().isNotEmpty) {
      context.read<ChatBloc>().add(SendMessage(_messageController.text));
      _messageController.clear();
    }
  }
}
