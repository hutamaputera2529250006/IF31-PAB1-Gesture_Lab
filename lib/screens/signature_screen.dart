import 'package:flutter/material.dart';

class Stroke {
  final Color color;
  final List<Offset> points;

  Stroke(this.color) : points = [];
}

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({super.key});

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final List<Stroke> _strokes = [];
  Stroke? _currentStroke;

  static const List<Color> _penColors = [
    Colors.black,
    Color(0xFF2563EB),
    Color(0xFFDC2626),
  ];
  Color _selectedColor = Colors.black;

  void _clearCanvas() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 5: Tanda Tangan Digital'),
        actions: [
          IconButton(
            tooltip: 'Hapus Kanvas',
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearCanvas,
          ),
          IconButton(
            tooltip: 'Kembali ke Beranda',
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanda tangani di dalam kotak di bawah ini:',
              style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() {
                        _currentStroke = Stroke(_selectedColor)
                          ..points.add(details.localPosition);
                        _strokes.add(_currentStroke!);
                      });
                    },
                    onPanUpdate: (details) {
                      setState(() {
                        _currentStroke?.points.add(details.localPosition);
                      });
                    },
                    onPanEnd: (_) {
                      setState(() => _currentStroke = null);
                    },
                    child: CustomPaint(
                      painter: _SignaturePainter(_strokes),
                      size: Size.infinite,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text(
                  'Warna Pena:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                ..._penColors.map((color) {
                  final isSelected = color == _selectedColor;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF1B365D)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(Icons.check, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _clearCanvas,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hapus Kanvas'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Stroke> strokes;

  _SignaturePainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          1.75,
          Paint()..color = stroke.color,
        );
        continue;
      }

      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final p in stroke.points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}