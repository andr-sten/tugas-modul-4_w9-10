// lib/task_sqflite_page.dart
import 'package:flutter/material.dart';
import 'db_helper.dart';

class TaskSqflitePage extends StatefulWidget {
  const TaskSqflitePage({super.key});

  @override
  State<TaskSqflitePage> createState() => _TaskSqflitePageState();
}

class _TaskSqflitePageState extends State<TaskSqflitePage> {
  List<Map<String, dynamic>> _tasks = [];
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  // Fitur Baru untuk Tugas Latihan:
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int _limit = 10;
  int _offset = 0;
  bool _isLoadingMore = false;
  bool _hasMore = true; // Menunjukkan apakah ada data lagi untuk dimuat

  // Memuat semua data task
  // Ganti _load() lama dengan _loadTasks()
  Future<void> _loadTasks({bool isInitialLoad = true}) async {
    if (isInitialLoad) {
      setState(() {
        _tasks.clear();
        _offset = 0;
        _hasMore = true;
      });
    }
    if (!_hasMore || _isLoadingMore) return;

    setState(() => _isLoadingMore = true);

    final data = await DbHelper.getTasks(
      limit: _limit,
      offset: _offset,
      searchQuery: _searchCtrl.text,
    );

    setState(() {
      _tasks.addAll(data);
      _offset += data.length;
      _hasMore = data.length == _limit; // Jika data < limit, berarti sudah habis
      _isLoadingMore = false;
    });
  }

  // Fungsi dipanggil saat search bar berubah
  void _onSearch() {
    _loadTasks(isInitialLoad: true);
  }

  @override
  void initState() {
    super.initState();
    // Tambahkan listener untuk otomatis memuat saat scroll mencapai batas bawah
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels == _scrollCtrl.position.maxScrollExtent) {
        _loadTasks(isInitialLoad: false);
      }
    });
    // Tambahkan listener untuk pencarian
    _searchCtrl.addListener(_onSearch);
    _loadTasks();
  }

  // Jangan lupa buang controllers saat dispose
  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.removeListener(_onSearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  // Menambah task baru
  Future<void> _addTask() async {
    await DbHelper.insert({
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'isCompleted': 0 // 0 = false, 1 = true
    });
    _titleCtrl.clear();
    _descCtrl.clear();
    await _loadTasks(isInitialLoad: true); // Muat ulang dari awal setelah tambah
  }

  // Mengubah status isCompleted
  Future<void> _toggleComplete(Map<String, dynamic> t) async {
    final id = t['id'] as int;
    final newVal = (t['isCompleted'] as int) == 1 ? 0 : 1;
    await DbHelper.update(id, {'isCompleted': newVal});
    await _loadTasks(isInitialLoad: true); // Muat ulang dari awal setelah tambah
  }

  // Menghapus task
  Future<void> _delete(int id) async {
    await DbHelper.delete(id);
    await _loadTasks(isInitialLoad: true); // Muat ulang dari awal setelah tambah
  }


  //- Bagian build()

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task (sqflite)')),
      // Hapus resizeToAvoidBottomInset: false (biarkan default/true)

      body: Column(children: [

        // BUNGKUS BAGIAN FORM INPUT DENGAN SingleChildScrollView
        SingleChildScrollView(
          // Gunakan PrimaryScrollController untuk kasus ini,
          // dan set shrinkWrap: true.
          // Atau, gunakan Column(mainAxisSize: MainAxisSize.min)
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  // Text Field Pencarian (NEW)
                  TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Cari Judul/Deskripsi',
                        prefixIcon: Icon(Icons.search),
                        isDense: true, // Coba tambahkan isDense: true untuk menghemat ruang
                        border: OutlineInputBorder(),
                      )
                  ),
                  // Ganti const SizedBox(height: 12) menjadi:
                  const SizedBox(height: 4),

                  TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: 'Judul Task', isDense: true)), // Coba isDense: true
                  const SizedBox(height: 4),

                  TextField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: 'Deskripsi', isDense: true)), // Coba isDense: true

                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _addTask, child: const Text('Tambah')),
                ]),
          ),
        ), // AKHIR SingleChildScrollView

        const Divider(),

        // Expanded ListView tetap di bawah untuk Paging
        Expanded(
          child: ListView.builder(
            controller: _scrollCtrl,
            itemCount: _tasks.length + (_hasMore ? 1 : 0),
            itemBuilder: (_, i) {
              // ... (Logic ListView tetap sama)
              if (i == _tasks.length) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _isLoadingMore
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed: () => _loadTasks(isInitialLoad: false),
                      child: const Text('Muat Lebih Banyak'),
                    ),
                  ),
                );
              }
              final t = _tasks[i];
              final done = (t['isCompleted'] as int) == 1;
              return ListTile(
                title: Text(t['title']),
                subtitle: Text(t['description'] ?? ''),
                leading: IconButton(
                  icon: Icon(
                      done ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: () => _toggleComplete(t),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _delete(t['id'] as int),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}