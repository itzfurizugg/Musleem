import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'city_picker_screen.dart';
import 'prayer_schedule_screen.dart';
import '../services/prayer_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      if (mounted) {
        final prefs = await SharedPreferences.getInstance();
        final cityId = prefs.getInt('selected_city_id');
        final cityName = prefs.getString('selected_city_name');

        _controller.reverse().then((_) {
          if (mounted) {
            if (cityId != null && cityName != null) {
              // Jika sudah ada kota yang dipilih, langsung ke Jadwal Sholat
              // Kita buat objek City minimal karena screen hanya butuh id & name & province
              // Province dan Timezone bisa kita ambil dari prefs juga jika kita simpan tadi
              final city = City(
                id: cityId,
                name: cityName,
                province: prefs.getString('selected_city_province') ?? '',
                timezone:
                    prefs.getString('selected_city_timezone') ?? 'Asia/Jakarta',
              );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => PrayerScheduleScreen(city: city),
                ),
              );
            } else {
              // Jika belum ada, ke pilih kota
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CityPickerScreen()),
              );
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF003231)),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/splash.png',
                    width: 450,
                    height: 650,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cruelty_free_outlined,
                      size: 120,
                      color: Color(0xFFF5F0DC),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
