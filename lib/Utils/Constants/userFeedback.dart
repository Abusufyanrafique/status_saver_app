import 'dart:io';
import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Local Database/LocalDatabase.dart';
import 'AllColors.dart';
import 'SizeConfig.dart';


// --- UI Components ---

Widget bottomButton(
  VoidCallback ontap, 
  String icon, 
  String title
  ) {
  return GestureDetector(
    onTap: ontap,
    behavior: HitTestBehavior.opaque,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Agar aap getHeight/getWidth use kar rahe hain to wahi rehne dein
        SvgPicture.asset(icon, height: 20, width: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w400, 
            fontSize: 16, 
            color: Colors.black
            ),
        )
      ],
    ),
  );
}

// --- Sharing Logic ---

// 1. General Share (System Tray) - Image/Video dono ke liye
Future<void> shareStatus(String path) async {
  if (path.isNotEmpty) {
    await Share.shareXFiles([XFile(path)]);
  }
}
Future<void> saveToHive(String path, String type) async {
  var box = Hive.box<SavedItem>('saved_items');

  // Check karein ke kahin ye file pehle hi save to nahi?
  bool exists = box.values.any((item) => item.path == path);

  if (!exists) {
    await box.add(SavedItem(
      path: path,
      type: type,
      dateTime: DateTime.now(),
    ));
  }
}

Widget tabbutton(String title) {
  return Container(
    height: getHeight(36),
    width: getWidth(123),
    decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: Colors.white,width: 1)
    ),
    alignment: Alignment.center,
    child: Text(title,style: AppColor1().customTextStyleBold16(),),
  );
}






Future<void> openWhatsapp() async {
  var num = "+923116326930";

  final Uri androidUrl = Uri.parse("whatsapp://send?phone=$num&text=hello");
  final Uri iosUrl = Uri.parse("https://wa.me/$num?text=${Uri.encodeComponent("hello")}");

  if (Platform.isIOS) {
    if (await canLaunchUrl(iosUrl)) {
      await launchUrl(iosUrl);
    } else {
      print("WhatsApp not installed");
    }
  } else {
    if (await canLaunchUrl(androidUrl)) {
      await launchUrl(androidUrl);
    } else {
      print("WhatsApp not installed");
    }
  }
}

void showAppSnackBar({
  required BuildContext context,
  required String title,
  required String message,
  required ContentType contentType,
}) {
  final snackBar = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    margin: const EdgeInsets.all(16),
    padding: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    duration: const Duration(seconds: 3),
    content: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
        inMaterialBanner: false,
      ),
    ),
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(snackBar);
}



