// lib/task_floor_page.dart
import 'package:flutter/material.dart';
import 'app_database.dart'; // Database yang sudah di-generate
import 'task_entity.dart';

class TaskFloorPage extends StatefulWidget {
  const TaskFloorPage({super.key});

  @override
  State<TaskFloorPage> createState() => _TaskFloorPageState();
}

class _TaskFloorPageState extends State<TaskFloorPage> {
  // Gunakan Future untuk menyimpan instance database
  late final Future<AppDatabase> _dbFuture;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Inisialisasi Floor database
    _dbFuture = $FloorAppDatabase.databaseBuilder('app_floor.db').build();

  }

  // Memuat data task


  // Menambah task
  Future<void> _add() async {
    final db = await _dbFuture;
    await db.taskDao.insertTask(Task(title: _titleCtrl.text, description: _descCtrl.text));
    _titleCtrl.clear(); _descCtrl.clear();
  }

  // Mengubah status isCompleted
  Future<void> _toggle(Task t) async {
    final db = await _dbFuture;
    // Membuat objek Task baru dengan isCompleted yang dibalik
    await db.taskDao.updateTask(Task(id: t.id, title: t.title, description: t.description, isCompleted: !t.isCompleted));

  }

  // Menghapus task
  Future<void> _delete(Task t) async {
    final db = await _dbFuture;
    await db.taskDao.deleteTask(t);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task (Floor)')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Judul')),
            TextField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi')),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _add, child: const Text('Tambah')),
          ]),
        ),
        const Divider(),
        // GANTI Expanded DENGAN FutureBuilder DAHULU UNTUK MENDAPATKAN DAO
        Expanded(
          child: FutureBuilder<AppDatabase>(
            future: _dbFuture,
            builder: (context, dbSnapshot) {
              if (dbSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (dbSnapshot.hasError || !dbSnapshot.hasData) {
                return const Center(child: Text('Gagal memuat database.'));
              }

              final taskDao = dbSnapshot.data!.taskDao;

              // STREAMBUILDER: Membaca Stream dari DAO
              return StreamBuilder<List<Task>>(
                stream: taskDao.findAll(),
                builder: (context, streamSnapshot) {
                  if (streamSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final tasks = streamSnapshot.data ?? [];

                  if (tasks.isEmpty) {
                    return const Center(child: Text('Tidak ada task. Tambahkan satu!'));
                  }

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (_, i) {
                      final t = tasks[i];
                      return ListTile(
                        title: Text(t.title),
                        subtitle: Text(t.description ?? ''),
                        leading: IconButton(
                          icon: Icon(t.isCompleted
                              ? Icons.check_box
                              : Icons.check_box_outline_blank),
                          onPressed: () => _toggle(t),
                        ),
                        trailing: IconButton(
                            icon: const Icon(Icons.delete), onPressed: () => _delete(t)),
                      );
                    },
                  );
                },
              );
            },
          ),
        )
      ]),
    );
  }
}