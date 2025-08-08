import 'package:equatable/equatable.dart';

class Attachment extends Equatable {
  final String id;
  final String type; // 'image' or 'file'
  final String path;
  final String? name;

  const Attachment({
    required this.id,
    required this.type,
    required this.path,
    this.name,
  });

  @override
  List<Object?> get props => [id, type, path, name];
}
