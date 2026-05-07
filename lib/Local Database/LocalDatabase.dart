import 'package:flutter/material.dart';
import 'dart:io';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:status_saver/Utils/Constants/AllText.dart';
import 'package:status_saver/bloc/status/status_bloc.dart';
import 'package:status_saver/bloc/status/status_event.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Screens/BottomNavPages/ImageView/ImageView.dart';
import '../Screens/BottomNavPages/VideoView/VideoView.dart';
import '../Utils/Constants/AllColors.dart';
import '../Utils/Constants/SizeConfig.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../Utils/Constants/userFeedback.dart';
import 'package:path/path.dart';
part 'LocalDatabase.g.dart';




Future<String> getAppFolderPath() async {
  final dir = await getExternalStorageDirectory();
  final path = "${dir!.path}/MySavedStatus";

  final folder = Directory(path);

  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  return path;
}

Future<String?> saveFilePermanently(String originalPath) async {
  try {
    final folderPath = await getAppFolderPath();
    final fileName = basename(originalPath);
    final newPath = "$folderPath/$fileName";

    final newFile = File(newPath);

    if (await newFile.exists()) {
      return newPath; // already saved
    }

    await newFile.writeAsBytes(
      await File(originalPath).readAsBytes(),
    );

    return newPath;
  } catch (e) {
    print("Error: $e");
    return null;
  }
}
@HiveType(typeId: 0)
class SavedItem extends HiveObject {
  @HiveField(0)
  final String path;

  @HiveField(1)
  final String type; // 'image' ya 'video'

  @HiveField(2)
  final DateTime dateTime;

  SavedItem({
    required this.path, 
    required this.type, 
    required this.dateTime
    });
}
class LocalDatabase extends StatelessWidget {
  const LocalDatabase({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor1.screenbackgroundColor,
        appBar: AppBar(
          title: Text(
            "Saved Statuses",
            style: AppColor1().customTextStyleBold16(),
          ),
          backgroundColor: AppColor1.screenbackgroundColor,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(child: tabbutton("Images")),
              Tab(child: tabbutton("Videos")),
              Tab(child: tabbutton("Audio")),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaGridScreen(mediaType: 'image', context: context,),
             MediaGridScreen(mediaType: 'video', context: context,),
             MediaGridScreen(mediaType: 'audio', context: context,),
          ],
        ),
      ),
    );
  }
}
class MediaGridScreen extends StatefulWidget {
  final String mediaType;
  final BuildContext context;

  const MediaGridScreen({super.key, required this.mediaType, required this.context});

