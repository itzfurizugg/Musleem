import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/prayer_service.dart';
import 'city_picker_screen.dart';
import 'prayer_schedule_screen.dart';
import 'qibla_screen.dart';
import 'profile.dart';
import 'dua/dua_category_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;
  City? _selectedCity;

  @override
  void initState() {
    super.initState();
    _checkSavedCity();
  }

  Future<void> _checkSavedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final cityId = prefs.getInt('selected_city_id');
    final cityName = prefs.getString('selected_city_name');
    final cityProvince = prefs.getString('selected_city_province') ?? '';
    final cityTimezone =
        prefs.getString('selected_city_timezone') ?? 'Asia/Jakarta';

    if (cityId != null && cityName != null) {
      if (mounted) {
        setState(() {
          _selectedCity = City(
            id: cityId,
            name: cityName,
            province: cityProvince,
            timezone: cityTimezone,
          );
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CityPickerScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F0E8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1A6B6B)),
        ),
      );
    }

    if (_selectedCity == null) return const SizedBox.shrink();

    final List<Widget> tabs = [
      PrayerScheduleScreen(city: _selectedCity!, isTab: true),
      const QiblaScreen(),
      const DuaCategoryScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true, // Biar liquid navbar kelihatan ngambang di atas konten
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: tabs),
          Positioned(
            left: 0,
            right: 0,
            bottom:
                MediaQuery.of(context).padding.bottom +
                24, // Melayang dengan jarak
            child: Align(
              alignment: Alignment.bottomCenter,
              child: _buildLiquidNavbar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidNavbar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: Container(
          height: 64, // Sedikit lebih tinggi untuk touch target
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFFBFAF8).withOpacity(
              0.7,
            ), // Mengurangi opacity agar blur (glass effect) lebih terlihat
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                // Shadow kedua untuk penekanan lebih dalam
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize
                .min, // Navbar berbentuk pill yang menyesuaikan lebar anak-anaknya
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Beranda'),
              const SizedBox(width: 4),
              _buildNavItem(1, Icons.explore_rounded, 'Kiblat'),
              const SizedBox(width: 4),
              _buildNavItem(2, Icons.book_rounded, 'Doa'),
              const SizedBox(width: 4),
              _buildNavItem(3, Icons.person_rounded, 'Profil'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final primaryColor = const Color(0xFF1A6B6B);
    final selectedBgColor = primaryColor;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? selectedBgColor : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : primaryColor.withOpacity(0.5),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
