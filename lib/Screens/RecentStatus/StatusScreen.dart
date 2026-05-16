import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:status_saver/Local%20Database/LocalDatabase.dart';
import 'package:status_saver/Screens/BottomNavPages/AudioScreen.dart';
import 'package:status_saver/Screens/BottomNavPages/VideoView/VideoScreens.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/components/app_drawer.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:status_saver/services/notification/status_scanner_service.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/Constants/AllColors.dart';
import '../../bloc/status/status_bloc.dart';
import '../../bloc/status/status_event.dart';
import '../BottomNavPages/ImageView/ImagesScreen.dart';

class StatusScreen extends StatefulWidget {
  final bool isBusiness;

  const StatusScreen({
    super.key,
    this.isBusiness = false,
  });

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  int _newStatusCount = 0;
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();
    // SharedPreferences.getInstance().then((prefs) {
    //   prefs.remove('seen_statuses');
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatusBloc>().add(LoadStatusEvent());
      }
    });

    _checkNewStatus();

    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkNewStatus();
    });
  }
Future<void> _checkNewStatus() async {
  int newCount = 0;

  for (final path in kStatusPaths) {
    final dir = Directory(path);
    if (await dir.exists()) {
      final allFiles = await dir.list().toList();
      final fileNames = allFiles
          .map((f) => f.path)
          .where((p) {
            final ext = p.substring(p.lastIndexOf('.')).toLowerCase();
            return {'.jpg', '.jpeg', '.png', '.mp4', '.opus'}.contains(ext);
          })
          .map((p) => p.split('/').last)
          .toSet();

      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final baseline = (prefs.getStringList('baseline_statuses') ?? []).toSet();
      final seen = (prefs.getStringList('seen_statuses') ?? []).toSet();

      debugPrint("📁 TOTAL FILES: ${fileNames.length}");
      debugPrint("📌 BASELINE: ${baseline.length}");
      debugPrint("👀 SEEN: ${seen.length}");

      //  FIRST RUN
      if (baseline.isEmpty && seen.isEmpty) {
        debugPrint('⚠️ FIRST RUN - baseline set ho raha hai');
        await prefs.setStringList('baseline_statuses', fileNames.toList());
        await prefs.setStringList('seen_statuses', fileNames.toList());
        newCount = 0;
        break;
      }

      //  Naye files = jo baseline mein nahi aur seen mein bhi nahi
      final newFiles = fileNames
          .where((f) => !baseline.contains(f) && !seen.contains(f))
          .toSet();

      newCount = newFiles.length;

      debugPrint("🆕 NEW STATUS COUNT: $newCount");
      debugPrint("🆕 NEW FILES: $newFiles");

      break;
    }
  }

  if (!mounted) return;
  setState(() {
    _newStatusCount = newCount;
  });
}

//  Bell tap karo = sab seen mark ho jaaye
Future<void> _markAllSeen() async {
  final prefs = await SharedPreferences.getInstance();

  for (final path in kStatusPaths) {
    final dir = Directory(path);
    if (await dir.exists()) {
      final allFiles = await dir.list().toList();
      final fileNames = allFiles
          .map((f) => f.path)
          .where((p) {
            final ext = p.substring(p.lastIndexOf('.')).toLowerCase();
            return {'.jpg', '.jpeg', '.png', '.mp4', '.opus'}.contains(ext);
          })
          .map((p) => p.split('/').last)
          .toList();

      //  Saare current files ko seen mark karo
      await prefs.setStringList('seen_statuses', fileNames);
      await prefs.setBool('has_new_status', false);
      await prefs.setInt('new_status_count', 0);
      break;
    }
  }

  if (!mounted) return;
  setState(() {
    _newStatusCount = 0;
  });
}

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        drawer: const AppDrawer(),
        backgroundColor: AppColor1.screenbackgroundColor,
        appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: AppColor1.screenbackgroundColor,
          title: Text(
            t.statusSaver,
            style: AppColor1().customTextStyle20(),
          ),
          actions: [

            /// CHAT BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirectChatScreen(),
                    ),
                  );
                },
                child: Container(
                  width: getWidth(24),
                  height: getHeight(24),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/whitecontainer.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AllIcons.chat,
                      width: getWidth(16),
                      height: getHeight(15),
                    ),
                  ),
                ),
              ),
            ),

            /// SHARE BUTTON
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  shareToWhatsAppDirect();
                },
                child: Container(
                  width: getWidth(24),
                  height: getHeight(24),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/whitecontainer.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AllIcons.share,
                      width: getWidth(14),
                      height: getHeight(14),
                    ),
                  ),
                ),
              ),
            ),

            /// NOTIFICATION BELL — naye status ka count
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () async {
                  await _markAllSeen(); // ✅ FIXED
                },
                child: Container(
                  width: getWidth(24),
                  height: getHeight(24),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/whitecontainer.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [

                      Center(
                        child: SvgPicture.asset(
                          AllIcons.notification,
                          width: getWidth(13),
                          height: getHeight(16),
                        ),
                      ),

                      // 🔴 Count Badge
                      if (_newStatusCount > 0)
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 10,
                              minHeight: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape:BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                _newStatusCount > 99
                                    ? "99+"
                                    : _newStatusCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),

                    ],
                  ),
                ),
              ),
            ),

          ],
          bottom: TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: t.images),
              Tab(text: t.videos),
              Tab(text: t.audio),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            ImageScreen(),
            VideoScreens(),
            AudioScreen(),
          ],
        ),
      ),
    );
  }
}

void shareToWhatsAppDirect() async {
  const message =
      " Check out this Status Saver App!\n"
      "Save WhatsApp statuses easily 📥";

  final Uri url = Uri.parse(
    "whatsapp://send?text=${Uri.encodeComponent(message)}",
  );

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    final fallbackUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );
    await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
  }
}