  @override
  State<MediaGridScreen> createState() => _MediaGridScreenState();
}
class _MediaGridScreenState extends State<MediaGridScreen> {
  // Tracks selected item paths
  final Set<String> _selectedPaths = {};
  bool get _isSelectionMode => _selectedPaths.isNotEmpty;
  // Long press → enter selection mode and select item
  void _onLongPress(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  // Tap → toggle if in selection mode, else navigate
  void _onTap(
    String path, 
    SavedItem item, 
    int index, 
    List<SavedItem> allItems
    ) {
    if (_isSelectionMode) {
      setState(() {
        if (_selectedPaths.contains(path)) {
          _selectedPaths.remove(path);
        } else {
          _selectedPaths.add(path);
        }
      });
    } else {
      _navigateToPlayer(item, index, allItems);
    }
  }

  // Select all / deselect all
  void _selectAll(List<SavedItem> items) {
    setState(() {
      if (_selectedPaths.length == items.length) {
        _selectedPaths.clear();
      } else {
        _selectedPaths.addAll(items.map((e) => e.path));
      }
    });
  }

  void _clearSelection() {
    setState(() => _selectedPaths.clear());
  }



  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return ValueListenableBuilder(
      valueListenable: Hive.box<SavedItem>('saved_items').listenable(),
      builder: (context, Box<SavedItem> box, _) {
        final filteredItems = box.values
            .where((item) => item.type == widget.mediaType)
            .toList()
            .reversed
            .toList();

        if (filteredItems.isEmpty) {
          return Center(
            child: Text(
              "No ${widget.mediaType} saved yet!",
              style: const TextStyle(
                color: Colors.grey
                ),
            ),
          );
        }

        return Column(
          children: [
            // ── Action bar — only visible in selection mode ──
            if (_isSelectionMode)
              Container(
                color: Colors.white10,
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    // Select All circle
                    GestureDetector(
                      onTap: () => _selectAll(filteredItems),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedPaths.length == filteredItems.length
                              ? Colors.white
                              : Colors.transparent,
                          border: Border.all(
                            color: Colors.white, width: 2
                            ),
                        ),
                        child: _selectedPaths.length == filteredItems.length
                            ? const Icon(Icons.check,
                            size: 16, color: Colors.black)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                     Text(
                      "All",
                      style: AppColor1().customTextStyle12(
                        color: AppColor1.textColor
                        )
                    ),
                    const Spacer(),
                    Text(
                      "${_selectedPaths.length} selected",
                      style:  AppColor1().customTextStyle12(
                        color: AppColor1.textColor
                        )
                    ),
                    const SizedBox(width: 4),
                    // Delete button
                    IconButton(
                      icon: const Icon(
                        Icons.delete, 
                        color: Colors.red
                        ),
                      onPressed: _deleteSelected,
                    ),
                    // Cancel selection
                    IconButton(
                      icon: const Icon(
                        Icons.close, 
                        color: Colors.black
                        ),
                      onPressed: _clearSelection,
                    ),
                  ],
                ),
              ),

            // ── Grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisExtent: getHeight(175),
                  mainAxisSpacing: 8,
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final isSelected = _selectedPaths.contains(item.path);

                  return GestureDetector(
                    onLongPress: () => _onLongPress(item.path),
                    onTap: () =>
                        _onTap(item.path, item, index, filteredItems),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Thumbnail
                          _buildThumbnail(item),

                          // Dark overlay when selected
                          if (isSelected)
                            Container(color: Colors.black45),

                          // Play/audio icon in normal mode
                          if (item.type != 'image' && !isSelected)
                            const Center(
                              child: Icon(
                                Icons.play_circle_fill,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),

                          // Audio icon
                          if (item.type == 'audio' && !isSelected)
                            const Center(
                              child: Icon(
                                Icons.audiotrack,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),

                          // Selection circle — top right corner
                          if (_isSelectionMode)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check,
                                    size: 14, color: Colors.black)
                                    : null,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnail(SavedItem item) {
    final file = File(item.path);
    if (item.type == 'image' && file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return Container(
      color: Colors.black87,
      child: Center(
        child: Icon(
          item.type == 'video' ? Icons.videocam : Icons.audiotrack,
          color: Colors.white38,
          size: 40,
        ),
      ),
    );
  }


  Future<void> _deleteSelected() async {
    final bool? confirmed = await showDialog<bool>(
      context: widget.context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Delete Files",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "Are you sure you want to delete ${_selectedPaths.length} item(s)? This cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              "Cancel", 
              style: TextStyle(color: Colors.grey
              )),
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

    // Delete each selected item from disk + Hive
    final box = Hive.box<SavedItem>('saved_items');
    for (final path in _selectedPaths.toList()) {
      try {
        final file = File(path);
        if (await file.exists()) await file.delete();

        final item = box.values.firstWhere((e) => e.path == path);
        await item.delete();
      } catch (e) {
        debugPrint("Delete error for $path: $e");
      }
    }

    if (mounted) {
      showAppSnackBar(
        context: widget.context,
        title: "Deleted",
        message: "Successfully deleted ✅",
        contentType: ContentType.success,
      );
      setState(() => _selectedPaths.clear());
    }
  }

  void _navigateToPlayer(
    SavedItem item, 
    int index, 
    List<SavedItem> allItems,
    ) {
    if (item.type == 'image') {
      Navigator.push(
        widget.context,
        MaterialPageRoute(
          builder: (_) => ImageView(
            imagePath: item.path,
            isFromSavedScreen: true,
          ),
        ),
      );
    } else if (item.type == 'video') {
      Navigator.push(
        widget.context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(
            videoPath: item.path,
            currentIndex: index,
            allVideos: allItems.map((e) => e.path).toList(),
            isFromSavedScreen: true,
          ),
        ),
      );
    } else if (item.type == 'audio') {
      Navigator.push(
        widget.context,
        MaterialPageRoute(
          builder: (_) => AudioPlayerScreen(
            audioPath: item.path,
            //isFromSavedScreen: true,
          ),
        ),
      );
    }
  }

}
//=================================AudioView====================

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;

  static const List<double> _waveHeights = [
    6, 8, 12, 18, 24, 20, 14, 10, 16, 22,
    28, 24, 18, 12, 8, 14, 20, 26, 30, 26,
    20, 16, 10, 14, 18, 24, 28, 22, 16, 12,
    8, 10, 16, 22, 26, 20, 14, 10, 6, 8,
    12, 18, 24, 28, 22, 16, 10, 8, 12, 18,
  ];

  const AudioPlayerScreen({required this.audioPath, super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  int _playedBars = 0;
  Duration _totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();

    _player.onDurationChanged.listen((duration) {
      setState(() => _totalDuration = duration);
    });

    _player.onPositionChanged.listen((position) {
      if (_totalDuration.inMilliseconds == 0) return;

      final progress =
          position.inMilliseconds / _totalDuration.inMilliseconds;

      final bars = (progress * AudioPlayerScreen._waveHeights.length)
          .clamp(0, AudioPlayerScreen._waveHeights.length)
          .toInt();

      if (mounted) setState(() => _playedBars = bars);
    });

    _player.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _playedBars = 0;
        });
      }
    });

    _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() => _isPlaying = s == PlayerState.playing);
      }
    });

    _playAudio();
  }

  void _playAudio() async {
    await _player.play(DeviceFileSource(widget.audioPath));
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
    "Status Saver",
    style: AppColor1().customTextStyleBold16(),
  ),
  centerTitle: true,
),

      ///  FIXED BODY
      body: Column(
        children: [

          ///  AUDIO PLAYER CENTER
          Expanded(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [

                    ///  PLAY / PAUSE
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 27,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    ///  WAVE BARS
                    Expanded(
                      child: Row(
                        children: List.generate(
                          AudioPlayerScreen._waveHeights.length,
                          (i) {
                            final isPlayed = i < _playedBars;

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 1.6,
                              height: AudioPlayerScreen._waveHeights[i],
                              decoration: BoxDecoration(
                                color: isPlayed
                                    ? Colors.black
                                    : const Color(0xFFE3EAF2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          ///  BOTTOM BUTTONS (SAME AS VIDEO)
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

                /// REPOST
                bottomButton(
                  () => shareStatus(widget.audioPath),
                  "assets/icons/repost.svg",
                  "Repost",
                ),

                /// SHARE
                bottomButton(
               () => shareStatus(widget.audioPath),
               "assets/icons/share.svg",
                "Share",
                 ),

                /// SAVE
                bottomButton(
            () {
    saveMedia(
      context,
      widget.audioPath,
      isVideo: false,
    );
    if (context.mounted) {
  context.read<StatusBloc>().add(LoadStatusEvent());
}
  },
  "assets/icons/save.svg",
  "Save",
),
              ],
            ),
          ),
        ],
      ),
    );
  }
         //++++++++++++==== audio saver function================++++++++++++

///================ SAVE MEDIA =================
Future<void> saveMedia(
  BuildContext context,
  String sourcePath, {
  required bool isVideo,
}) async {

  bool hasPermission = await requestPermission();

  if (!hasPermission) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Storage permission denied")),
    );
    return;
  }

  final file = File(sourcePath);

  if (!file.existsSync()) {
    print("File not found");
    return;
  }

  try {
    final dir = Directory("/storage/emulated/0/Download/StatusSaver");

    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final fileName = sourcePath.split('/').last;

    final newFile = await file.copy("${dir.path}/$fileName");

    print("SAVED AT: ${newFile.path}");

    try {
      await MediaScanner.loadMedia(path: newFile.path);
    } catch (scanError) {
      print("Media scan skipped: $scanError");
    }

    /// ================= HIVE FIX ADDED =================
    final box = Hive.box<SavedItem>('saved_items');

    await box.add(
      SavedItem(
        path: newFile.path,
        type: _getMediaType(newFile.path), //  FIXED HERE
        dateTime: DateTime.now(),
      ),
    );
    /// ==================================================

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFE3EAF2),
                  Color(0xFFC9D6FF),
                  Color(0xFFA1C4FD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Media Saved Successfully",
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
      );
    }

  } catch (e) {
    print("SAVE ERROR: $e");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Save failed: $e")),
      );
    }
  }
}

