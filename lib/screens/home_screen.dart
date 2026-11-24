import 'package:flutter/material.dart';
import 'tap_gesture_screen.dart';
import 'drag_canvas_screen.dart';
import 'scale_swipe_screen.dart';
import 'signature_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _showModulePreview(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF2563EB)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(detail, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GesturLab — Menu Praktikum'),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TapGestureScreen()),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Eksplorasi Widget GestureDetector',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B365D),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '• Ketuk (Tap) kartu untuk membuka layar praktikum.\n'
                      '• Tekan lama (Long Press) kartu untuk pratinjau materi.\n'
                      '• Usap layar ke kiri (Swipe Left) untuk pintasan ke Screen 2.',
                      style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Daftar Screen Praktikum (5 Screen Aktif)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    _buildMenuCard(
                      context: context,
                      number: 'SCREEN 2',
                      title: 'Tap, Double Tap & Long Press',
                      subtitle: 'Deteksi ketukan tunggal, ganda, tekanan lama & log peristiwa.',
                      icon: Icons.touch_app,
                      accentColor: const Color(0xFF2563EB),
                      previewDetail:
                          'Screen 2 mendemonstrasikan cara GestureDetector membedakan '
                          'onTap, onDoubleTap, dan onLongPress melalui mekanisme Gesture Arena.',
                      destination: const TapGestureScreen(),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      number: 'SCREEN 3',
                      title: 'Kanvas Drag & Drop (Pan Gesture)',
                      subtitle: 'Menyeret objek bebas (onPanUpdate) ke zona target.',
                      icon: Icons.open_with,
                      accentColor: const Color(0xFF059669),
                      previewDetail:
                          'Screen 3 memanfaatkan onPanStart, onPanUpdate, dan onPanEnd '
                          'untuk memindahkan posisi widget berdasarkan koordinat delta (dx, dy).',
                      destination: const DragCanvasScreen(),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      number: 'SCREEN 4',
                      title: 'Pinch-to-Zoom & Swipe Galeri',
                      subtitle: 'Skala dua jari (onScaleUpdate) & usap antar kartu.',
                      icon: Icons.pinch,
                      accentColor: const Color(0xFFD97706),
                      previewDetail:
                          'Screen 4 menggabungkan onScaleUpdate untuk memperbesar dan memutar '
                          'kartu serta onHorizontalDragEnd untuk navigasi galeri.',
                      destination: const ScaleSwipeScreen(),
                    ),
                    const SizedBox(height: 12),
                    _buildMenuCard(
                      context: context,
                      number: 'SCREEN 5',
                      title: 'Kanvas Tanda Tangan Digital',
                      subtitle: 'Menggambar coretan jari (onPan + CustomPainter) dengan 3 warna pena.',
                      icon: Icons.draw,
                      accentColor: const Color(0xFF7C3AED),
                      previewDetail:
                          'Screen 5 menggunakan onPanStart, onPanUpdate, dan onPanEnd '
                          'untuk merekam titik-titik sentuhan, lalu CustomPainter menggambarnya '
                          'sebagai garis coretan.',
                      destination: const SignatureScreen(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String number,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String previewDetail,
    required Widget destination,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
      onLongPress: () => _showModulePreview(context, title, previewDetail),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0D000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accentColor.withAlpha(28),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}