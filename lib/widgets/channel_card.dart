import 'package:flutter/material.dart';

class ChannelCard extends StatelessWidget {
  final String channelName;
  final String logoUrl;
  final bool isVIP;
  final bool isActive;
  final bool isFavorite; // دیاریکردنی ئەوەی ئایا دڵخوازە
  final VoidCallback? onFavoriteTap; // فەرمانی کاتی کلیک کردن لەسەر دڵەکە

  const ChannelCard({
    super.key,
    required this.channelName,
    required this.logoUrl,
    this.isVIP = false,
    this.isActive = false,
    this.isFavorite = false,
    this.onFavoriteTap,
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
                color: const Color(0xFF673AB7),
                borderRadius: BorderRadius.circular(8),
                image: logoUrl.isNotEmpty ? DecorationImage(image: NetworkImage(logoUrl), fit: BoxFit.cover) : null,
              ),
              child: logoUrl.isEmpty
                  ? Center(child: Text(channelName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)))
                  : null,
            ),
          ),
          
          // دوگمەی دڵخواز
          Positioned(
            top: 0, left: 0, 
            child: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.white70, size: 24),
              onPressed: onFavoriteTap,
            )
          ),

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
