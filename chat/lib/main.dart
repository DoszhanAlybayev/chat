import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'chat_page.dart';
import 'bloc/chat_bloc.dart';
import 'repositories/file_repository.dart';

void main() {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Обработчик для Flutter ошибок
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) {
        debugPrint('Flutter Error: ${details.exception}');
        debugPrint('Stack trace: ${details.stack}');
      }
    };
    
    runApp(const MyApp());
  }, (error, stack) {
    // Обработчик для необработанных асинхронных ошибок
    if (kDebugMode) {
      debugPrint('Unhandled error: $error');
      debugPrint('Stack trace: $stack');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chat App',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ru', 'RU'),
        Locale('en', 'US'),
      ],
      locale: Locale('ru', 'RU'),
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