import 'package:flutter/cupertino.dart';
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
import 'package:status_saver/bloc/status/status_bloc.dart';
import 'package:status_saver/bloc/status/status_event.dart';
import 'package:status_saver/config/images/app_images.dart';
import 'package:status_saver/l10n/app_localizations.dart';
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
      return newPath;
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
  final String type;

  @HiveField(2)
  final DateTime dateTime;

  SavedItem({
    required this.path,
    required this.type,
    required this.dateTime,
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
    final t = AppLocalizations.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColor1.screenbackgroundColor,
        appBar: AppBar(
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
            AppLocalizations.of(context)!.savedStatuses,
            style: AppColor1().customTextStyleBold16(),
          ),
          backgroundColor: AppColor1.screenbackgroundColor,
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(child: tabbutton(t.images)),
              Tab(child: tabbutton(t.videos)),
              Tab(child: tabbutton(t.audio)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MediaGridScreen(mediaType: 'image', context: context),
            MediaGridScreen(mediaType: 'video', context: context),
            MediaGridScreen(mediaType: 'audio', context: context),
          ],
        ),
      ),
    );
  }
}

class MediaGridScreen extends StatefulWidget {
  final String mediaType;
  final BuildContext context;

  const MediaGridScreen({
    super.key,
    required this.mediaType,
    required this.context,
  });

  @override
  State<MediaGridScreen> createState() => _MediaGridScreenState();
}

class _MediaGridScreenState extends State<MediaGridScreen> {
  final Set<String> _selectedPaths = {};
  bool get _isSelectionMode => _selectedPaths.isNotEmpty;

  void _onLongPress(String path) {
    setState(() {
      if (_selectedPaths.contains(path)) {
        _selectedPaths.remove(path);
      } else {
        _selectedPaths.add(path);
      }
    });
  }

  void _onTap(
    String path,
    SavedItem item,
    int index,
    List<SavedItem> allItems,
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
              style: const TextStyle(color: Colors.grey),
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
                    const EdgeInsets.symmetric(
                      horizontal: 16, 
                      vertical: 8
                      ),
                child: Row(
                  children: [
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
                          border: Border.all(color: Colors.white, width: 2),
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
                      style: AppColor1()
                          .customTextStyle12(color: AppColor1.textColor),
                    ),
                    const Spacer(),
                    Text(
                      "${_selectedPaths.length} selected",
                      style: AppColor1()
                          .customTextStyle12(color: AppColor1.textColor),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(
                        Icons.delete, 
                        color: Colors.red
                        ),
                      onPressed: _deleteSelected,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: _clearSelection,
                    ),
                  ],
                ),
              ),

            // ── Grid / List ──
            Expanded(
              child: widget.mediaType == 'audio'

                  // ── AUDIO → ListView ──
                  ? ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final isSelected = _selectedPaths.contains(item.path);

                        return GestureDetector(
                          onLongPress: () => _onLongPress(item.path),
                          onTap: () =>
                              _onTap(item.path, item, index, filteredItems),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Stack(
                              children: [
                                _buildThumbnail(item),

                                // Dark overlay when selected
                                if (isSelected)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),

                                // Selection circle
                                if (_isSelectionMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
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
                    )

                  // ── IMAGE / VIDEO → GridView ──
                  : GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
                                _buildThumbnail(item),

                                if (isSelected)
                                  Container(color: Colors.black45),

                                if (item.type != 'image' && !isSelected)
                                  const Center(
                                    child: Icon(
                                      Icons.play_circle_fill,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),

                                if (_isSelectionMode)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
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

  // ── Thumbnail Builder ──
  Widget _buildThumbnail(SavedItem item) {
    final file = File(item.path);

    /// IMAGE
   /// IMAGE
if (item.type == 'image') {

  /// CHECK FILE EXISTS + NOT EMPTY
  if (file.existsSync() && file.lengthSync() > 0) {

    return Image.file(
      file,
      fit: BoxFit.cover,

      /// HANDLE CORRUPT IMAGE
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey.shade300,
          child: const Center(
            child: Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey,
            ),
          ),
        );
      },
    );
  }

  /// EMPTY IMAGE FILE
  return Container(
    color: Colors.grey.shade300,
    child: const Center(
      child: Icon(
        Icons.broken_image,
        size: 40,
        color: Colors.grey,
      ),
    ),
  );
}

    /// VIDEO
    if (item.type == 'video') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 45,
          ),
        ),
      );
    }

    /// AUDIO
    if (item.type == 'audio') {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12, 
          vertical: 10
          ),
        child: Row(
          children: [
            /// PLAY BUTTON
          GestureDetector(
  onTap: () {
    
  },
  child: Container(
    width: 34,
    height: 34,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      shape: BoxShape.circle,
    ),
    child: Icon(
       Icons.play_arrow ,
      size: 20,
      color: Colors.black87,
    ),
  ),
),

            const SizedBox(width: 12),

            /// AUDIO WAVE
            Expanded(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: List.generate(40, (index) {
      final heights = [
        6.0, 8.0, 12.0, 18.0, 24.0,
        20.0, 14.0, 10.0, 16.0, 22.0,
        28.0, 24.0, 18.0, 12.0, 8.0,
        14.0, 20.0, 26.0, 30.0, 26.0,
        20.0, 16.0, 10.0, 14.0, 18.0,
        24.0, 28.0, 22.0, 16.0, 12.0,
        8.0, 10.0, 16.0, 22.0, 26.0,
        20.0, 14.0, 10.0, 6.0, 8.0,
        12.0, 18.0, 24.0, 28.0, 22.0,
        16.0, 10.0, 8.0, 12.0, 18.0,
      ];

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 1.8,
        height: heights[index % heights.length],
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }),
  ),
)
          ],
        ),
      );
    }

    return const SizedBox();
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
            child: const Text("Cancel",
                style: TextStyle(color: Colors.grey)),
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
        message: "Successfully deleted ",
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
        CupertinoPageRoute(
          builder: (_) => ImageView(
            images: allItems.map((e) => e.path).toList(),
            initialIndex: index,
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
            isFromSavedScreen: true,
            audioList: allItems.map((e) => e.path).toList(),
            initialIndex: index,
          ),
        ),
      );
    }
  }
}


