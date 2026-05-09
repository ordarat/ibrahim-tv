import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class LiveVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const LiveVideoPlayer({super.key, required this.videoUrl});

  @override
  State<LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<LiveVideoPlayer> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      isLive: true,
      aspectRatio: 16 / 9,
      placeholder: const Center(child: CircularProgressIndicator(color: Colors.orange)),
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.orange,
        handleColor: Colors.orange,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white38,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
        ? AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: _chewieController!))
        : const AspectRatio(aspectRatio: 16 / 9, child: Center(child: CircularProgressIndicator(color: Colors.orange)));
  }
}
