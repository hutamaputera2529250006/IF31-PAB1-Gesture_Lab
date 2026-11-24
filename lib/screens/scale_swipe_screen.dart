import 'package:flutter/material.dart';
import 'signature_screen.dart';

class ScaleSwipeScreen extends StatefulWidget {
  const ScaleSwipeScreen({super.key});

  @override
  State<ScaleSwipeScreen> createState() => _ScaleSwipeScreenState();
}

class _ScaleSwipeScreenState extends State<ScaleSwipeScreen>
    with SingleTickerProviderStateMixin {
  static const double _swipeThreshold = 120.0;

  int _currentIndex = 0;
  double _currentScale = 1.0;
  double _baseScale = 1.0;
  double _currentRotation = 0.0;
  double _baseRotation = 0.0;

  double _dragX = 0.0;
  bool _isAnimating = false;
  int _agreeCount = 0;
  int _skipCount = 0;

  late final AnimationController _controller;

  final List<Map<String, dynamic>> _galleryItems = const [
    {
      'title': 'Eksplorasi Pegunungan',
      'tag': 'KARTU 1 / 3',
      'desc': 'Geser kartu ke kanan untuk SETUJU atau ke kiri untuk LEWATI. '
          'Dua jari untuk zoom & putar.',
      'icon': Icons.terrain,
      'color': Color(0xFF0F766E),
    },
    {
      'title': 'Arsitektur Modern',
      'tag': 'KARTU 2 / 3',
      'desc': 'Geser melewati ±120 piksel agar kartu terlempar keluar layar.',
      'icon': Icons.location_city,
      'color': Color(0xFF1D4ED8),
    },
    {
      'title': 'Observasi Antariksa',
      'tag': 'KARTU 3 / 3',
      'desc': 'Tekan tombol Reset untuk mengembalikan skala dan rotasi ke normal.',
      'icon': Icons.auto_awesome,
      'color': Color(0xFF6D28D9),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetTransform() {
    setState(() {
      _currentScale = 1.0;
      _baseScale = 1.0;
      _currentRotation = 0.0;
      _baseRotation = 0.0;
    });
  }

  void _animateDragTo(double target, {VoidCallback? onDone}) {
    final animation = Tween<double>(begin: _dragX, end: target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    void listener() {
      if (!mounted) return;
      setState(() => _dragX = animation.value);
    }

    _isAnimating = true;
    animation.addListener(listener);
    _controller.forward(from: 0).whenComplete(() {
      animation.removeListener(listener);
      if (!mounted) return;
      _isAnimating = false;
      onDone?.call();
    });
  }

  void _handleScaleStart(ScaleStartDetails details) {
    if (_isAnimating) return;
    _baseScale = _currentScale;
    _baseRotation = _currentRotation;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      if (details.pointerCount >= 2) {
        _currentScale = (_baseScale * details.scale).clamp(0.6, 2.2);
        _currentRotation = _baseRotation + details.rotation;
      } else {
        _dragX += details.focalPointDelta.dx;
      }
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    if (_isAnimating) return;

    if (_dragX.abs() >= _swipeThreshold) {
      final isAgree = _dragX > 0;
      final screenWidth = MediaQuery.of(context).size.width;

      _animateDragTo(
        isAgree ? screenWidth * 1.3 : -screenWidth * 1.3,
        onDone: () {
          setState(() {
            if (isAgree) {
              _agreeCount++;
            } else {
              _skipCount++;
            }
            _currentIndex = (_currentIndex + 1) % _galleryItems.length;
            _dragX = 0.0;
          });
          _resetTransform();
        },
      );
    } else {
      _animateDragTo(0.0);
    }
  }

  Widget _buildStamp(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 3),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = _galleryItems[_currentIndex];
    final Color cardColor = item['color'] as Color;

    final double swipeProgress =
        (_dragX.abs() / _swipeThreshold).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 4: Pinch & Swipe'),
        actions: [
          IconButton(
            tooltip: 'Ke Screen 5 (Tanda Tangan)',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SignatureScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Skala: ${_currentScale.toStringAsFixed(2)}x',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Rotasi: ${(_currentRotation * 57.2958).toStringAsFixed(0)}°',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                        onPressed: _resetTransform,
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        'Setuju: $_agreeCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF16A34A),
                        ),
                      ),
                      Text(
                        'Lewati: $_skipCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  child: Transform.translate(
                    offset: Offset(_dragX, 0),
                    child: Transform.rotate(
                      angle: _currentRotation + (_dragX / 900),
                      child: Transform.scale(
                        scale: _currentScale,
                        child: Container(
                          width: 270,
                          height: 310,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: cardColor.withAlpha(95),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white24,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        item['tag'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    Icon(
                                      item['icon'] as IconData,
                                      size: 76,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      item['title'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      item['desc'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 12.5,
                                        color: Colors.white70,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_dragX > 0)
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: Opacity(
                                    opacity: swipeProgress,
                                    child: Transform.rotate(
                                      angle: -0.2,
                                      child: _buildStamp(
                                          'SETUJU', const Color(0xFF16A34A)),
                                    ),
                                  ),
                                ),
                              if (_dragX < 0)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Opacity(
                                    opacity: swipeProgress,
                                    child: Transform.rotate(
                                      angle: 0.2,
                                      child: _buildStamp(
                                          'LEWATI', const Color(0xFFDC2626)),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_galleryItems.length, (idx) {
                      final isActive = idx == _currentIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF1B365D)
                              : const Color(0xFF94A3B8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '← LEWATI (geser kiri)  |  SETUJU (geser kanan) →',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B365D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}