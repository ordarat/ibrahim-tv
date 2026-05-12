import 'dart:math';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PlayerScreen extends StatefulWidget {
  final String channelName;
  final String streamUrl;

  const PlayerScreen({super.key, required this.channelName, required this.streamUrl});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late String _userSessionId;
  late DatabaseReference _viewerRef; 
  int _viewersCount = 0;
  late String _viewId;

  @override
  void initState() {
    super.initState();
    // دروستکردنی ئایدییەکی جیاواز بۆ هەر جارێک کە پلەیەرەکە دەکرێتەوە
    _userSessionId = '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
    _viewId = 'shaka_player_${DateTime.now().millisecondsSinceEpoch}';
    
    _setupShakaPlayer();
    _setupPresenceSystem(); 
  }

  void _setupShakaPlayer() {
    // لێرەدا IFrame دروست دەکەین و کۆدەکانی Shaka Player ی تێدا جێگیر دەکەین
    ui_web.platformViewRegistry.registerViewFactory(_viewId, (int viewId) {
      final iframe = html.IFrameElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.border = 'none'
        ..allowFullscreen = true
        ..srcdoc = """
          <!DOCTYPE html>
          <html>
          <head>
            <!-- ڕاکێشانی پەرتوکخانەی فەرمی Shaka Player لە کۆمپانیاوە -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/shaka-player/4.7.1/shaka-player.ui.min.js"></script>
            <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/shaka-player/4.7.1/controls.min.css">
            <style>
              body { margin: 0; background-color: black; height: 100vh; overflow: hidden; display: flex; align-items: center; justify-content: center; }
              .video-container { width: 100%; height: 100%; position: relative; }
              video { width: 100%; height: 100%; outline: none; }
            </style>
          </head>
          <body>
            <div data-shaka-player-container class="video-container">
              <video autoplay data-shaka-player id="video"></video>
            </div>
            <script>
              // هێنانی لینکی کەناڵەکە لە فلاتەرەوە
              const manifestUri = '${widget.streamUrl}';

              async function init() {
                const video = document.getElementById('video');
                const ui = video['ui'];
                const controls = ui.getControls();
                const player = controls.getPlayer();

                // ڕێکخستنی مەکینەی Shaka بۆ ئەوەی بەرگەی پچڕانی ئینتەرنێت بگرێت
                player.configure({
                  streaming: {
                    bufferingGoal: 30,
                    rebufferingGoal: 2,
                    bufferBehind: 30,
                  }
                });

                try {
                  await player.load(manifestUri);
                  console.log('Video loaded successfully!');
                  video.play();
                } catch (e) {
                  console.error('Error loading video', e);
                }
              }

              // کاتێک دیزاینەکە تەواو بوو، مەکینەکە دەخاتە کار
              document.addEventListener('shaka-ui-loaded', init);
            </script>
          </body>
          </html>
        """;
      return iframe;
    });
  }

  Future<void> _setupPresenceSystem() async {
    // پاککردنەوەی ناوەکە بۆ ئەوەی داتابەیس قبوڵی بکات
    String safeChannelName = widget.channelName.replaceAll(RegExp(r'[.#\$\[\]]'), '_');
    
    _viewerRef = FirebaseDatabase.instance.ref('live_viewers/$safeChannelName/$_userSessionId');
    _viewerRef.onDisconnect().remove();
    await _viewerRef.set(true);

    FirebaseDatabase.instance.ref('live_viewers/$safeChannelName').onValue.listen((event) {
      if (mounted) {
        setState(() {
          if (event.snapshot.exists) {
            _viewersCount = event.snapshot.children.length;
          } else {
            _viewersCount = 0;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _viewerRef.remove(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // پیشاندانی ڤیدیۆکەی Shaka Player
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: HtmlElementView(viewType: _viewId),
            ),
            
            // دوگمەی گەڕانەوە (چوونە دەرەوە لە کەناڵەکە)
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

            // سیستەمی لایڤ و بینەرەکان کە وەک خۆی ماوەتەوە
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