///================ PERMISSION =================
Future<bool> requestPermission() async {

  if (Platform.isAndroid) {

    /// Android 13+
    if (await Permission.photos.isGranted ||
        await Permission.videos.isGranted ||
        await Permission.audio.isGranted) {

      return true;
    }

    final photos = await Permission.photos.request();
    final videos = await Permission.videos.request();
    final audio = await Permission.audio.request();

    return photos.isGranted ||
        videos.isGranted ||
        audio.isGranted;
  }

  return true;
}
  //===========================audio share function======================

                          void shareStatus(String path) async {
                          try {
                          await Share.shareXFiles([XFile(path)], text: "Check this audio");
                           } catch (e) {
                             print("Share error: $e");
                           }
                           }



  ///  Bottom Button Widget (Reusable)
 Widget bottomButton(
  VoidCallback onTap,
  String imagePath,
  String text,
) {
  return GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        
        SvgPicture.asset(
          imagePath,
          width: 18,
          height: 18,
        ),

        const SizedBox(width: 6),

        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
}



class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}
class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String fullPhoneNumber = "";

  Future<void> _launchWhatsApp() async {
    if (fullPhoneNumber.isEmpty) {
      // SnackBar ya error message dikhayen
      return;
    }

    final String message = _messageController.text.trim();

    final String cleanNumber = fullPhoneNumber.replaceAll('+', '');

    final String url = "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}";
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor1.screenbackgroundColor,
        title:  Text("Direct Chat",
        style: AppColor1().customTextStyleBold16(
          fontWeight: FontWeight(500)
          ),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 150
          ),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Whatsapp Web", 
                  style:AppColor1().customTextStyleBold16(
                    fontWeight: FontWeight(500)
                    )),
                SizedBox(height: getHeight(29)),
               Text(
               AllText.direclyMessage,
              style: AppColor1()
            .customTextStyleBold16(fontWeight: FontWeight.w400)
            .copyWith(
            color: Color(0xFF7C7777),
            fontSize: 16,
            height: 1.3,       
             ),
             textAlign: TextAlign.center,
             ),
                const SizedBox(height: 49),
                IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: '3194160084',
                    hintStyle: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000000)
                    ),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),

                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),

                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),

                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 15
                      ),
                  ),
                  initialCountryCode: 'PK',
                  onChanged: (phone) {
                    fullPhoneNumber = phone.completeNumber;
                  },

                  dropdownIconPosition: IconPosition.trailing,
                  flagsButtonPadding: const EdgeInsets.only(left: 8),

                   dropdownDecoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.only(
                   topLeft: Radius.circular(8),
                   bottomLeft: Radius.circular(8),
                   topRight: Radius.circular(8),
                   bottomRight: Radius.circular(8),
                   ),
                   
                  ),
                  
                  flagsButtonMargin: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3
                    ),
                ),

                SizedBox(height: getHeight(15)),

  Container(
  height: 138,
  width: double.infinity,
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: Color(0xFFE0E0E0),
      width: 1,
    ),
  ),
  child: TextField(
    controller: _messageController,
    maxLines: null,
    expands: true,  //  Container ki full height le ga
    textAlign: TextAlign.center,
    textAlignVertical: TextAlignVertical.center,
    decoration: InputDecoration(
      hintText: "Input Message Here",
      hintStyle:AppColor1().customTextStyle14(
        color: Color(0xFF7C7777),
        
        ),
      border: InputBorder.none,  //  default border hatao
      contentPadding: EdgeInsets.symmetric(horizontal: 16),
    ),
  ),
),

                SizedBox(height: getHeight(49)),

                SizedBox(
                  width: double.infinity,
                  height: getHeight(55),
                  child: ElevatedButton(
                    onPressed: _launchWhatsApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    ),
                               child:  Text("Send Message",
                               style:AppColor1().customTextStyleBold16(
                                fontWeight: FontWeight(400)),
                                textAlign: TextAlign.center
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getMediaType(String path) {
  final p = path.toLowerCase();

  if (p.endsWith(".jpg") ||
      p.endsWith(".jpeg") ||
      p.endsWith(".png") ||
      p.endsWith(".webp")) {
    return "image";
  }

  if (p.endsWith(".mp4") ||
      p.endsWith(".mkv") ||
      p.endsWith(".3gp") ||
      p.endsWith(".mov")) {
    return "video";
  }

  if (p.endsWith(".mp3") ||
      p.endsWith(".aac") ||
      p.endsWith(".opus") ||
      p.endsWith(".ogg")) {
    return "audio";
  }

  return "unknown";
}