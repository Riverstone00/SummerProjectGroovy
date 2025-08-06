import 'package:flutter/material.dart';
import 'package:flutter/src/material/colors.dart';

void main() {
  runApp(const MaterialApp(
    home: GuestMyPage(),
    debugShowCheckedModeBanner: false,
  ));
}

class GuestMyPage extends StatelessWidget {
  const GuestMyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFDF6FB),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'My Page',
          style: TextStyle(
            color: Colors.pink,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.pink.shade100,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(width: 20),
                const Expanded(
                  child: Text(
                    '로그인을 해주세요.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(thickness: 1, color: Colors.pinkAccent),
            const SizedBox(height: 24),
            const Text(
              '로그인하여 더 많은 기능을 사용해보세요!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
