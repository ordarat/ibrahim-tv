import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  int _currentSliderIndex = 0; 
  List<String> _favorites = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_channels') ?? [];
    });
  }

  Future<void> _toggleFavorite(String channelName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(channelName)) {
        _favorites.remove(channelName);
      } else {
        _favorites.add(channelName);
      }
      prefs.setStringList('favorite_channels', _favorites);
    });
  }

  void _autoScroll() {
    if (_pageController.hasClients && _sliderCount > 1) {
      int nextPage = _pageController.page!.toInt() + 1;
      if (nextPage >= _sliderCount) nextPage = 0;
      _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
    if (mounted) Future.delayed(const Duration(seconds: 4), _autoScroll);
  }

  @override
  void dispose() { _pageController.dispose(); super.dispose(); }

  Widget _buildAdBanner() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('ads').doc('banner').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
        var adData = snapshot.data!.data() as Map<String, dynamic>;
        if (adData['image_url'] == null || adData['image_url'].toString().isEmpty) return const SizedBox();

        return Container(
          height: 80,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1B4B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5),
            image: DecorationImage(image: NetworkImage(adData['image_url']), fit: BoxFit.cover)
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildHomeContent() : _buildFavoritesContent(),
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
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'دڵخوازەکان'),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(color: const Color(0xFF1A2235), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                      decoration: const InputDecoration(
                        hintText: 'گەڕان بۆ کەناڵ...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Colors.orange), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                      )
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(2), 
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2)), 
                  child: ClipOval(
                    child: Image.asset(
                      'assets/logo.png', 
                      width: 32, 
                      height: 32, 
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.tv, color: Colors.orange, size: 28),
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            if (_searchQuery.isEmpty) ...[
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('sliders').orderBy('created_at', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const SizedBox();
                  var sliders = snapshot.data!.docs;
                  _sliderCount = sliders.length;

                  return Column(
                    children: [
                      SizedBox(
                        height: 160.0,
                        child: PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) => setState(() => _currentSliderIndex = index),
                          itemCount: sliders.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), image: DecorationImage(image: NetworkImage(sliders[index]['image_url']), fit: BoxFit.cover)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(sliders.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: _currentSliderIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentSliderIndex == index ? Colors.orange : Colors.orange.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('channels').orderBy('created_at', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('هیچ کەناڵێک بوونی نییە', style: TextStyle(color: Colors.grey)));

                var allChannels = snapshot.data!.docs;
                var filteredChannels = allChannels.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  String name = (data['name'] ?? '').toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredChannels.isEmpty) return const Center(child: Padding(padding: EdgeInsets.only(top: 40.0), child: Text('هیچ کەناڵێک نەدۆزرایەوە', style: TextStyle(color: Colors.grey, fontSize: 16))));

                Map<String, List<DocumentSnapshot>> groupedChannels = {};
                for (var doc in filteredChannels) {
                  var data = doc.data() as Map<String, dynamic>;
                  String category = data['category'] ?? 'گشتی';
                  if (!groupedChannels.containsKey(category)) groupedChannels[category] = [];
                  groupedChannels[category]!.add(doc);
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: groupedChannels.keys.length,
                  itemBuilder: (context, index) {
                    String categoryName = groupedChannels.keys.elementAt(index);
                    List<DocumentSnapshot> categoryChannels = groupedChannels[categoryName]!;

                    bool hasMore = categoryChannels.length > 6;
                    var displayChannels = hasMore && _searchQuery.isEmpty ? categoryChannels.sublist(0, 6) : categoryChannels;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader(categoryName, hasMore && _searchQuery.isEmpty, () {
                          var channelMaps = categoryChannels.map((e) => e.data() as Map<String, dynamic>).toList();
                          Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryScreen(categoryName: categoryName, channels: channelMaps)));
                        }),
                        const SizedBox(height: 15),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          // لێرەدا قەبارەکەمان گۆڕی بۆ 0.70 بۆ ئەوەی تێکەڵ نەبن
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.70),
                          itemCount: displayChannels.length,
                          itemBuilder: (context, gridIndex) {
                            var channelData = displayChannels[gridIndex].data() as Map<String, dynamic>;
                            String cName = channelData['name'] ?? '';
                            return GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(channelName: cName, streamUrl: channelData['stream_url'] ?? ''))),
                              child: ChannelCard(
                                channelName: cName, logoUrl: channelData['logo_url'] ?? '', isVIP: channelData['is_vip'] ?? false, isFavorite: _favorites.contains(cName), onFavoriteTap: () => _toggleFavorite(cName),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 15),
                        if (index == 0 && _searchQuery.isEmpty) _buildAdBanner(),
                        if (index == 0 && _searchQuery.isEmpty) const SizedBox(height: 15),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('کەناڵە دڵخوازەکانم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 20),
          Container(
            height: 45,
            decoration: BoxDecoration(color: const Color(0xFF1A2235), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.blueAccent.withOpacity(0.3))),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
              decoration: const InputDecoration(hintText: 'گەڕان لە دڵخوازەکان...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, prefixIcon: Icon(Icons.search, color: Colors.orange), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10))
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('channels').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.orange));
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('هیچ کەناڵێک بوونی نییە', style: TextStyle(color: Colors.grey)));

                var favChannels = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  bool isFav = _favorites.contains(data['name']);
                  bool matchesSearch = (data['name'] ?? '').toLowerCase().contains(_searchQuery);
                  return isFav && matchesSearch;
                }).toList();

                if (favChannels.isEmpty) return Center(child: Text(_searchQuery.isEmpty ? 'هیچ کەناڵێکت نەکردووە بە دڵخواز' : 'هیچ کەناڵێک نەدۆزرایەوە', style: const TextStyle(color: Colors.grey, fontSize: 16)));

                return GridView.builder(
                  // لێرەشدا قەبارەکەمان گۆڕی بۆ 0.70
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.70),
                  itemCount: favChannels.length,
                  itemBuilder: (context, index) {
                    var channelData = favChannels[index].data() as Map<String, dynamic>;
                    String cName = channelData['name'] ?? '';
                    return GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(channelName: cName, streamUrl: channelData['stream_url'] ?? ''))),
                      child: ChannelCard(channelName: cName, logoUrl: channelData['logo_url'] ?? '', isVIP: channelData['is_vip'] ?? false, isFavorite: true, onFavoriteTap: () => _toggleFavorite(cName)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool showSeeMore, VoidCallback? onSeeMore) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
        if (showSeeMore)
          OutlinedButton(
            onPressed: onSeeMore, 
            style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), 
            child: const Text('زیاتر ببینە >', style: TextStyle(color: Colors.blueAccent))
          )
      ],
    );
  }
}

