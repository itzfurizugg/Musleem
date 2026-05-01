import 'dart:ui';
import 'package:flutter/material.dart';
import '../../services/tutorial_service.dart';

class PanduanSholatScreen extends StatefulWidget {
  const PanduanSholatScreen({super.key});

  @override
  State<PanduanSholatScreen> createState() => _PanduanSholatScreenState();
}

class _PanduanSholatScreenState extends State<PanduanSholatScreen> {
  late final TutorialService _service;
  List<TutorialStep> _steps = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _service = TutorialService();
    _pageController = PageController();
    _loadPanduanSholat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPanduanSholat() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final tutorial = await _service.getTutorialBySlug('panduan-sholat');
      if (tutorial == null) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Tutorial Panduan Sholat tidak ditemukan.';
            _isLoading = false;
          });
        }
        return;
      }
      final steps = await _service.getSteps(tutorial.id);
      if (mounted) {
        setState(() {
          _steps = steps;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat panduan: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _buildGlassButton(
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
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Text(
                'Panduan Sholat',
                style: TextStyle(
                  color: Color(0xFF0D4A4A),
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  height: 1.3,
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPanduanSholat,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A6B6B),
              foregroundColor: Colors.white,
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_steps.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada konten', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final step = _steps[index];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFFE89813,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Langkah ${step.stepNumber} / ${_steps.length}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFFE89813),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D4A4A),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (step.imagePath != null &&
                          step.imagePath!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            step.imagePath!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SizedBox.shrink(),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (step.arabicText != null &&
                          step.arabicText!.isNotEmpty) ...[
                        Text(
                          step.arabicText!,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontSize: 26,
                            height: 2.2,
                            color: Color(0xFF0D4A4A),
                            fontFamily: 'serif',
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (step.transliteration != null &&
                          step.transliteration!.isNotEmpty) ...[
                        Text(
                          step.transliteration!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (step.description != null &&
                          step.description!.isNotEmpty) ...[
                        const Divider(height: 32),
                        Text(
                          step.description!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF333333),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _buildBottomNavigation(),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: const Icon(Icons.arrow_back_ios_new, size: 16),
              label: const Text('Sebelumnya'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A6B6B),
                disabledForegroundColor: Colors.grey[400],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPage == index
                            ? const Color(0xFFE89813)
                            : Colors.grey[300],
                      ),
                    );
                  }),
                ),
              ),
            ),
            TextButton(
              onPressed: _currentPage < _steps.length - 1 ? _nextPage : null,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1A6B6B),
                disabledForegroundColor: Colors.grey[400],
              ),
              child: const Row(
                children: [
                  Text('Selanjutnya'),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
