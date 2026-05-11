import 'dart:math';
import 'package:flutter/material.dart';
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
  late String _userSessionId; // کۆدە تایبەتەکەی ئەم ئامێرە (لەبری ئایپی)

  @override
  void initState() {
    super.initState();
    // دروستکردنی کۆدێکی تایبەت بەم سەردانیکەرە لەم کاتەدا
    _userSessionId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    
    WidgetsBinding.instance.addObserver(this);
    _addViewer(); // هەر کە کرایەوە کۆدەکەی خۆی دەنێرێتە فایەربەیس
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      isLive: true,
      aspectRatio: _videoPlayerController.value.aspectRatio > 0 
          ? _videoPlayerController.value.aspectRatio 
          : 16 / 9,
      errorBuilder: (context, errorMessage) {
        return const Center(child: Text('کێشە لە پەخشکردنی ئەم کەناڵە هەیە', style: TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  // تۆمارکردنی ئەم ئامێرە لەناو لیستی بینەرە ڕاستەوخۆکاندا
  Future<void> _addViewer() async {
    await FirebaseFirestore.instance
        .collection('channel_stats')
        .doc(widget.channelName)
        .collection('live_viewers')
        .doc(_userSessionId)
        .set({'joined_at': FieldValue.serverTimestamp()});
  }

  // سڕینەوەی ئەم ئامێرە لە لیستی بینەرەکان کاتێک دەچێتە دەرەوە
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
    // ئەگەر ئەپەکەی خستە خوارەوە (Background) یان دایخست
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _removeViewer();
    } 
    // ئەگەر گەڕایەوە ناو ئەپەکە و ڤیدیۆکە
    else if (state == AppLifecycleState.resumed) {
      _addViewer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeViewer(); // کاتێک دوگمەی Back دادەگرێت، ڕاستەوخۆ خۆی دەسڕێتەوە
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
                  onPressed: () => Navigator.pop(context), // لێرەدا دەگەڕێتەوە دواوە و dispose کار دەکات
                ),
              ),
            ),

            Positioned(
              top: 20,
              left: 20,
              child: StreamBuilder<QuerySnapshot>(
                // لێرەدا بە ڕاستەوخۆیی (Stream) گوێ لە ژمارەی فایلەکانی ناو live_viewers دەگرێت
                stream: FirebaseFirestore.instance
                    .collection('channel_stats')
                    .doc(widget.channelName)
                    .collection('live_viewers')
                    .snapshots(),
                builder: (context, snapshot) {
                  int viewers = 0;
                  if (snapshot.hasData) {
                    viewers = snapshot.data!.docs.length; // ژمارەی بینەرەکان = کۆی ئەو ئامێرانەی ئێستا سەیر دەکەن
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
