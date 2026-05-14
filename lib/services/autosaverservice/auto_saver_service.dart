import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
//  AUTO SAVER SERVICE
//  Ye service WhatsApp statuses ko automatically monitor karke
//  save karti hai jab bhi switch ON ho.
// ─────────────────────────────────────────────────────────────

class AutoSaverService {
  static const String _prefKey = 'auto_saver_enabled';

  // WhatsApp status folder paths (Android)
  static const List<String> _statusPaths = [
    '/storage/emulated/0/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses',
    '/storage/emulated/0/WhatsApp Business/Media/.Statuses',
  ];

  Timer? _timer;
  bool _isRunning = false;
  final Set<String> _savedFiles = {};

  // Singleton pattern
  static final AutoSaverService _instance = AutoSaverService._internal();
  factory AutoSaverService() => _instance;
  AutoSaverService._internal();

  // ── Preference helpers ──────────────────────────────────────

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  Future<void> _setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, value);
  }

  // ── Start / Stop ────────────────────────────────────────────

  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;
    await _setEnabled(true);

    debugPrint('[AutoSaver] Started — checking every 30 seconds');

    // Pehli dafa foran check karo
    await _checkAndSave();

    // Phir har 30 second baad check karo
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      await _checkAndSave();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _setEnabled(false);
    debugPrint('[AutoSaver] Stopped');
  }

  bool get isRunning => _isRunning;

  // ── Core Logic ──────────────────────────────────────────────

  Future<void> _checkAndSave() async {
    final saveDir = await _getSaveDirectory();
    if (saveDir == null) return;

    for (final path in _statusPaths) {
      final dir = Directory(path);
      if (!await dir.exists()) continue;

      final files = dir.listSync().whereType<File>().toList();

      for (final file in files) {
        final name = file.uri.pathSegments.last;

        // Hidden files skip karo
        if (name.startsWith('.')) continue;

        // Pehle se saved files skip karo
        if (_savedFiles.contains(file.path)) continue;

        // Sirf image aur video save karo
        final ext = name.split('.').last.toLowerCase();
        if (!['jpg', 'jpeg', 'png', 'mp4', 'gif'].contains(ext)) continue;

        await _saveFile(file, saveDir, name);
      }
    }
  }

  Future<void> _saveFile(File source, Directory destDir, String name) async {
    try {
      final destPath = '${destDir.path}/$name';
      final destFile = File(destPath);

      // Agar pehle se exist karta hai to skip
      if (await destFile.exists()) {
        _savedFiles.add(source.path);
        return;
      }

      await source.copy(destPath);
      _savedFiles.add(source.path);
      debugPrint('[AutoSaver] Saved: $name');
    } catch (e) {
      debugPrint('[AutoSaver] Error saving $name: $e');
    }
  }

  Future<Directory?> _getSaveDirectory() async {
    try {
      final base = await getExternalStorageDirectory();
      if (base == null) return null;

      final saveDir = Directory('${base.path}/StatusSaver/AutoSaved');
      if (!await saveDir.exists()) {
        await saveDir.create(recursive: true);
      }
      return saveDir;
    } catch (e) {
      debugPrint('[AutoSaver] Could not get save directory: $e');
      return null;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  AUTO SAVER SWITCH WIDGET
//  Is widget ko apni kisi bhi screen mein add karo.
//  Sirf yahi import karo aur <AutoSaverSwitch /> laga do.
// ─────────────────────────────────────────────────────────────

class AutoSaverSwitch extends StatefulWidget {
  const AutoSaverSwitch({super.key});

  @override
  State<AutoSaverSwitch> createState() => _AutoSaverSwitchState();
}

class _AutoSaverSwitchState extends State<AutoSaverSwitch>
    with SingleTickerProviderStateMixin {
  final _service = AutoSaverService();
  bool _enabled = false;
  bool _loading = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();

    // Pulse animation jab auto saver ON ho
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await _service.isEnabled();
    if (enabled && !_service.isRunning) {
      await _service.start();
    }
    if (mounted) {
      setState(() {
        _enabled = enabled;
        _loading = false;
      });
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);

    if (value) {
      await _service.start();
      _showSnack('Auto Save ON kar diya ✅ Statuses automatically save honge!');
    } else {
      _service.stop();
      _showSnack('Auto Save band kar diya ⏸');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'sans-serif')),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const SizedBox(
        height: 80,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _enabled
              ? [const Color(0xFF00C853), const Color(0xFF69F0AE)]
              : [const Color(0xFF37474F), const Color(0xFF546E7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _enabled
                ? const Color(0xFF00C853).withOpacity(0.4)
                : Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Pulsing icon
            AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, child) => Transform.scale(
                scale: _enabled ? _pulseAnim.value : 1.0,
                child: child,
              ),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _enabled ? Icons.save_alt_rounded : Icons.save_outlined,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _enabled
                        ? 'Statuses automatically save ho rahe hain'
                        : 'Band hai — switch ON karo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),

            // Switch
            Transform.scale(
              scale: 1.1,
              child: Switch.adaptive(
                value: _enabled,
                onChanged: _toggle,
                activeColor: Colors.white,
                activeTrackColor: Colors.white.withOpacity(0.4),
                inactiveThumbColor: Colors.white70,
                inactiveTrackColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}