// =================================AudioView====================

class AudioPlayerScreen extends StatefulWidget {
  final String audioPath;
  final bool isFromSavedScreen;
  final List<String> audioList;
  final int initialIndex;

  static const List<double> _waveHeights = [
    6, 8, 12, 18, 24, 20, 14, 10, 16, 22,
    28, 24, 18, 12, 8, 14, 20, 26, 30, 26,
    20, 16, 10, 14, 18, 24, 28, 22, 16, 12,
    8, 10, 16, 22, 26, 20, 14, 10, 6, 8,
    12, 18, 24, 28, 22, 16, 10, 8, 12, 18,
  ];

  const AudioPlayerScreen({
    super.key,
    required this.audioPath,
    this.isFromSavedScreen = false,
    required this.audioList,
    required this.initialIndex,
  });

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
  final AudioPlayer _player = AudioPlayer();

  bool _isPlaying = false;
  int _playedBars = 0;
  Duration _totalDuration = Duration.zero;

  late PageController _pageController;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();

    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: currentIndex);

    _initAudio(currentIndex);

    _player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => _totalDuration = d);
    });

    _player.onPositionChanged.listen((p) {
      if (_totalDuration.inMilliseconds == 0 || !mounted) return;
      final progress = p.inMilliseconds / _totalDuration.inMilliseconds;
      final bars = (progress * AudioPlayerScreen._waveHeights.length)
          .clamp(0, AudioPlayerScreen._waveHeights.length)
          .toInt();
      setState(() => _playedBars = bars);
    });

    _player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() {
        _isPlaying = false;
        _playedBars = 0;
      });
    });

    _player.onPlayerStateChanged.listen((s) {
      if (!mounted) return;
      setState(() => _isPlaying = s == PlayerState.playing);
    });
  }

  Future<void> _initAudio(int index) async {
    await _player.stop();
    await _player.play(DeviceFileSource(widget.audioList[index]));
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
  }

  void _next() {
    if (currentIndex < widget.audioList.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previous() {
    if (currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFE3EAF2),
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
          Expanded(
            child: Row(
              children: [
                /// LEFT BUTTON
                GestureDetector(
                  onTap: _previous,
                  child: SizedBox(
                    width: 60,
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

                /// PAGE VIEW
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.audioList.length,
                    onPageChanged: (index) async {
                      setState(() {
                        currentIndex = index;
                        _playedBars = 0;
                      });
                      await _initAudio(index);
                    },
                    itemBuilder: (context, index) {
                      return Center(
                        child: Container(
                          height: 67,
                          margin:
                              const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: _togglePlay,
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: List.generate(
                                    AudioPlayerScreen._waveHeights.length,
                                    (i) {
                                      final isPlayed = i < _playedBars;
                                      return Container(
                                        width: 1.2,
                                        height: AudioPlayerScreen
                                            ._waveHeights[i],
                                        color: isPlayed
                                            ? Colors.black
                                            : const Color(0xFFE3EAF2),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// RIGHT BUTTON
                GestureDetector(
                  onTap: _next,
                  child: SizedBox(
                    width: 60,
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
              ],
            ),
          ),

          /// FIXED BOTTOM BAR
          Container(
            padding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: const BoxDecoration(color: Colors.white),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bottomButton(
                  () => shareStatus(widget.audioPath),
                  AllIcons.repost,
                  t.repost,
                ),
                bottomButton(
                  () => shareStatus(widget.audioPath),
                  AllIcons.share,
                  t.share,
                ),
                bottomButton(
                  () {
                    if (widget.isFromSavedScreen == true) {
                      deleteAudio(context, widget.audioList[currentIndex]);
                    } else {
                      saveMedia(
                        context,
                        widget.audioList[currentIndex],
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
}

// =================== audio delete function ================
Future<void> deleteAudio(BuildContext context, String path) async {
  try {
    final box = Hive.box<SavedItem>('saved_items');
    final item = box.values.firstWhere(
      (e) => e.path == path,
      orElse: () => throw Exception("Item not found"),
    );
    final file = File(path);
    if (await file.exists()) await file.delete();
    await item.delete();
    if (context.mounted) {
      context.read<StatusBloc>().add(LoadStatusEvent());
    }
   if (context.mounted) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: const Color(0xFFF0EFF4),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24, 
            vertical: 28
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
             Text(
        AppLocalizations.of(context)!.deleteAudioTitle,
        style: AppColor1().customTextStyleRegular10().copyWith(
        color: Colors.black,
        fontSize:getFont(22),
        fontWeight: FontWeight.bold,
  ),
),
              const SizedBox(height: 12),
              // SUBTITLE
               Text(
                AppLocalizations.of(context)!.deleteAudioTitle,
                style: AppColor1().customTextStyleRegular10().copyWith(
                  color: Colors.black54,
                  fontSize: getFont(14),
                ),
              ),
              const SizedBox(height: 24),
              // BUTTONS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // CANCEL BUTTON
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text(
                      AppLocalizations.of(context)!.cancel,
                     style: AppColor1().customTextStyleRegular10().copyWith(
    color: Colors.black,
    fontSize:getFont(14),
    fontWeight: FontWeight.bold,
  ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // DELETE BUTTON
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 22, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      // TODO: apna delete logic yahan likhein
                    },
                    child:  Text(
                      AppLocalizations.of(context)!.delete,
                     style: AppColor1().customTextStyleRegular10().copyWith(
    color: Colors.black,
    fontSize:getFont(14),
    fontWeight: FontWeight.bold,
  ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
  } catch (e) {
    debugPrint("Delete Audio Error: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Delete failed: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// ++++++++++++==== audio saver function ================++++++++++++

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

    //  FIX: Android 10–14 safe storage path
    final externalDir = await getExternalStorageDirectory();

    final dir = Directory("${externalDir!.path}/StatusSaver");

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

    final box = Hive.box<SavedItem>('saved_items');

    await box.add(
      SavedItem(
        path: newFile.path,
        type: _getMediaType(newFile.path),
        dateTime: DateTime.now(),
      ),
    );

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE3EAF2),
                  Color(0xFFC9D6FF),
                  Color(0xFFA1C4FD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.download,
                  color: Colors.black,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.mediaSavedSuccessfully,
                  style: const TextStyle(color: Colors.black),
                ),
              ],
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
Future<bool> requestPermission() async {
  if (Platform.isAndroid) {

    // Android 13+
    if (await Permission.photos.isGranted ||
        await Permission.videos.isGranted ||
        await Permission.audio.isGranted) {
      return true;
    }

    // Android 11 / 10 / below
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      return true;
    }

    final result = await [
      Permission.photos,
      Permission.videos,
      Permission.audio,
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    return result.values.any((status) => status.isGranted);
  }

  return true;
}

void shareStatus(String path) async {
  try {
    await Share.shareXFiles([XFile(path)], text: "Check this audio");
  } catch (e) {
    print("Share error: $e");
  }
}

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

class DirectChatScreen extends StatefulWidget {
  const DirectChatScreen({super.key});

  @override
  State<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends State<DirectChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  String fullPhoneNumber = "";

  Future<void> _launchWhatsApp() async {
    if (fullPhoneNumber.isEmpty) return;

    final String message = _messageController.text.trim();
    final String cleanNumber = fullPhoneNumber.replaceAll('+', '');
    final String url =
        "https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}";
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
    final t = AppLocalizations.of(context)!;
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColor1.screenbackgroundColor,
         leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: SvgPicture.asset(
            AllIcons.backArrow,
            width: getWidth(22),
            height: getHeight(22),
            colorFilter: const ColorFilter.mode(
              Colors.black87,
              BlendMode.srcIn,
            ),
          ),
        ),
        title: Text(
          t.directChat,
          style: AppColor1().customTextStyleBold16(
            fontWeight: FontWeight(500),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.symmetric(
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
                  t.whatsappWeb,
                  style: AppColor1().customTextStyleBold16(
                    fontWeight: FontWeight(500),
                  ),
                ),
                SizedBox(height: getHeight(29)),
                Text(
                  t.directlyMessage,
                  style: AppColor1()
                      .customTextStyleBold16(fontWeight: FontWeight.w400)
                      .copyWith(
                        color: const Color(0xFF7C7777),
                        fontSize: 16,
                        height: 1.3,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 49),
                IntlPhoneField(
                  decoration: InputDecoration(
                    hintText: '3194160084',
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF000000),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F5F5),
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
                      vertical: 15,
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  flagsButtonMargin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 3,
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
                      color: const Color(0xFFE0E0E0),
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      hintText: t.inputMessageHere,
                      hintStyle: AppColor1().customTextStyle14(
                        color: const Color(0xFF7C7777),
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
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
                      backgroundColor: const Color(0xFFF5F5F5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      t.sendMessage,
                      style: AppColor1().customTextStyleBold16(
                        fontWeight: FontWeight(400),
                      ),
                      textAlign: TextAlign.center,
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