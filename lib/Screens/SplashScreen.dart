import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:status_saver/Screens/HomeScreen/HomeScreen.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/colors/app_colors.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/config/style/text_style.dart';
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:status_saver/services/splash/splash_services.dart';

class SplashyScreen extends StatefulWidget {
  const SplashyScreen({super.key});

  @override
  State<SplashyScreen> createState() => _SplashyScreenState();
}

class _SplashyScreenState extends State<SplashyScreen> {
  final SplashServices services = SplashServices();

  @override
  void initState() {
    super.initState();
    navigate();
  }

  void navigate() async {
    await services.waitForSplash();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundcolor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Image(
                image: AssetImage(AppImages.statussaverlogo),
                width: getWidth(343),
                height: getHeight(229),
              ),
            ),

            SizedBox(height: getHeight(12)),

            Text(
              t.appName,
              style: kSize20TextColorNosiferRegular,
            ),
          ],
        ),
      ),
    );
  }
}