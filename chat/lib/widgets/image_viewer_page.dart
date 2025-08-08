import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'dart:io';

class ImageViewerPage extends StatelessWidget {
  final String imagePath;
  final String title;

  const ImageViewerPage({
    super.key,
    required this.imagePath,
    this.title = 'Просмотр изображения',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // Здесь можно добавить функцию поделиться
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Функция "Поделиться" будет добавлена'),
                  backgroundColor: Color(0xFF007AFF),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          backgroundDecoration: BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2.0,
          heroAttributes: PhotoViewHeroAttributes(tag: imagePath),
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                color: Color(0xFF007AFF),
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / 
                      (event.expectedTotalBytes ?? 1),
              ),
            ),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Ошибка при загрузке изображения',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
