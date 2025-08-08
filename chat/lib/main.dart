import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_page.dart';
import 'bloc/chat_bloc.dart';
import 'repositories/file_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(
        primaryColor: Color(0xFF007AFF),
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF007AFF)),
        useMaterial3: true,
      ),
      home: BlocProvider(
        create: (context) => ChatBloc(
          fileRepository: FileRepository(),
        ),
        child: const ChatPage(),
      ),
    );
  }
}