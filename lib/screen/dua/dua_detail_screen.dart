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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      appBar: AppBar(
        title: Text(
          dua.title,
          style: const TextStyle(
            color: Color(0xFF0D4A4A),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0D4A4A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, color: Color(0xFF1A6B6B)),
            tooltip: 'Salin doa',
            onPressed: () {
              final text =
                  '${dua.arabicText}\n\n${dua.transliteration}\n\n${dua.translation}';
              _copyToClipboard(context, text);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Judul doa
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A6B6B),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                dua.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                      color: Colors.black.withOpacity(0.04),
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

            // Tombol salin
            OutlinedButton.icon(
              onPressed: () {
                final text =
                    '${dua.arabicText}\n\n${dua.transliteration}\n\n${dua.translation}';
                _copyToClipboard(context, text);
              },
              icon: const Icon(Icons.copy, size: 18),
              label: const Text('Salin Doa'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1A6B6B),
                side: const BorderSide(color: Color(0xFF1A6B6B)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 40),
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
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
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
