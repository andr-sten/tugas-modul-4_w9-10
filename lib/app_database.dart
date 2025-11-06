// lib/app_database.dart
import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite; // Diperlukan untuk Floor
import 'task_entity.dart';
import 'task_dao.dart';

part 'app_database.g.dart'; // File yang akan di-generate oleh Floor

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  TaskDao get taskDao;
}