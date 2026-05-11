import 'package:flutter/material.dart';

class ChannelCard extends StatelessWidget {
  final String channelName;
  final String logoUrl;
  final bool isVIP;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;

  const ChannelCard({
    super.key,
    required this.channelName,
    required this.logoUrl,
    this.isVIP = false,
    this.isFavorite = false,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              children: [
                // بەشی سەرەوە بۆ وێنەکە کە خۆی دەگونجێنێت
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    alignment: Alignment.center,
                    child: logoUrl.isNotEmpty
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.contain, 
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.tv, color: Colors.grey, size: 40),
                          )
                        : Text(
                            channelName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                // بەشی خوارەوە بۆ ناوەکە
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                  ),
                  child: Text(
                    channelName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            Positioned(
              top: -4, 
              left: -4, 
              child: IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.orange : Colors.white54, size: 20),
                onPressed: onFavoriteTap,
              )
            ),

            if (isVIP)
              Positioned(
                top: 6, 
                right: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber, 
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
