import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ئەمە زیادکراوە بۆ کۆنتڕۆڵکردنی سوڕانەوەی شاشە
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerScreen extends StatefulWidget {
  final String channelName;
  final String streamUrl;

  const PlayerScreen({super.key, required this.channelName, required this.streamUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  late String _userSessionId; 

  @override
  void initState() {
    super.initState();
    _userSessionId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    WidgetsBinding.instance.addObserver(this);
    _addViewer(); 
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      isLive: true,
      allowFullScreen: true, // ڕێگەدان بە دوگمەی فوول سکرین
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeRight,
        DeviceOrientation.landscapeLeft,
      ], // کاتێک دەچێتە فوول سکرین، شاشەکە بە پاڵکەوتوویی دەسوڕێنێتەوە
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
      ], // کاتێک لە فوول سکرین دەردەچێت، دەیگەڕێنێتەوە باری ستوونی
      aspectRatio: _videoPlayerController.value.aspectRatio > 0 
          ? _videoPlayerController.value.aspectRatio 
          : 16 / 9,
      errorBuilder: (context, errorMessage) {
        return const Center(child: Text('کێشە لە پەخشکردنی ئەم کەناڵە هەیە', style: TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  Future<void> _addViewer() async {
    await FirebaseFirestore.instance
        .collection('channel_stats')
        .doc(widget.channelName)
        .collection('live_viewers')
        .doc(_userSessionId)
        .set({'joined_at': FieldValue.serverTimestamp()});
  }

  Future<void> _removeViewer() async {
    await FirebaseFirestore.instance
        .collection('channel_stats')
        .doc(widget.channelName)
        .collection('live_viewers')
        .doc(_userSessionId)
        .delete();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _removeViewer();
    } else if (state == AppLifecycleState.resumed) {
      _addViewer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeViewer(); 
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('channel_stats')
                    .doc(widget.channelName)
                    .collection('live_viewers')
                    .snapshots(),
                builder: (context, snapshot) {
                  int viewers = 0;
                  if (snapshot.hasData) {
                    viewers = snapshot.data!.docs.length; 
                  }
                  
                  return Container(
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
                        Text('$viewers', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
