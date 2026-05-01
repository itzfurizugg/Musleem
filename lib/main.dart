import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'services/prayer_notif_service.dart';
import 'screen/splash_screen.dart';
import 'screen/auth/login.dart';
import 'screen/auth/register.dart';
import 'screen/home.dart';
import 'screen/city_picker_screen.dart';
import 'screen/dua/dua_category_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi timezone database
  tz.initializeTimeZones();

  await Supabase.initialize(
    url: 'https://ryyahvjonscodfcmjaaf.supabase.co',
    anonKey: 'sb_publishable_gRefHEE_JHWhY7XoVIVjmg_6CsTB_xM',
  );

  // Inisialisasi notification plugin & minta izin
  await PrayerNotifService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = GoogleFonts.dmSansTextTheme();
    return MaterialApp(
      title: 'MuslimNoob',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F0E8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6B6B)),
        useMaterial3: true,
        textTheme: base.copyWith(
          displayLarge: GoogleFonts.poppins(textStyle: base.displayLarge),
          displayMedium: GoogleFonts.poppins(textStyle: base.displayMedium),
          displaySmall: GoogleFonts.poppins(textStyle: base.displaySmall),
          headlineLarge: GoogleFonts.poppins(textStyle: base.headlineLarge),
          headlineMedium: GoogleFonts.poppins(textStyle: base.headlineMedium),
          headlineSmall: GoogleFonts.poppins(textStyle: base.headlineSmall),
          titleLarge: GoogleFonts.poppins(textStyle: base.titleLarge),
          titleMedium: GoogleFonts.poppins(textStyle: base.titleMedium),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomeScreen(),
        '/city-picker': (context) => const CityPickerScreen(),
        '/dua': (context) => const DuaCategoryScreen(),
      },
    );
  }
}
