import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../widgets/channel_card.dart';
import '../widgets/ad_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

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
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 45,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2235),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            hintText: 'گەڕان بۆ کەناڵ...',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search, color: Colors.orange),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 2),
                      ),
                      child: const Icon(Icons.tv, color: Colors.orange, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                CarouselSlider(
                  options: CarouselOptions(
                    height: 160.0,
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enableInfiniteScroll: true,
                    autoPlayAnimationDuration: const Duration(milliseconds: 800),
                    viewportFraction: 1.0,
                  ),
                  items: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.blueAccent),
                        color: const Color(0xFF1A2235),
                      ),
                      child: const Center(
                        child: Text(
                          'وێنەی ڕیکلامی سەرەکی (Kurdish Media Hub)',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                    Container(width: 20, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.orange)),
                    Container(width: 8, height: 8, margin: const EdgeInsets.symmetric(horizontal: 4), decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('وەرزشی'),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) {
                    List<String> channels = ['beIN SPORTS 3', 'beIN SPORTS 2', 'beIN SPORTS 1', 'beIN SPORTS 6', 'beIN SPORTS 5', 'beIN SPORTS 4'];
                    return ChannelCard(
                      channelName: channels[index],
                      isVIP: index == 2, // beIN SPORTS 1 دەبێتە VIP
                      isActive: index == 2, // beIN SPORTS 1 دەبێتە هەڵبژێردراو
                    );
                  },
                ),
                const SizedBox(height: 20),
                const AdContainer(
                  title: 'Hey Tuya at CES 2026',
                  description: 'Explore Hey Tuya\'s AI smart home platform...',
                ),
                const SizedBox(height: 20),
                _buildSectionHeader('هەواڵەکان'),
                const SizedBox(height: 15),
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
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'سەرەتا'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'دڵخواز'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'هەژمار'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'سێتینگ'),
          BottomNavigationBarItem(icon: Icon(Icons.tv), label: 'TV Mode'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          ),
          child: const Text('زیاتر ببینە >', style: TextStyle(color: Colors.blueAccent)),
        )
      ],
    );
  }
}
