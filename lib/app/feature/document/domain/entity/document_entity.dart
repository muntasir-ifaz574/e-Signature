import 'package:equatable/equatable.dart';

class DocumentEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String fileUrl;
  final DateTime createdAt;
  final String? fieldsJson;
  final bool isPublished;

  const DocumentEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.fileUrl,
    required this.createdAt,
    this.fieldsJson,
    this.isPublished = false,
  });

  DocumentEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? fileUrl,
    DateTime? createdAt,
    String? fieldsJson,
    bool? isPublished,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      fieldsJson: fieldsJson ?? this.fieldsJson,
      isPublished: isPublished ?? this.isPublished,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'fileUrl': fileUrl,
      'createdAt': createdAt.toIso8601String(),
      'fieldsJson': fieldsJson,
      'isPublished': isPublished,
    };
  }

  factory DocumentEntity.fromMap(Map<String, dynamic> map) {
    DateTime createdAtDate = DateTime.now();
    final createdAtRaw = map['createdAt'];
    if (createdAtRaw is String) {
      createdAtDate = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else if (createdAtRaw is Function) {
      // Cloud Firestore Timestamp
      try {
        createdAtDate = (createdAtRaw as dynamic).toDate();
      } catch (_) {}
    } else if (createdAtRaw != null &&
        createdAtRaw.toString().contains("Timestamp")) {
      // Manual check if we can't import cloud_firestore here to keep domain clean
      // But better to just handle dynamic
      try {
        createdAtDate = (createdAtRaw as dynamic).toDate();
      } catch (_) {}
    }

    return DocumentEntity(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      fileUrl: map['fileUrl'] ?? '',
      createdAt: createdAtDate,
      fieldsJson: map['fieldsJson'],
      isPublished: map['isPublished'] ?? false,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    fileUrl,
    createdAt,
    fieldsJson,
    isPublished,
  ];
}
