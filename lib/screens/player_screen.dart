import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:firebase_database/firebase_database.dart'; // پاکێجی داتابەیسە نوێیەکە

class PlayerScreen extends StatefulWidget {
  final String channelName;
  final String streamUrl;

  const PlayerScreen({super.key, required this.channelName, required this.streamUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late String _userSessionId;
  late DatabaseReference _viewerRef; // شوێنی سەیڤکردنی ئەم ئامێرە
  int _viewersCount = 0;

  @override
  void initState() {
    super.initState();
    _userSessionId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    _initializePlayer();
    _setupPresenceSystem(); // کارپێکردنی سیستەمە زیرەکەکە
  }

  void _setupPresenceSystem() {
    // ١. شوێنێک لە داتابەیس دروست دەکات بە ناوی کەناڵەکە و کۆدی ئامێرەکە
    _viewerRef = FirebaseDatabase.instance.ref('live_viewers/${widget.channelName}/$_userSessionId');

    // ٢. فەرمانی ئاڵتونی (onDisconnect): هەرکاتێک تابی وێبگەڕەکە داخرا یان نێت نەما، ڕاستەوخۆ بیسڕەوە!
    _viewerRef.onDisconnect().remove();

    // ٣. ئامێرەکە ئێستا لایڤە، بۆیە زیادی بکە
    _viewerRef.set(true);

    // ٤. بەردەوام گوێ لە ژمارەی کۆی گشتی ئامێرەکان دەگرێت
    FirebaseDatabase.instance.ref('live_viewers/${widget.channelName}').onValue.listen((event) {
      if (mounted) {
        setState(() {
          if (event.snapshot.exists) {
            _viewersCount = event.snapshot.children.length; // ژمارەی ئەوانەی ئێستا سەیری دەکەن
          } else {
            _viewersCount = 0;
          }
        });
      }
    });
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      isLive: true,
      allowFullScreen: true,
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ],
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ],
      aspectRatio: _videoPlayerController.value.aspectRatio > 0 
          ? _videoPlayerController.value.aspectRatio 
          : 16 / 9,
      errorBuilder: (context, errorMessage) {
        return const Center(child: Text('کێشە لە پەخشکردنی ئەم کەناڵە هەیە', style: TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _viewerRef.remove(); // ئەگەر بە دوگمەی Back گەڕایەوە، لێرەدا دەیسڕێتەوە
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const CircularProgressIndicator(color: Colors.orange),
            ),
            
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.8), width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    const Text('LIVE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(width: 12),
                    const Icon(Icons.visibility, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text('$_viewersCount', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
