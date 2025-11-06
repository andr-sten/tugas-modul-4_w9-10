// lib/task_api_page.dart

import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Pastikan Dio sudah diimpor
import 'task_api_model.dart'; // Import model DTO
import 'task_api_service.dart'; // Import service API

class TaskApiPage extends StatefulWidget {
  const TaskApiPage({super.key});

  @override
  State<TaskApiPage> createState() => _TaskApiPageState();
}


class _TaskApiPageState extends State<TaskApiPage> {
  // 1. Inisialisasi Service API
  final Dio _dio = Dio();
  late final TaskApiService _api;

  // 2. State untuk Data dan UI
  List<TaskDto> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Controller untuk input form (jika Anda menambahkannya)
  final _titleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inisialisasi service setelah Dio
    _api = TaskApiService(_dio);
    // Muat data pertama kali
    _loadTasks();
  }

  // Metode READ ALL (dengan penanganan error)
  // lib/task_api_page.dart - di dalam class _TaskApiPageState

// ... (variabel _tasks, _isLoading, _errorMessage)

// Metode READ ALL (dengan penanganan error dan retry)
  Future<void> _loadTasks({int maxAttempts = 3, int currentAttempt = 0}) async {
    setState(() {
      _isLoading = true;
      // PENTING: Jangan hapus _errorMessage di sini, biarkan di try/catch
      if (currentAttempt == 0) {
        _errorMessage = null; // Hapus error hanya saat upaya pertama (tombol refresh ditekan)
      }
      _tasks.clear(); // Hapus data lama saat mulai memuat
    });

    try {
      final list = await _api.getTasks();

      // SUKSES: Hapus pesan error lama jika ada
      setState(() {
        _tasks = list.toList();
        _errorMessage = null; // Hapus pesan error karena berhasil
      });
      return; // Keluar dari fungsi setelah berhasil

    } on DioException catch (e) {
      // GAGAL: Menangkap error 403, Timeout, atau lainnya.
      final isRetryable = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown;

      if (isRetryable && currentAttempt < maxAttempts) {
        // Logika Retry
        await Future.delayed(const Duration(seconds: 1));
        return _loadTasks(maxAttempts: maxAttempts, currentAttempt: currentAttempt + 1);
      }

      // Jika gagal setelah semua upaya atau jika error non-retryable (seperti 403)
      setState(() {
        final statusCode = e.response?.statusCode;
        if (statusCode == 403) {
          _errorMessage = 'Error 403 Forbidden: Akses ditolak oleh server.';
        } else {
          _errorMessage = 'Gagal memuat: ${statusCode ?? 'Jaringan Gagal'}';
        }
        _tasks.clear(); // Pastikan list kosong saat error
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Kesalahan tidak terduga.';
        _tasks.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Metode CRUD lainnya (Perlu Anda implementasikan)

  // Metode CREATE (Contoh Implementasi Sederhana)
  Future<void> _addTask() async {
    if (_titleCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final newTask = TaskDto(
        title: _titleCtrl.text,
        isCompleted: false,
      );

      // 1. Panggil API (Ini menghasilkan respons sukses 201)
      final createdTask = await _api.createTask(newTask);
      _titleCtrl.clear();

      // 2. SIMULASI LOKAL: Tambahkan task hasil respons API ke daftar lokal
      //    (Karena _loadTasks() tidak akan mengambil data baru)
      setState(() {
        // Gunakan ID dari respons API (biasanya 201)
        // Tambahkan di awal list
        _tasks.insert(0, createdTask);
      });

    } on DioException catch (e) {
      setState(() => _errorMessage = 'Gagal menambah task. ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Metode UPDATE (toggle isCompleted)
  Future<void> _toggleComplete(TaskDto task) async {
    setState(() => _isLoading = true);
    try {
      final updatedTask = TaskDto(
          id: task.id,
          title: task.title,
          description: task.description,
          isCompleted: !task.isCompleted // Toggle status
      );

      // 1. Panggil API (respons sukses 200)
      await _api.updateTask(task.id!, updatedTask);

      // 2. SIMULASI LOKAL: Ganti item lama dengan item baru di list
      setState(() {
        final index = _tasks.indexWhere((t) => t.id == task.id);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }
      });

    } on DioException catch (e) {
      setState(() => _errorMessage = 'Gagal mengubah status task. ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Metode DELETE
  Future<void> _deleteTask(int id) async {
    setState(() => _isLoading = true);
    try {
      // 1. Panggil API (Ini menghasilkan respons sukses 200)
      await _api.deleteTask(id);

      // 2. SIMULASI LOKAL: Hapus task dari list _tasks
      setState(() {
        _tasks.removeWhere((t) => t.id == id);
      });

    } on DioException catch (e) {
      setState(() => _errorMessage = 'Gagal menghapus task. ${e.message}');
    } finally {
      setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task (API)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadTasks,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bagian Form Input (Sederhana)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(labelText: 'Judul Task Baru'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _addTask, // Nonaktifkan saat loading
                  child: const Text('Tambah API'),
                ),
              ],
            ),
          ),
          const Divider(),

          // Bagian Indikator Loading
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(),
            ),

          // TAMPILKAN PESAN ERROR JIKA ADA
          if (_errorMessage != null)
            Expanded( // Gunakan Expanded agar pesan error bisa ditengah
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    // TOMBOL UNTUK MANUAL RELOAD
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : () => _loadTasks(),
                      icon: const Icon(Icons.cached),
                      label: const Text('Coba Muat Ulang'),
                    )
                  ],
                ),
              ),
            ),

          if (_tasks.isNotEmpty && _errorMessage == null)
          // Bagian Daftar Tugas
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text('ID: ${task.id ?? '-'} | Completed: ${task.isCompleted}'),
                  leading: IconButton(
                    icon: Icon(
                        task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                    onPressed: () => _toggleComplete(task),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task.id!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}