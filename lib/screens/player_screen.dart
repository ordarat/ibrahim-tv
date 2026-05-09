import 'package:flutter/material.dart';
import '../widgets/live_video_player.dart';

class PlayerScreen extends StatelessWidget {
  final String channelName;
  final String streamUrl;

  const PlayerScreen({
    super.key,
    required this.channelName,
    required this.streamUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(channelName, style: const TextStyle(color: Colors.orange)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: LiveVideoPlayer(videoUrl: streamUrl),
      ),
    );
  }
}
