import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/channel_card.dart';
import 'player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  int _sliderCount = 0;

  @override
  void initState() {
    super.initState();
    // ئۆتۆماتیکی سوڕانەوەی سڵایدەرەکە
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  void _autoScroll() {
    if (_pageController.hasClients && _sliderCount > 1) {
      int nextPage = _pageController.page!.toInt() + 1;
      if (nextPage >= _sliderCount) nextPage = 0;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    if (mounted) {
      Future.delayed(const Duration(seconds: 4), _autoScroll);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // گەڕان
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(color: const Color(0xFF1A2235), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                        child: const TextField(decoration: InputDecoration(hintText: 'گەڕان بۆ کەناڵ...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Colors.orange), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10))),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2)), child: const Icon(Icons.tv, color: Colors.orange, size: 24)),
                  ],
                ),
                const SizedBox(height: 20),
                
                // ١. بەشی سڵایدەری داینامیک
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('sliders').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                    
                    var sliders = snapshot.data!.docs;
                    _sliderCount = sliders.length; // ژمارەی سڵایدەرەکان وەرئەگرین بۆ ئۆتۆ سکڕۆڵەکە

                    return SizedBox(
                      height: 160.0,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: sliders.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15), 
                              image: DecorationImage(image: NetworkImage(sliders[index]['image_url']), fit: BoxFit.cover)
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 15),

                // ٢. شریتی ڕیکلام (Ads Banner) کە ڕێک لەناو بۆکسێکدایە
                StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance.collection('ads').doc('banner').snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
                    
                    var adData = snapshot.data!.data() as Map<String, dynamic>;
                    if (adData['image_url'] == null || adData['image_url'].toString().isEmpty) return const SizedBox();

                    return Container(
                      height: 70, // بەرزی شریتی ڕیکلامەکە
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
                        image: DecorationImage(image: NetworkImage(adData['image_url']), fit: BoxFit.cover)
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                
                _buildSectionHeader('وەرزشی'),
                const SizedBox(height: 15),
                
                // ٣. هێنانی کەناڵەکان لە فایەربەیسەوە
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('channels').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('هیچ کەناڵێک بوونی نییە', style: TextStyle(color: Colors.grey)));

                    var channels = snapshot.data!.docs;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85),
                      itemCount: channels.length,
                      itemBuilder: (context, index) {
                        var channelData = channels[index].data() as Map<String, dynamic>;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(channelName: channelData['name'] ?? 'کەناڵ', streamUrl: channelData['stream_url'] ?? '')));
                          },
                          child: ChannelCard(
                            channelName: channelData['name'] ?? '', 
                            logoUrl: channelData['logo_url'] ?? '', 
                            isVIP: channelData['is_vip'] ?? false
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF0A0F18),
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'سەرەتا'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'دڵخواز'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV Mode'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
        OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('زیاتر ببینە >', style: TextStyle(color: Colors.blueAccent)))
      ],
    );
  }
}
