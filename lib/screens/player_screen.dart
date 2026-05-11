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

// لێرەدا WidgetsBindingObserver بەکاردەهێنین بۆ ئەوەی بزانین کەی ئەپەکە دادەخرێت
class _PlayerScreenState extends State<PlayerScreen> with WidgetsBindingObserver {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _hasIncremented = false; // بۆ دڵنیابوون لەوەی تەنها یەکجار زیاد دەبێت

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // چاودێری داخستنی ئەپەکە دەکات
    _incrementViewers(); // هەر کە کرایەوە بینەرێک زیاد دەکات
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.streamUrl));
    await _videoPlayerController.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      isLive: true, // شێوازی لایڤ چالاک دەکات
      aspectRatio: _videoPlayerController.value.aspectRatio > 0 
          ? _videoPlayerController.value.aspectRatio 
          : 16 / 9,
      errorBuilder: (context, errorMessage) {
        return const Center(child: Text('کێشە لە پەخشکردنی ئەم کەناڵە هەیە', style: TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  // فەنکشنی زیادکردنی بینەر لە فایەربەیس
  Future<void> _incrementViewers() async {
    if (_hasIncremented) return;
    _hasIncremented = true;
    
    // لەناو کۆلێکشنێکی نوێ بە ناوی channel_stats ژمارەکە هەڵدەگرین
    await FirebaseFirestore.instance.collection('channel_stats').doc(widget.channelName).set({
      'viewers': FieldValue.increment(1)
    }, SetOptions(merge: true));
  }

  // فەنکشنی کەمکردنەوەی بینەر
  Future<void> _decrementViewers() async {
    if (!_hasIncremented) return;
    _hasIncremented = false;
    
    // سەرەتا دڵنیا دەبینەوە کە ژمارەکە لە سفڕ کەمتر نەبێتەوە
    var doc = await FirebaseFirestore.instance.collection('channel_stats').doc(widget.channelName).get();
    if (doc.exists) {
      int current = doc.data()?['viewers'] ?? 0;
      if (current > 0) {
        await FirebaseFirestore.instance.collection('channel_stats').doc(widget.channelName).set({
          'viewers': FieldValue.increment(-1)
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // ئەگەر ئەپەکە خرایە باکگراوند یان داخرا، بینەرەکە کەم بکەرەوە
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _decrementViewers();
    } else if (state == AppLifecycleState.resumed) {
      // ئەگەر گەڕایەوە ناو ئەپەکە، دووبارە زیادی بکەرەوە
      _incrementViewers();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _decrementViewers(); // کاتێک دەگەڕێتەوە دواوە (Back)، بینەرەکە کەم دەکاتەوە
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
            // ڤیدیۆ پلەیەرەکە لە خوارەوە
            Center(
              child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                  ? Chewie(controller: _chewieController!)
                  : const CircularProgressIndicator(color: Colors.orange),
            ),
            
            // دوگمەی گەڕانەوە (لە لای ڕاست)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // شریتی لایڤ و ژمارەی بینەران (لە لای چەپ)
            Positioned(
              top: 20,
              left: 20,
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('channel_stats').doc(widget.channelName).snapshots(),
                builder: (context, snapshot) {
                  int viewers = 0;
                  if (snapshot.hasData && snapshot.data!.exists) {
                    viewers = (snapshot.data!.data() as Map<String, dynamic>)['viewers'] ?? 0;
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
                        // خاڵی سووری لایڤ
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
