import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_app_1771020440/screens/auth/login_screen.dart';
import 'package:flutter_app_1771020440/screens/menu/menu_screen.dart';
import 'package:flutter_app_1771020440/screens/reservation/reservation_screen.dart';
import 'package:flutter_app_1771020440/screens/my_reservations/my_reservations_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.orange.withValues(alpha: 0.15),
                child: Icon(icon, size: 28, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant App - 1771020593'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();

              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Colors.orange, Colors.deepOrange],
                ),
              ),
              child: Row(
                children: const [
                  Icon(Icons.restaurant_menu, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Chào mừng bạn đến với ứng dụng\nquản lý & đặt bàn nhà hàng',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // MENU
            _buildCard(
              icon: Icons.restaurant,
              title: 'Xem Menu',
              subtitle: 'Danh sách món ăn & chi tiết',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MenuScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // RESERVATION
            _buildCard(
              icon: Icons.event_seat,
              title: 'Đặt Bàn',
              subtitle: 'Chọn ngày, giờ & số khách',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReservationScreen()),
                );
              },
            ),
            const SizedBox(height: 16),

            // MY RESERVATIONS
            _buildCard(
              icon: Icons.receipt_long,
              title: 'Đặt Bàn Của Tôi',
              subtitle: 'Xem & thanh toán đặt bàn',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyReservationsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
