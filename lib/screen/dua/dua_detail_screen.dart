import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/dua_service.dart';

class DuaDetailScreen extends StatelessWidget {
  final Dua dua;

  const DuaDetailScreen({super.key, required this.dua});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Doa disalin ke clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF1A6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildGlassButton({
    required VoidCallback onPressed,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.35),
                  Colors.white.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Color(0xFF0D4A4A),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              child: IconTheme(
                data: const IconThemeData(color: Color(0xFF0D4A4A), size: 16),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: glass back button + tombol salin ─────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back_ios_new, size: 16),
                        SizedBox(width: 6),
                        Text('Kembali'),
                      ],
                    ),
                  ),
                  _buildGlassButton(
                    onPressed: () {
                      final text =
                          '${dua.arabicText}\n\n${dua.transliteration}\n\n${dua.translation}';
                      _copyToClipboard(context, text);
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_all_rounded, size: 18),
                        SizedBox(width: 6),
                        Text('Salin'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Judul doa gaya homepage
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                dua.title,
                style: const TextStyle(
                  color: Color(0xFF0D4A4A),
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  height: 1.3,
                ),
              ),
            ),

            // ── Konten ───────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Teks Arab
                    _buildSection(
                      label: 'Arab',
                      icon: Icons.translate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Text(
                          dua.arabicText,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 2.2,
                            color: Color(0xFF0D4A4A),
                            fontFamily: 'serif',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Latin / Transliterasi
                    _buildSection(
                      label: 'Latin',
                      icon: Icons.format_quote,
                      child: _buildTextCard(
                        text: dua.transliteration,
                        color: const Color(0xFF0D4A4A),
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Terjemahan
                    _buildSection(
                      label: 'Artinya',
                      icon: Icons.menu_book_outlined,
                      child: _buildTextCard(
                        text: '"${dua.translation}"',
                        color: Colors.grey[800]!,
                        fontSize: 15,
                      ),
                    ),

                    // Sumber (kalau ada)
                    if (dua.source != null && dua.source!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildSection(
                        label: 'Sumber',
                        icon: Icons.info_outline,
                        child: _buildTextCard(
                          text: dua.source!,
                          color: Colors.grey[600]!,
                          fontSize: 13,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF1A6B6B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A6B6B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTextCard({
    required String text,
    required Color color,
    required double fontSize,
    FontStyle fontStyle = FontStyle.normal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          height: 1.7,
          fontStyle: fontStyle,
        ),
      ),
    );
  }
}
