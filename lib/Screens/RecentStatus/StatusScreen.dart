import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
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
  bool _hasNewStatus = false; // Red dot state
  Timer? _statusCheckTimer;

  @override
  void initState() {
    super.initState();

    // Status bloc load karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatusBloc>().add(LoadStatusEvent());
      }
    });

    // Pehli baar check karo
    _checkNewStatus();

    // Har 5 seconds mein check karo — background se naya status aane par red dot update ho
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkNewStatus();
    });
  }

  Future<void> _checkNewStatus() async {
    final hasNew = await StatusScannerService.hasNewStatus();
    if (mounted && hasNew != _hasNewStatus) {
      setState(() {
        _hasNewStatus = hasNew;
      });
    }
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel(); // Timer band karo
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

            /// NOTIFICATION ICON — Red dot jab naya status aaye
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () async {
                  // Red dot clear karo jab user tap kare
                  await StatusScannerService.clearNewStatusFlag();
                  setState(() {
                    _hasNewStatus = false;
                  });
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

                      // Notification icon
                      Center(
                        child: SvgPicture.asset(
                          AllIcons.notification,
                          width: getWidth(13),
                          height: getHeight(16),
                        ),
                      ),

                      // 🔴 Red dot — _hasNewStatus true hone par dikhega
                      if (_hasNewStatus)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),

                    ],
                  ),
                ),
              ),
            ),

          ],
          bottom:  TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: t.images),
              Tab(text: t.videos),
              Tab(text: t.audio),
            ],
          ),
        ),

        // TabBarView hamesha show karo
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