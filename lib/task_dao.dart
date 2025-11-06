// lib/task_dao.dart - SETELAH MODIFIKASI
import 'package:floor/floor.dart';
import 'task_entity.dart';

@dao
abstract class TaskDao {
  // UBAH DARI Future MENJADI Stream
  @Query('SELECT * FROM Task ORDER BY id DESC')
  Stream<List<Task>> findAll();

  @insert
  Future<int> insertTask(Task task);

  @update
  Future<int> updateTask(Task task);

  @delete
  Future<int> deleteTask(Task task);
}