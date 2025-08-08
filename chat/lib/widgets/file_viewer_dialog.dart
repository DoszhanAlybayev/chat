import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class FileViewerDialog extends StatelessWidget {
  final String filePath;
  final String fileName;

  const FileViewerDialog({
    super.key,
    required this.filePath,
    required this.fileName,
  });

  @override
  Widget build(BuildContext context) {
    final file = File(filePath);
    final fileSize = _formatFileSize(file.lengthSync());
    final fileExtension = fileName.split('.').last.toUpperCase();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          _getFileIcon(fileName),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              fileName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Тип файла:', fileExtension),
          SizedBox(height: 8),
          _buildInfoRow('Размер:', fileSize),
          SizedBox(height: 8),
          _buildInfoRow('Путь:', filePath),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Закрыть',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _openFile(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF007AFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Открыть',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: Colors.black87),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red, size: 32);
      case 'doc':
      case 'docx':
        return Icon(Icons.description, color: Colors.blue, size: 32);
      case 'xls':
      case 'xlsx':
        return Icon(Icons.table_chart, color: Colors.green, size: 32);
      case 'ppt':
      case 'pptx':
        return Icon(Icons.slideshow, color: Colors.orange, size: 32);
      case 'txt':
        return Icon(Icons.text_snippet, color: Colors.grey, size: 32);
      case 'zip':
      case 'rar':
      case '7z':
        return Icon(Icons.archive, color: Colors.purple, size: 32);
      case 'mp3':
      case 'wav':
      case 'flac':
        return Icon(Icons.audio_file, color: Colors.pink, size: 32);
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icon(Icons.video_file, color: Colors.indigo, size: 32);
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icon(Icons.image, color: Colors.teal, size: 32);
      default:
        return Icon(Icons.insert_drive_file, color: Colors.grey, size: 32);
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  Future<void> _openFile(BuildContext context) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть файл: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка при открытии файла: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
