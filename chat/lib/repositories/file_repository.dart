import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class FileRepository {
  final ImagePicker _imagePicker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Ошибка при открытии камеры: $e');
      }
      throw Exception('Ошибка при открытии камеры: $e');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Неожиданная ошибка при открытии камеры: $e');
      }
      throw Exception('Неожиданная ошибка при открытии камеры: $e');
    }
  }

  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Ошибка при открытии галереи: $e');
      }
      throw Exception('Ошибка при открытии галереи: $e');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Неожиданная ошибка при открытии галереи: $e');
      }
      throw Exception('Неожиданная ошибка при открытии галереи: $e');
    }
  }

  Future<PlatformFile?> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        return result.files.single;
      }
      return null;
    } on Exception catch (e) {
      if (kDebugMode) {
        debugPrint('Ошибка при выборе файла: $e');
      }
      throw Exception('Ошибка при выборе файла: $e');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Неожиданная ошибка при выборе файла: $e');
      }
      throw Exception('Неожиданная ошибка при выборе файла: $e');
    }
  }
}
