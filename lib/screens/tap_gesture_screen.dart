import 'package:flutter/material.dart';
import 'drag_canvas_screen.dart';

class TapGestureScreen extends StatefulWidget {
  const TapGestureScreen({super.key});

  @override
  State<TapGestureScreen> createState() => _TapGestureScreenState();
}

class _TapGestureScreenState extends State<TapGestureScreen> {
  int _tapCount = 0;
  bool _isLiked = false;
  int _colorIndex = 0;
  String _lastGesture = 'Belum ada sentuhan';
  final List<String> _logs = [];

  final List<Color> _cardColors = const [
    Color(0xFF2563EB),
    Color(0xFF0D9488),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
  ];

  void _addLog(String eventName) {
    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}:'
        '${now.second.toString().padLeft(2, '0')}';
    setState(() {
      _lastGesture = eventName;
      _logs.insert(0, '[$timeStr] $eventName');
      if (_logs.length > 8) {
        _logs.removeLast();
      }
    });
  }

  void _handleSingleTap() {
    setState(() {
      _tapCount++;
      _colorIndex = (_colorIndex + 1) % _cardColors.length;
    });
    _addLog('onTap → Warna diubah (Total Tap: $_tapCount)');
  }

  void _handleDoubleTap() {
    setState(() {
      _isLiked = !_isLiked;
    });
    _addLog(_isLiked
        ? 'onDoubleTap → Ditandai Favorit (Liked)'
        : 'onDoubleTap → Batal Favorit (Unliked)');
  }

  void _handleLongPress() {
    setState(() {
      _tapCount = 0;
      _colorIndex = 0;
      _isLiked = false;
    });
    _addLog('onLongPress → Status di-reset ke awal');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Long Press terdeteksi: Counter & warna di-reset!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _cardColors[_colorIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screen 2: Tap & Long Press'),
        actions: [
          IconButton(
            tooltip: 'Ke Screen 3 (Drag Canvas)',
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DragCanvasScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _handleSingleTap,
              onDoubleTap: _handleDoubleTap,
              onLongPress: _handleLongPress,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: activeColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withAlpha(90),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: _isLiked ? 1.25 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isLiked ? Icons.favorite : Icons.touch_app,
                        color: _isLiked ? Colors.redAccent.shade100 : Colors.white,
                        size: 58,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jumlah Ketukan: $_tapCount',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Status: $_lastGesture',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Tap: Ganti Warna | Double Tap: Like | Long Press: Reset',
                        style: TextStyle(fontSize: 11.5, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Log Callback Real-Time:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _logs.clear()),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Bersihkan'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: _logs.isEmpty
                    ? const Center(
                        child: Text(
                          'Sentuh kotak di atas untuk melihat urutan eksekusi callback...',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _logs.length,
                        separatorBuilder: (_, __) => const Divider(height: 10),
                        itemBuilder: (context, index) {
                          return Text(
                            _logs[index],
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12.5,
                              color: Color(0xFF1E293B),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}