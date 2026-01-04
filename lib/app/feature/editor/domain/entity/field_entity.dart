import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum FieldType { signature, text, checkbox, date }

class FieldEntity extends Equatable {
  final String id;
  final FieldType type;
  final double x;
  final double y;
  final double width;
  final double height;
  final int pageIndex;
  final String? value;
  final bool isRequired;

  const FieldEntity({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    this.width = 100,
    this.height = 50,
    required this.pageIndex,
    this.value,
    this.isRequired = true,
  });

  FieldEntity copyWith({
    String? id,
    FieldType? type,
    double? x,
    double? y,
    double? width,
    double? height,
    int? pageIndex,
    String? value,
    bool? isRequired,
  }) {
    return FieldEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      pageIndex: pageIndex ?? this.pageIndex,
      value: value ?? this.value,
      isRequired: isRequired ?? this.isRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'pageIndex': pageIndex,
      'value': value,
      'isRequired': isRequired,
    };
  }

  factory FieldEntity.fromJson(Map<String, dynamic> json) {
    return FieldEntity(
      id: json['id'],
      type: FieldType.values.firstWhere((e) => e.name == json['type']),
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
      pageIndex: json['pageIndex'] ?? 0,
      value: json['value'],
      isRequired: json['isRequired'] ?? true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    x,
    y,
    width,
    height,
    pageIndex,
    value,
    isRequired,
  ];
}
