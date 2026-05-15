import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/colors/app_colors.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:status_saver/services/autosaverservice/auto_saver_service.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _autoSaveEnabled = false;
  bool _makeNewStatusEnabled = false;

  final _service = AutoSaverService();
  late Box _box;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    _box = await Hive.openBox('settings');

    final saved = _box.get('auto_saver', defaultValue: false) as bool;
    setState(() => _autoSaveEnabled = saved);

    if (saved && !_service.isRunning) {
      await _service.start();
    }
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
          style: AppColor1().
          customTextStyle12().
          copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 12,
          ),
        child: Column(
          children: [
            SizedBox(height:getHeight(16)),
            // ── Container 1 ──
            _SettingsTile(
              title: t.notification,
              subtitle: t.notificationSubtitle,
              value: _notificationEnabled,
              onChanged: (val) => setState(() => _notificationEnabled = val),
              height: getHeight(70),
              width: getWidth(398),
            ),

            SizedBox(height: getHeight(16)),

            // ── Container 2 — Auto Save ──
            _SettingsTile(
              title: t.autoSave,
              subtitle: t.autoSaveSubtitle,
              value: _autoSaveEnabled,
              onChanged: _onAutoSaveToggle, 
              height: getHeight(54),
              width: getWidth(398),
            ),

            SizedBox(height: getHeight(16)),

            // ── Container 3 ──
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
        padding: const EdgeInsets.symmetric(
          horizontal: 16, 
          vertical: 14
          ),
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