import 'package:flutter/material.dart';
import '../../services/dua_service.dart';
import 'dua_list_screen.dart';

class DuaCategoryScreen extends StatefulWidget {
  const DuaCategoryScreen({super.key});

  @override
  State<DuaCategoryScreen> createState() => _DuaCategoryScreenState();
}

class _DuaCategoryScreenState extends State<DuaCategoryScreen> {
  late final DuaService _service;
  List<DuaCategory> _allCategories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _service = DuaService();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final categories = await _service.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat data: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCategory(String title, List<String> matchSlugs) {
    if (_allCategories.isEmpty) return;

    // Filter kategori berdasarkan slug yang cocok atau tampilkan semua
    final targetCategory = _allCategories.firstWhere(
      (c) => matchSlugs.contains(c.slug),
      orElse: () => _allCategories.first, // Fallback
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DuaListScreen(category: targetCategory),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E8),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
            ? _buildError()
            : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(_errorMessage!, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCategories,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 160),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Doa & Dzikir',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D4A4A),
            ),
          ),
          const SizedBox(height: 24),

          _buildListItem(
            title: 'Doa Harian',
            subtitle: 'Kumpulan doa untuk aktivitas sehari-hari',
            icon: Icons.volunteer_activism_rounded,
            color: const Color(0xFF1A6B6B),
            onTap: () => _navigateToCategory('Doa Harian', [
              'doa-harian',
              'doa-pagi-dan-petang',
              'doa-keluarga',
              'doa-makan-dan-minum',
              'doa-bepergian',
            ]),
          ),
          _buildListItem(
            title: 'Dzikir',
            subtitle: 'Dzikir pagi dan petang sesuai sunnah',
            icon: Icons.spa_rounded,
            color: const Color(0xFFE89813),
            onTap: () => _navigateToCategory('Dzikir', ['doa-pagi-dan-petang']),
          ),
          _buildListItem(
            title: 'Panduan Sholat',
            subtitle: 'Niat dan doa dalam sholat',
            icon: Icons.mosque_rounded,
            color: const Color(0xFF4A8989),
            onTap: () => _navigateToCategory('Panduan Sholat', [
              'doa-sholat',
              'doa-qunut',
            ]),
          ),
          _buildListItem(
            title: 'Doa Setelah Sholat',
            subtitle: 'Wirid dan doa setelah sholat fardhu',
            icon: Icons.menu_book_rounded,
            color: const Color(0xFFC48C36),
            onTap: () => _navigateToCategory('Doa Setelah Sholat', [
              'doa-setelah-sholat',
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D4A4A),
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey[300],
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
