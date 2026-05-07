import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:status_saver/Local%20Database/LocalDatabase.dart';
import 'package:status_saver/bloc/status/status_bloc.dart';
import 'package:status_saver/bloc/status/status_state.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({super.key});

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  static const List<double> _waveHeights = [
    6, 8, 12, 18, 24, 20, 14, 10, 16, 22,
    28, 24, 18, 12, 8, 14, 20, 26, 30, 26,
    20, 16, 10, 14, 18, 24, 28, 22, 16, 12,
    8, 10, 16, 22, 26, 20, 14, 10, 6, 8,
    12, 18, 24, 28, 22, 16, 10, 8, 12, 18,
  ];

  final AudioPlayer _player = AudioPlayer();
  int? _playingIndex;
  int _playedBars = 0;
  bool _isPlaying = false;
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
      final bars =
          (progress * _waveHeights.length).clamp(0, _waveHeights.length).toInt();
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
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay(int index, String path) async {
    if (_playingIndex == index) {
      if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
      return;
    }

    setState(() {
      _playingIndex = index;
      _playedBars = 0;
    });

    await _player.stop();
    await _player.play(DeviceFileSource(path));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StatusBloc, StatusState>(
      builder: (context, state) {
        final audioFiles = state.audio;

        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (audioFiles.isEmpty) {
          return const Center(
            child: Text(
              "No Audio Found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return ListView.builder(
          itemCount: audioFiles.length,
          padding: const EdgeInsets.all(10),
          itemBuilder: (context, index) {
            final path = audioFiles[index].path;
            final bool isThisPlaying = _playingIndex == index && _isPlaying;
            final bool isThisActive = _playingIndex == index;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AudioPlayerScreen(
                      audioPath: path,
                    ),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [

                    /// PLAY / PAUSE BUTTON
                    GestureDetector(
                      onTap: () {
                        _togglePlay(index, path);
                      },
                      child: Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF000000).withOpacity(0.25),
                              offset: const Offset(0, 1),
                              blurRadius: 1,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          isThisPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.black,
                          size: 27,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    /// WAVE BARS
                    Expanded(
                      child: Row(
                        children: List.generate(
                          _waveHeights.length,
                          (i) {
                            final bool isGreen =
                                isThisActive && i < _playedBars;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 1.6,
                              height: _waveHeights[i],
                              decoration: BoxDecoration(
                                color: isGreen
                                    ? Colors.green
                                    : Colors.black.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          },
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}