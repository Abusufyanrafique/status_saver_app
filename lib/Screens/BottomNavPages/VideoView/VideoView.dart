

import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:video_player/video_player.dart';
import '../../../Local Database/LocalDatabase.dart';
import '../../../Utils/Constants/AllText.dart';
import '../../../Utils/Constants/file_service.dart';
import '../../../Utils/Constants/userFeedback.dart';

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

  Future<void> _initializePlayer(String path) async {
    setState(() => _isInitializing = true);

    final file = File(path);
    if (!await file.exists()) {
      debugPrint("File not found ❌");
      setState(() => _isInitializing = false);
      return;
    }

    // Dispose old controllers before creating new ones
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

  void _playNext() {
    if (_currentIndex < widget.allVideos.length - 1) {
      setState(() => _currentIndex++);
      _initializePlayer(widget.allVideos[_currentIndex]);
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
      _initializePlayer(widget.allVideos[_currentIndex]);
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
    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor1.screenbackgroundColor,
        title: Text("Videos", style: AppColor1().customTextStyleBold16()),

      ),
      body: Column(
        children: [
          // Video Player Area
          Expanded(
            child: Center(
              child: _isInitializing
                  ? const CircularProgressIndicator(color: Colors.black)
                  : _chewieController != null
                  ? Chewie(controller: _chewieController!)
                  : const Icon(Icons.error, color: Colors.red, size: 60),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Repost
                bottomButton(
                      () {}, // repost logic here
                  AllIcons.repost,
                  AllText.Repost,
                ),

                // Share
                bottomButton(
                      () => shareStatus(widget.allVideos[_currentIndex]),
                  AllIcons.share,
                  AllText.Share,
                ),

                // Save OR Delete
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
                  widget.isFromSavedScreen ? AllIcons.delete : AllIcons.save,
                  widget.isFromSavedScreen ? AllText.delete : AllText.Save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
