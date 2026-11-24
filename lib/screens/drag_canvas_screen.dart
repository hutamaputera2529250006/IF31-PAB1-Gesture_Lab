import 'package:flutter/material.dart';
import 'scale_swipe_screen.dart';

class DragCanvasScreen extends StatefulWidget {
  const DragCanvasScreen({super.key});

  @override
  State<DragCanvasScreen> createState() => _DragCanvasScreenState();
}

class _DragCanvasScreenState extends State<DragCanvasScreen> {
  static const double _startX = 40.0;
  static const double _startY = 40.0;
  static const int _maxLives = 3;

  double _posX = _startX;
  double _posY = _startY;
  bool _isDragging = false;
  int _score = 0;
  int _lives = _maxLives;

  static const double _objectSize = 72.0;
  static const double _targetSize = 110.0;
  static const double _dangerSize = 90.0;

  void _showMessage(String text, {int seconds = 1}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          duration: Duration(seconds: seconds),
        ),
      );
  }

  bool _isTouchingDanger(
      double rocketX, double rocketY, double dangerLeft, double dangerTop) {
    return rocketX < dangerLeft + _dangerSize &&
        rocketX + _objectSize > dangerLeft &&
        rocketY < dangerTop + _dangerSize &&
        rocketY + _objectSize > dangerTop;
  }

  void _handleDangerHit() {
    _posX = _startX;
    _posY = _startY;
    _lives--;

    if (_lives <= 0) {
      _lives = _maxLives;
      _score = 0;
      _showMessage('Game Over! Nyawa habis, skor di-reset.', seconds: 2);
    } else {
      _showMessage('Awas! Roket menyentuh Zona Bahaya. Sisa nyawa: $_lives',
          seconds: 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 3: Drag & Pan Canvas'),
        actions: [
          IconButton(
            tooltip: 'Ke Screen 4 (Pinch & Swipe)',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScaleSwipeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFFF1F5F9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Posisi: (${_posX.toStringAsFixed(0)}, ${_posY.toStringAsFixed(0)})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                Text(
                  _isDragging ? 'Status: Menyeret...' : 'Status: Diam',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: _isDragging ? const Color(0xFF059669) : const Color(0xFF64748B),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B365D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Skor: $_score | Nyawa: $_lives',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final maxX = constraints.maxWidth - _objectSize;
                final maxY = constraints.maxHeight - _objectSize;

                final targetLeft = constraints.maxWidth - _targetSize - 24;
                final targetTop = constraints.maxHeight - _targetSize - 24;

                final dangerLeft = (constraints.maxWidth - _dangerSize) / 2;
                final dangerTop = (constraints.maxHeight - _dangerSize) / 2;

                return Stack(
                  children: [
                    const Positioned(
                      top: 14,
                      left: 16,
                      right: 16,
                      child: Text(
                        'Seret roket ke Zona Target hijau, hindari Zona Bahaya merah!',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ),
                    Positioned(
                      left: targetLeft,
                      top: targetTop,
                      child: Container(
                        width: _targetSize,
                        height: _targetSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF059669),
                            width: 2.5,
                          ),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag_circle, color: Color(0xFF059669), size: 34),
                            SizedBox(height: 4),
                            Text(
                              'DROP ZONE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF065F46),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: dangerLeft,
                      top: dangerTop,
                      child: Container(
                        width: _dangerSize,
                        height: _dangerSize,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.red, width: 2.5),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 30),
                            SizedBox(height: 4),
                            Text(
                              'BAHAYA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: _posX,
                      top: _posY,
                      child: GestureDetector(
                        onPanStart: (_) {
                          setState(() => _isDragging = true);
                        },
                        onPanUpdate: (details) {
                          final newX = (_posX + details.delta.dx).clamp(0.0, maxX);
                          final newY = (_posY + details.delta.dy).clamp(0.0, maxY);

                          setState(() {
                            if (_isTouchingDanger(newX, newY, dangerLeft, dangerTop)) {
                              _handleDangerHit();
                            } else {
                              _posX = newX;
                              _posY = newY;
                            }
                          });
                        },
                        onPanEnd: (_) {
                          setState(() => _isDragging = false);

                          final centerX = _posX + (_objectSize / 2);
                          final centerY = _posY + (_objectSize / 2);

                          final isInsideTarget =
                              centerX >= targetLeft &&
                                  centerX <= (targetLeft + _targetSize) &&
                                  centerY >= targetTop &&
                                  centerY <= (targetTop + _targetSize);

                          if (isInsideTarget) {
                            setState(() {
                              _score += 10;
                              _posX = _startX;
                              _posY = _startY;
                            });
                            _showMessage('Tepat sasaran! +10 Poin.');
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          width: _objectSize,
                          height: _objectSize,
                          decoration: BoxDecoration(
                            color: _isDragging
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(_isDragging ? 75 : 35),
                                blurRadius: _isDragging ? 14 : 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}