class CategoryScreen extends StatefulWidget {
  final String categoryName;
  final List<Map<String, dynamic>> channels;

  const CategoryScreen({super.key, required this.categoryName, required this.channels});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<String> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorite_channels') ?? [];
    });
  }

  Future<void> _toggleFavorite(String channelName) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_favorites.contains(channelName)) {
        _favorites.remove(channelName);
      } else {
        _favorites.add(channelName);
      }
      prefs.setStringList('favorite_channels', _favorites);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('کەناڵەکانی ${widget.categoryName}', style: const TextStyle(color: Colors.orange)),
        backgroundColor: const Color(0xFF1A2235),
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // لێرەشدا قەبارەکەمان گۆڕی بۆ 0.70
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.70
              ),
              itemCount: widget.channels.length,
              itemBuilder: (context, index) {
                var channelData = widget.channels[index];
                String cName = channelData['name'] ?? '';
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => PlayerScreen(channelName: cName, streamUrl: channelData['stream_url'] ?? ''))),
                  child: ChannelCard(
                    channelName: cName, 
                    logoUrl: channelData['logo_url'] ?? '', 
                    isVIP: channelData['is_vip'] ?? false,
                    isFavorite: _favorites.contains(cName),
                    onFavoriteTap: () => _toggleFavorite(cName),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
