// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:just_audio/just_audio.dart' hide PlayerState, AudioPlayer;
// import 'package:provider/provider.dart';
// import 'package:status_saver/Local%20Database/LocalDatabase.dart';
// import 'package:status_saver/Utils/Constants/AllColors.dart';
// import 'package:status_saver/Utils/Constants/AllText.dart';
// import 'package:status_saver/Utils/Constants/SizeConfig.dart';
// import 'package:status_saver/bloc/status/status_bloc.dart';
// import 'package:status_saver/bloc/status/status_event.dart';
// import 'package:status_saver/config/images/app_images.dart';

// class AudioPlayerScreen extends StatefulWidget {
//   final String audioPath;
//   final bool isFromSavedScreen;
//   final List<String> audioList;
//   final int initialIndex;

//   static const List<double> _waveHeights = [
//     6, 8, 12, 18, 24, 20, 14, 10, 16, 22,
//     28, 24, 18, 12, 8, 14, 20, 26, 30, 26,
//     20, 16, 10, 14, 18, 24, 28, 22, 16, 12,
//     8, 10, 16, 22, 26, 20, 14, 10, 6, 8,
//     12, 18, 24, 28, 22, 16, 10, 8, 12, 18,
//   ];

//   const AudioPlayerScreen({
//     required this.audioPath,
//     super.key,
//     this.isFromSavedScreen = false,
//     required this.audioList,
//     required this.initialIndex,
//   });

//   @override
//   State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
// }

// class _AudioPlayerScreenState extends State<AudioPlayerScreen> {
//   final AudioPlayer _player = AudioPlayer();

//   bool _isPlaying = false;
//   int _playedBars = 0;
//   Duration _totalDuration = Duration.zero;

//   late PageController _pageController;
//   int currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();

//     currentIndex = widget.initialIndex;
//     _pageController = PageController(initialPage: currentIndex);

//     _playAudio(widget.audioList[currentIndex]);

//     _player.onDurationChanged.listen((duration) {
//       setState(() => _totalDuration = duration);
//     });

//     _player.onPositionChanged.listen((position) {
//       if (_totalDuration.inMilliseconds == 0) return;

//       final progress =
//           position.inMilliseconds / _totalDuration.inMilliseconds;

//       final bars = (progress * AudioPlayerScreen._waveHeights.length)
//           .clamp(0, AudioPlayerScreen._waveHeights.length)
//           .toInt();

//       if (mounted) setState(() => _playedBars = bars);
//     });

//     _player.onPlayerComplete.listen((_) {
//       if (mounted) {
//         setState(() {
//           _isPlaying = false;
//           _playedBars = 0;
//         });
//       }
//     });

//     _player.onPlayerStateChanged.listen((s) {
//       if (mounted) {
//         setState(() => _isPlaying = s == PlayerState.playing);
//       }
//     });
//   }

//   void _playAudio(String path) async {
//     await _player.stop();
//     await _player.play(DeviceFileSource(path));
//   }

//   Future<void> _togglePlay() async {
//     if (_isPlaying) {
//       await _player.pause();
//     } else {
//       await _player.resume();
//     }
//   }

//   @override
//   void dispose() {
//     _player.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//   print("Audio List Length: ${widget.audioList.length}");
//   print("Current Index: $currentIndex");
//     return Scaffold(
//       backgroundColor: const Color(0xFFE3EAF2),

//       appBar: AppBar(
//         backgroundColor: const Color(0xFFE3EAF2),
//         leading: IconButton(
//           onPressed: () => Navigator.pop(context),
//           icon: const Icon(Icons.arrow_back),
//         ),
//         title: Text("Status Saver",
//             style: AppColor1().customTextStyleBold16()),
//         centerTitle: true,
//       ),

//       body: Column(
//         children: [

//           ///  ONLY CHANGE = PageView added here
//           Expanded(
//             child: PageView.builder(
//               controller: _pageController,
//               itemCount: widget.audioList.length,
//               onPageChanged: (index) {
//                 setState(() {
//                   currentIndex = index;
//                   _playedBars = 0;
//                 });

//                 _playAudio(widget.audioList[index]);
//               },
//               itemBuilder: (context, index) {
//                 return Center(
//                   child: Container(
//                     height: getHeight(67),
//                     margin: const EdgeInsets.symmetric(horizontal: 50),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(6),
//                     ),
//                     child: Row(
//                       children: [

//                         /// PLAY BUTTON
//                         GestureDetector(
//                           onTap: _togglePlay,
//                           child: Container(
//                             height: 34,
//                             width: 34,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.white,
//                             ),
//                             child: Icon(
//                               _isPlaying
//                                   ? Icons.pause
//                                   : Icons.play_arrow,
//                               color: Colors.black,
//                               size: 27,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 12),

//                         /// WAVE
//                         Expanded(
//                           child: Row(
//                             children: List.generate(
//                               AudioPlayerScreen._waveHeights.length,
//                               (i) {
//                                 final isPlayed = i < _playedBars;

//                                 return Container(
//                                   margin:
//                                       const EdgeInsets.symmetric(horizontal: 1),
//                                   width: 1.6,
//                                   height:
//                                       AudioPlayerScreen._waveHeights[i],
//                                   color: isPlayed
//                                       ? Colors.black
//                                       : const Color(0xFFE3EAF2),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           ///  BOTTOM BUTTONS (ONLY PATH FIXED)
//           Container(
//             padding: const EdgeInsets.symmetric(
//                 vertical: 16, horizontal: 20),
//             decoration: const BoxDecoration(color: Colors.white),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [

//                 bottomButton(
//                   () => shareStatus(
//                       widget.audioList[currentIndex]),
//                   AllIcons.repost,
//                   AllText.Repost,
//                 ),

//                 bottomButton(
//                   () => shareStatus(
//                       widget.audioList[currentIndex]),
//                   AllIcons.share,
//                   AllText.Share,
//                 ),

//                 bottomButton(
//                   () {
//                     if (widget.isFromSavedScreen == true) {
//                       deleteAudio(
//                         context,
//                         widget.audioList[currentIndex],
//                       );
//                     } else {
//                       saveMedia(
//                         context,
//                         widget.audioList[currentIndex],
//                         isVideo: false,
//                       );

//                       if (context.mounted) {
//                         context
//                             .read<StatusBloc>()
//                             .add(LoadStatusEvent());
//                       }
//                     }
//                   },
//                   widget.isFromSavedScreen
//                       ? AllIcons.delete
//                       : AllIcons.save,
//                   widget.isFromSavedScreen
//                       ? AllText.delete
//                       : AllText.Save,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }