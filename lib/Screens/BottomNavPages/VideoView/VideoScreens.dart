import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:status_saver/Utils/Constants/AllColors.dart';
import 'package:status_saver/bloc/status/status_bloc.dart';
import 'package:status_saver/bloc/status/status_event.dart';
import 'package:status_saver/bloc/status/status_state.dart';
import '../../../Utils/Constants/SizeConfig.dart';
import 'VideoView.dart';

class VideoScreens extends StatefulWidget {
  const VideoScreens({super.key});

  @override
  State<VideoScreens> createState() => _VideoScreensState();
}

class _VideoScreensState extends State<VideoScreens> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    return Scaffold(
      backgroundColor: AppColor1.screenbackgroundColor,
      body: BlocBuilder<StatusBloc, StatusState>(
        buildWhen: (prev, curr) =>
            prev.videos != curr.videos ||
            prev.thumbnailCache != curr.thumbnailCache ||
            prev.isWhatsappAvailable != curr.isWhatsappAvailable ||
            prev.isLoading != curr.isLoading,
        builder: (context, state) {

          // ================= LOADING =================
          if (state.isLoading && state.videos.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.green),
            );
          }

          // ================= WHATSAPP NOT FOUND =================
          if (!state.isWhatsappAvailable && state.videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.whatshot, color: Colors.grey, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "WhatsApp not available",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          final videos = state.videos;

          // ================= NO VIDEOS =================
          if (videos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_off, color: Colors.grey, size: 60),
                  SizedBox(height: 10),
                  Text(
                    "No Videos Available",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          // ================= GRID =================
          return Padding(
            padding: const EdgeInsets.all(8),
            child: GridView.builder(
              itemCount: videos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
                mainAxisExtent: getHeight(175),
              ),
              itemBuilder: (context, index) {

                final videoPath = videos[index].path;
                final Uint8List? thumbnail = state.thumbnailCache[videoPath];

                //  Thumbnail load karo agar cache mein nahi hai
                if (thumbnail == null) {
                  context.read<StatusBloc>().add(
                    LoadThumbnailEvent(videoPath),
                  );
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => VideoPlayerScreen(
                          videoPath: videoPath,
                          currentIndex: index,
                          allVideos: state.videos.map((e) => e.path).toList(),
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [

                        // ================= THUMBNAIL =================
                        thumbnail != null
                            ? Image.memory(
                                thumbnail,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[850],
                                child: const Center(
                                  child: Icon(
                                    Icons.videocam,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),

                        // ================= PLAY ICON =================
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}