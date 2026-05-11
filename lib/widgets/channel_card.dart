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
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 28.0),
            child: Center(
              child: logoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        logoUrl,
                        fit: BoxFit.contain, 
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.tv, color: Colors.grey, size: 40),
                      ),
                    )
                  : Text(
                      channelName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
              ),
              child: Text(
                channelName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          // لێرەدا ڕەنگی دڵەکەمان کرد بە پرتەقاڵی
          Positioned(
            top: 0, 
            left: 0, 
            child: IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.orange : Colors.white54, size: 22),
              onPressed: onFavoriteTap,
            )
          ),

          if (isVIP)
            Positioned(
              top: 8, 
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber, 
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [BoxShadow(color: Colors.amber.withOpacity(0.4), blurRadius: 4)]
                ),
                child: const Text('VIP', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }
}
