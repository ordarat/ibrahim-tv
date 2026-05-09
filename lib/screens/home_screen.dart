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
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.all(8), 
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.orange, width: 2)), 
                      child: const Icon(Icons.tv, color: Colors.orange, size: 24)
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // وێنەی ڕیکلامی جێگیر (لەبری سڵایدەر کە کێشەی دروست کردبوو)
                Container(
                  height: 160.0,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15), 
                    border: Border.all(color: Colors.blueAccent), 
                    color: const Color(0xFF1A2235)
                  ), 
                  child: const Center(
                    child: Text('Kurdish Media Hub', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))
                  )
                ),
                const SizedBox(height: 20),
                
                _buildSectionHeader('وەرزشی'),
                const SizedBox(height: 15),
                
                // هێنانی کەناڵەکان لە فایەربەیسەوە
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('channels').orderBy('created_at', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Colors.orange));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('هیچ کەناڵێک بوونی نییە', style: TextStyle(color: Colors.grey)));
                    }

                    var channels = snapshot.data!.docs;

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, 
                        crossAxisSpacing: 12, 
                        mainAxisSpacing: 12, 
                        childAspectRatio: 0.85
                      ),
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
        OutlinedButton(
          onPressed: () {}, 
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          ), 
          child: const Text('زیاتر ببینە >', style: TextStyle(color: Colors.blueAccent))
        )
      ],
    );
  }
}
