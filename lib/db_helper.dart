// lib/db_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static const _dbName = 'tasks.db';
  static const _dbVersion = 1;

  static const table = 'tasks';

  // Fungsi untuk membuka koneksi database
  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    // openDatabase akan memanggil onCreate jika database belum ada
    return openDatabase(path, version: _dbVersion, onCreate: (db, v) async {
      await db.execute('CREATE TABLE tasks('
          '  id INTEGER PRIMARY KEY AUTOINCREMENT,'
          '  title TEXT NOT NULL,'
          '  description TEXT,'
          '  isCompleted INTEGER NOT NULL DEFAULT 0'
          ')');
    });
  }

  // Fungsi CREATE (Insert)
  static Future<int> insert(Map<String, dynamic> task) async {
    final db = await _open();
    return db.insert(table, task);
  }

  // Fungsi READ (Query All)
  static Future<List<Map<String, dynamic>>> getTasks({
    int limit = 10,
    int offset = 0,
    String? searchQuery,
  }) async {
    final db = await _open();

    // Tentukan klausa WHERE untuk pencarian
    String? whereClause;
    List<dynamic>? whereArgs;

    if (searchQuery != null && searchQuery.isNotEmpty) {
      // Mencari di kolom title dan description
      whereClause = 'title LIKE ? OR description LIKE ?';
      whereArgs = ['%$searchQuery%', '%$searchQuery%'];
    }

    return db.query(
      table,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'id DESC',
      limit: limit,   // Untuk Paging
      offset: offset, // Untuk Paging
    );
  }

  // Fungsi UPDATE
  static Future<int> update(int id, Map<String, dynamic> data) async {
    final db = await _open();
    return db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  // Fungsi DELETE
  static Future<int> delete(int id) async {
    final db = await _open();
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }
}