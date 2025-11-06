// lib/prefs_demo.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert'; // Untuk encoding JSON

class PrefsDemoPage extends StatefulWidget {
  const PrefsDemoPage({super.key});

  @override
  State<PrefsDemoPage> createState() => _PrefsDemoPageState();
}
class _PrefsDemoPageState extends State<PrefsDemoPage> {
  final TextEditingController _controller = TextEditingController();
  String _storedText = '';
  bool _darkMode = false;

  // Tambahan untuk Tugas Latihan (Simulasi setting lain)
  String _language = 'ID';
  bool _notifications = true;

  String _exportStatus = ''; // Status pesan ekspor

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _storedText = prefs.getString('greeting') ?? '';
      _darkMode = prefs.getBool('darkMode') ?? false;
      // Muat data setting baru
      _language = prefs.getString('language') ?? 'ID';
      _notifications = prefs.getBool('notifications') ?? true;
    });
  }

  // Fungsi untuk menyimpan setting baru
  Future<void> _saveSettings(String lang, bool notify) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', lang);
    await prefs.setBool('notifications', notify);
    _loadPrefs();
  }

  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('greeting', _controller.text);
    _controller.clear();
    _loadPrefs();
  }

  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() => _darkMode = value);
  }

  // >>> FUNGSI UTAMA UNTUK EKSPOR PREFERENSI KE JSON <<<
  Future<void> _exportPrefsToJson() async {
    setState(() => _exportStatus = 'Mengekspor...');
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Ambil SEMUA data preferensi
      final Map<String, dynamic> prefsMap = {};
      prefs.getKeys().forEach((key) {
        prefsMap[key] = prefs.get(key);
      });

      // 2. Serialisasi Map menjadi String JSON
      final String jsonString = jsonEncode(prefsMap);

      // 3. Tentukan Path File (Mirip Bab 2)
      final dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/prefs_export.json');

      // 4. Tulis String JSON ke File
      await file.writeAsString(jsonString);

      setState(() => _exportStatus = 'Sukses! Tersimpan di ${file.path}');
    } catch (e) {
      setState(() => _exportStatus = 'Gagal mengekspor: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil tinggi keyboard (viewInsets.bottom)
    final double keyboardHeight = MediaQuery
        .of(context)
        .viewInsets
        .bottom;

    final theme = ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
    );

    return MaterialApp(
      theme: theme,
      home: Scaffold(
        appBar: AppBar(title: const Text('Prefs Demo')),
        // --- SingleChildScrollView di Body ---
        body: SingleChildScrollView(
          // UBAH PADDING DARI all(16) MENJADI symmetric(horizontal: 16, vertical: 8)
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- PENGATURAN MODE GELAP ---
              SwitchListTile(
                  title: const Text('Mode Gelap'),
                  value: _darkMode,
                  onChanged: _toggleDarkMode),

              // --- TEXT INPUT SALAM ---
              TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                      labelText: 'Tulis salam',
                      border: OutlineInputBorder(),
                      isDense: true)), // Coba isDense: true
              const SizedBox(height: 8), // Kurangi dari 12 ke 8
              ElevatedButton(
                  onPressed: _saveText, child: const Text('Simpan Salam')),
              const SizedBox(height: 12),
              Text('Tersimpan: ' +
                  (_storedText.isEmpty ? "(kosong)" : _storedText)),
              const Divider(height: 32),

              // --- PENGATURAN BARU: BAHASA & NOTIFIKASI ---
              Text('Pengaturan Tambahan:', style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium),
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(
                    labelText: 'Bahasa', isDense: true),
                items: ['ID', 'EN', 'JP'].map((String value) {
                  return DropdownMenuItem<String>(
                      value: value, child: Text(value));
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    _saveSettings(newValue, _notifications);
                  }
                },
              ),
              SwitchListTile(
                title: const Text('Notifikasi Aktif'),
                value: _notifications,
                onChanged: (bool value) {
                  _saveSettings(_language, value);
                },
              ),
              const Divider(height: 32),

              // --- EKSPOR JSON PREFERENSI ---
              ElevatedButton.icon(
                onPressed: _exportPrefsToJson,
                icon: const Icon(Icons.download),
                label: const Text('Ekspor Preferensi ke JSON'),
              ),
              const SizedBox(height: 8),
              Text('Status: $_exportStatus',
                  style: const TextStyle(fontSize: 12)),

              // >>> KOMPENSASI KEYBOARD <<<
              // Tambahkan SizedBox setinggi keyboard saat aktif.
              SizedBox(height: keyboardHeight > 0 ? keyboardHeight : 0),

            ],
          ),
        ),
      ),
    );
  }
}