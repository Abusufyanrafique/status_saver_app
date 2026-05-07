
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/AllText.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';
import '../../../Utils/Constants/file_service.dart';
import '../../../Utils/Constants/userFeedback.dart';


class ImageView extends StatelessWidget {
  final String imagePath;
  final bool isFromSavedScreen;

  const ImageView({
    super.key,
    required this.imagePath,
    this.isFromSavedScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AllText.Status_Saver, style: AppColor1().customTextStyle20()),
        centerTitle: true,
      ),
      bottomNavigationBar: mediaBottomBar(
        context: context,
        imagePath: imagePath,
        isFromSavedScreen: isFromSavedScreen,
        onShare: () => shareStatus(imagePath),
        onRepost: () => repostStatus(context, imagePath),
        onSave: () async {
        print(" onSave TRIGGERED");
        await saveMedia(context, imagePath, isVideo: false);
        },
        onDelete: () async {
          await deleteItem(context, imagePath, deleteFromDisk: true);
          if (context.mounted) Navigator.pop(context);
        },
        bottomButton: bottomButton,

        repostIcon: AllIcons.repost,
        shareIcon: AllIcons.share,
        saveIcon: AllIcons.save,
        deleteIcon: AllIcons.delete,

        repostText: AllText.Repost,
        shareText: AllText.Share,
        saveText: AllText.Save,
        deleteText: AllText.delete,
      ),

      body: Center(
        child: InteractiveViewer(
          child: File(imagePath).existsSync()
              ? Image.file(
            File(imagePath),
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          )
              : const Center(child: Text("File not found ❌")),
        ),
      ),
    );
  }
}
