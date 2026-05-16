import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/colors/app_colors.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:status_saver/services/autosaverservice/auto_saver_service.dart';
import 'package:status_saver/services/notification/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = false;
  bool _autoSaveEnabled = false;
  bool _makeNewStatusEnabled = false;

  final _service = AutoSaverService();
  late Box _box;

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotificationState();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox('settings');
    final saved = _box.get('auto_saver', defaultValue: false) as bool;
    setState(() => _autoSaveEnabled = saved);
    if (saved && !_service.isRunning) {
      await _service.start();
    }
  }

  // ✅ Notification state load karo — permission + user preference dono check
  Future<void> _loadNotificationState() async {
    final enabled = await NotificationService.isNotificationEnabled();
    final granted = await NotificationService.isPermissionGranted();
    setState(() {
      _notificationEnabled = enabled && granted;
    });
  }

  // ✅ Notification toggle — permission maango agar nahi mili
  Future<void> _onNotificationToggle(bool val) async {
    if (val) {
      // User ne ON kiya — permission check karo
      final granted = await NotificationService.isPermissionGranted();

      if (!granted) {
        // Permission nahi hai — request karo
        final result = await NotificationService.requestPermission();

        if (!result) {
          // Permission denied — dialog dikhao settings open karne ka
          if (!mounted) return;
          _showPermissionDialog();
          return;
        }
      }

      // Permission mil gayi — enable karo
      await NotificationService.setNotificationEnabled(true);
      setState(() => _notificationEnabled = true);
    } else {
      // User ne OFF kiya
      await NotificationService.setNotificationEnabled(false);
      setState(() => _notificationEnabled = false);
    }
  }

  // ✅ Permission permanently denied ho toh settings open karo
  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notification Permission'),
        content: const Text(
          'Please allow notification permission from app settings to receive status alerts.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings(); // permission_handler se
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _onAutoSaveToggle(bool val) async {
    setState(() => _autoSaveEnabled = val);
    await _box.put('auto_saver', val);
    if (val) {
      await _service.start();
    } else {
      _service.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFE3EAF2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3EAF2),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            AllIcons.backArrow,
            width: getWidth(22),
            height: getHeight(22),
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          t.setting,
          style: AppColor1().customTextStyle12().copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            SizedBox(height: getHeight(16)),

            // ── Notification Toggle ──
            _SettingsTile(
              title: t.notification,
              subtitle: t.notificationSubtitle,
              value: _notificationEnabled,
              onChanged: _onNotificationToggle, // ✅ permission logic
              height: getHeight(70),
              width: getWidth(398),
            ),

            SizedBox(height: getHeight(16)),

            // ── Auto Save Toggle ──
            _SettingsTile(
              title: t.autoSave,
              subtitle: t.autoSaveSubtitle,
              value: _autoSaveEnabled,
              onChanged: _onAutoSaveToggle,
              height: getHeight(54),
              width: getWidth(398),
            ),

            SizedBox(height: getHeight(16)),

            // ── Make New Status Toggle ──
            _SettingsTile(
              title: t.makeANewStatus,
              subtitle: t.makeNewStatusSubtitle,
              value: _makeNewStatusEnabled,
              onChanged: (val) => setState(() => _makeNewStatusEnabled = val),
              height: getHeight(54),
              width: getWidth(398),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final double height;
  final double width;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.settingtilecolor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 0.5),
            blurRadius: 1,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppColor1().customTextStyleBold12()),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppColor1()
                        .customTextStyleRegular10()
                        .copyWith(fontSize: getFont(12)),
                  ),
                ],
              ),
            ),
            Transform.scale(
              scale: 0.6,
              child: Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: Colors.black,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.black12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}