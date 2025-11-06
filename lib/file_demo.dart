// lib/file_demo.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Import untuk JSON encoding/decoding

class FileDemoPage extends StatefulWidget {
  const FileDemoPage({super.key});

  @override
  State<FileDemoPage> createState() => _FileDemoPageState();
}

class _FileDemoPageState extends State<FileDemoPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  Map<String, dynamic>? _profileData; // Data profil yang dimuat
  String _statusMessage = 'Profil belum dimuat.';

  static const String _fileName = 'profile.json';

  // Mendapatkan path file lokal 'profile.json'
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  // >>> READ: Membaca data JSON dari file <<<
  Future<void> _readProfile() async {
    setState(() => _statusMessage = 'Membaca profil...');
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        setState(() {
          _profileData = null;
          _statusMessage = 'File profil belum ada.';
        });
        return;
      }

      final content = await file.readAsString();
      final decodedJson = jsonDecode(content) as Map<String, dynamic>;

      setState(() {
        _profileData = decodedJson;
        _statusMessage = 'Profil berhasil dimuat.';
      });
    } catch (e) {
      setState(() {
        _profileData = null;
        _statusMessage = 'Gagal memuat profil: $e';
      });
    }
  }

  // >>> CREATE/UPDATE: Menulis/Menyimpan data JSON ke file <<<
  Future<void> _saveProfile() async {
    if (_nameCtrl.text.isEmpty || _emailCtrl.text.isEmpty) {
      setState(() => _statusMessage = 'Nama dan Email tidak boleh kosong.');
      return;
    }

    setState(() => _statusMessage = 'Menyimpan profil...');
    try {
      final file = await _localFile;

      final profile = {
        'name': _nameCtrl.text,
        'email': _emailCtrl.text,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(profile); // Konversi Map ke String JSON

      await file.writeAsString(jsonString);

      _nameCtrl.clear();
      _emailCtrl.clear();
      await _readProfile(); // Muat ulang untuk menampilkan hasil simpan

    } catch (e) {
      setState(() => _statusMessage = 'Gagal menyimpan profil: $e');
    }
  }

  // >>> DELETE: Menghapus file profil <<<
  Future<void> _deleteProfile() async {
    setState(() => _statusMessage = 'Menghapus profil...');
    try {
      final file = await _localFile;
      if (await file.exists()) {
        await file.delete();
        setState(() {
          _profileData = null;
          _statusMessage = 'Profil berhasil dihapus.';
        });
      } else {
        setState(() => _statusMessage = 'Profil sudah tidak ada.');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Gagal menghapus profil: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _readProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile (File JSON)')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- FORM INPUT ---
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Nama Profil', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 20),

              // --- TOMBOL CRUD ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: ElevatedButton(onPressed: _saveProfile, child: const Text('Simpan/Update'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: _deleteProfile, child: const Text('Hapus File'))),
                  const SizedBox(width: 10),
                  Expanded(child: ElevatedButton(onPressed: _readProfile, child: const Text('Muat Ulang'))),
                ],
              ),

              const Divider(height: 40),

              // --- TAMPILAN PROFIL ---
              Text('Status: $_statusMessage', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              if (_profileData != null)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nama: ${_profileData!['name']}', style: const TextStyle(fontSize: 16)),
                        Text('Email: ${_profileData!['email']}', style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        Text('Tersimpan pada: ${_profileData!['timestamp']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                )
              else
                const Text('Tidak ada data profil yang tersimpan.', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}