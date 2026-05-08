import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:status_saver/Local%20Database/LocalDatabase.dart';
import 'package:status_saver/Screens/BottomNavPages/AudioScreen.dart';
import 'package:status_saver/Screens/BottomNavPages/VideoView/VideoScreens.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Utils/Constants/AllColors.dart';
import '../../Utils/Constants/AllText.dart';
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

  @override
  void initState() {
    super.initState();
    //  sirf yahan se ek baar fire karo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StatusBloc>().add(LoadStatusEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor1.screenbackgroundColor,
        appBar: AppBar(
  titleSpacing: 0,
  backgroundColor: AppColor1.screenbackgroundColor,
  leading: IconButton(
    icon: const Icon(Icons.menu),
    onPressed: () {},
  ),
  title: Text(
    AllText.StatusSaverApp,
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
            image: AssetImage(
              "assets/images/whitecontainer.png",
            ),
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
            image: AssetImage(
              "assets/images/whitecontainer.png",
            ),
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

  /// MORE ICON
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
            image: AssetImage(
              "assets/images/whitecontainer.png",
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            AllIcons.notification,
            width: getWidth(13),
            height: getHeight(16),
          ),
        ),
      ),
    ),
  ),
],
  bottom: const TabBar(
    indicatorColor: Colors.white,
    tabs: [
      Tab(text: "Images"),
      Tab(text: "Videos"),
      Tab(text: "Audio"),
    ],
  ),
),

        //  BlocBuilder hata do — TabBarView hamesha show karo
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
    // fallback if WhatsApp not installed
    final fallbackUrl = Uri.parse(
      "https://wa.me/?text=${Uri.encodeComponent(message)}",
    );

    await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
  }
}