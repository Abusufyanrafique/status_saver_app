import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/Utils/Constants/SizeConfig.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';
import 'package:video_player/video_player.dart';

import '../../../Local Database/LocalDatabase.dart' hide shareStatus;
import '../../../Utils/Constants/file_service.dart' hide saveMedia;
import '../../../Utils/Constants/userFeedback.dart' hide bottomButton;

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final int currentIndex;
  final List<String> allVideos;
  final bool isFromSavedScreen;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.currentIndex,
    required this.allVideos,
    this.isFromSavedScreen = false,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  late int _currentIndex;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex;
    _initializePlayer(widget.allVideos[_currentIndex]);
  }

  // ================= INIT PLAYER =================
  Future<void> _initializePlayer(String path) async {
    setState(() => _isInitializing = true);

    if (_currentIndex < 0 || _currentIndex >= widget.allVideos.length) return;

    final file = File(path);
    if (!await file.exists()) {
      setState(() => _isInitializing = false);
      return;
    }

    _chewieController?.dispose();
    _videoPlayerController?.dispose();

    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
    );

    setState(() => _isInitializing = false);
  }

  // ================= NEXT =================
  void _playNext() {
    if (_currentIndex >= widget.allVideos.length - 1) return;

    setState(() {
      _currentIndex++;
    });

    _initializePlayer(widget.allVideos[_currentIndex]);
  }

  // ================= PREVIOUS =================
  void _playPrevious() {
    if (_currentIndex <= 0) return;

    setState(() {
      _currentIndex--;
    });

    _initializePlayer(widget.allVideos[_currentIndex]);
  }

  // ================= DELETE =================
  Future<void> _deleteVideo() async {
    try {
      final box = Hive.box<SavedItem>('saved_items');
      final String currentPath = widget.allVideos[_currentIndex];

      await deleteItem(context, currentPath, deleteFromDisk: true);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,

      appBar: AppBar(
        backgroundColor: const Color(0xFFE3EAF2),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
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

          // ================= VIDEO AREA =================
          Expanded(
            child: Stack(
              children: [

                Center(
                  child: _isInitializing
                      ? const CircularProgressIndicator(color: Colors.black)
                      : _chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : const Icon(Icons.error, color: Colors.red, size: 60),
                ),

                // ================= LEFT BUTTON =================
                Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: _playNext,
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

                // ================= RIGHT BUTTON =================
                Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: _playPrevious,
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
              ],
            ),
          ),

          // ================= BOTTOM BAR =================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                bottomButton(
                  () {
                    shareStatus(widget.allVideos[_currentIndex]);
                  },
                  AllIcons.repost,
                  t.repost,
                ),

                bottomButton(
                  () => shareStatus(widget.allVideos[_currentIndex]),
                  AllIcons.share,
                  t.share,
                ),

                bottomButton(
                  () {
                    if (widget.isFromSavedScreen) {
                      _deleteVideo();
                    } else {
                      saveMedia(
                        context,
                        widget.allVideos[_currentIndex],
                        isVideo: true,
                      );
                    }
                  },
                  widget.isFromSavedScreen
                      ? AllIcons.delete
                      : AllIcons.save,
                  widget.isFromSavedScreen
                      ? t.delete
                      : t.save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}