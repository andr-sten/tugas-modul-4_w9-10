// lib/task_api_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'task_api_model.g.dart'; // File yang akan di-generate

@JsonSerializable()
class TaskDto {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;

  TaskDto({this.id, required this.title, this.description, this.isCompleted = false});

  // Factory method untuk deserialisasi (JSON ke Dart)
  factory TaskDto.fromJson(Map<String, dynamic> json) => _$TaskDtoFromJson(json);

  // Method untuk serialisasi (Dart ke JSON)
  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}