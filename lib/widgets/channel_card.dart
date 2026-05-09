import 'package:flutter/material.dart';

class ChannelCard extends StatelessWidget {
  final String channelName;
  final String logoUrl; // ئەمەمان زیاد کرد بۆ وەرگرتنی لینکی لۆگۆکە
  final bool isVIP;
  final bool isActive;

  const ChannelCard({
    super.key,
    required this.channelName,
    required this.logoUrl, // مەرجە بدرێت بە کارتەکە
    this.isVIP = false,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1B4B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isActive ? Colors.yellow : Colors.blueAccent.withOpacity(0.3), width: isActive ? 2 : 1),
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7), // ڕەنگی باکگراوند ئەگەر لۆگۆ نەبوو
                borderRadius: BorderRadius.circular(8),
                // هێنانی وێنەکە لە ڕێگەی لینکەوە
                image: logoUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(logoUrl),
                        fit: BoxFit.cover, // وا دەکات وێنەکە بە جوانی پڕ بە بۆکسەکە بێت
                      )
                    : null,
              ),
              // ئەگەر لینکی لۆگۆ نەبوو، با تەنها ناوی کەناڵەکە بنووسێت
              child: logoUrl.isEmpty
                  ? Center(child: Text(channelName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)))
                  : null,
            ),
          ),
          const Positioned(top: 12, left: 12, child: Icon(Icons.favorite, color: Colors.white24, size: 24)),
          if (isVIP)
            Positioned(
              bottom: -1, right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: const BoxDecoration(color: Colors.yellow, borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8))),
                child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
