import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:status_saver/Local%20Database/LocalDatabase.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/AllText.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';

class ImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final bool isFromSavedScreen;

  const ImageView({
    super.key,
    required this.images,
    required this.initialIndex,
    this.isFromSavedScreen = true,
  });

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  late PageController _controller;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;

    _controller = PageController(
      initialPage: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (currentIndex < widget.images.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previous() {
    if (currentIndex > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
      final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFE3EAF2),

      appBar: AppBar(
        backgroundColor: const Color(0xFFE3EAF2),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: SvgPicture.asset(
            AllIcons.backArrow,
            width: 24,
            height: 24,
          ),
        ),
        title: Text(
          t.statusSaver,
          style: AppColor1().customTextStyleBold16(),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [

          // ── IMAGE SWIPE VIEW ──
          Expanded(
            child: Stack(
              children: [

                PageView.builder(
                  controller: _controller,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Center(
                      child: InteractiveViewer(
                        child: Image.file(
                          File(widget.images[index]),
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  },
                ),

                // ⬅ LEFT BUTTON
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: _previous,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/images/audio_forward_white_con.png",
                            width: getWidth(30),
                            height: getHeight(30),
                          ),
                          SvgPicture.asset(
                            "assets/icons/white_back_icon.svg",
                            width: getWidth(9),
                            height: getHeight(16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ➡ RIGHT BUTTON
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _next,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.asset(
                            "assets/images/audio_forward_white_con.png",
                            width: getWidth(30),
                            height: getHeight(30),
                          ),
                          SvgPicture.asset(
                            "assets/icons/move_forward_icon.svg",
                            width: getWidth(9),
                            height: getHeight(16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── BOTTOM BAR ──
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 16, 
              horizontal: 20
              ),
            decoration: const BoxDecoration(
              color: Colors.white
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                bottomButton(
                  () {
                    shareStatus(widget.images[currentIndex]);
                  },
                  AllIcons.repost,
                  t.repost,
                ),

                bottomButton(
                  () => shareStatus(widget.images[currentIndex]),
                  AllIcons.share,
                  t.share,
                ),

                bottomButton(
                  () {
                    if (widget.isFromSavedScreen) {
                      _deleteImage();
                    } else {
                      saveMedia(
                        context,
                        widget.images[currentIndex],
                        isVideo: false,
                      );
                    }
                  },
                  widget.isFromSavedScreen ? AllIcons.delete : AllIcons.save,
                  widget.isFromSavedScreen ? t.delete : t.save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Image",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final path = widget.images[currentIndex];
      final file = File(path);
      if (await file.exists()) await file.delete();

      final box = Hive.box<SavedItem>('saved_items');
      final item = box.values.firstWhere(
        (e) => e.path == path,
        orElse: () => throw Exception("Not found"),
      );
      await item.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Image deleted successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }
}