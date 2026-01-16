import 'package:flutter/material.dart';
import 'dart:math';

class LaporanScreen extends StatelessWidget {
  const LaporanScreen({super.key});

  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Laporan Statistik",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined, color: Colors.white, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
           
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF131C2F),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTimeTab("Mingguan", false),
                  _buildTimeTab("Bulanan", true),
                  _buildTimeTab("Tahunan", false),
                ],
              ),
            ),
            const SizedBox(height: 32),

            
            const Text(
              "TOTAL PENGELUARAN",
              style: TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 1.2),
            ),
            const SizedBox(height: 8),
            const Text(
              "Rp 5.500.000",
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),

            
            SizedBox(
              height: 220,
              width: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(220, 220),
                    painter: DoughnutChartPainter(),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text("Mei", style: TextStyle(color: Colors.white54, fontSize: 14)),
                      Text("-5%", style: TextStyle(color: Colors.blueAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("vs bln lalu", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "BREAKDOWN KATEGORI",
                style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
            ),
            const SizedBox(height: 16),

            
            _buildCategoryRow("Makanan & Minuman", "45% dari total", "Rp 2.475.000", "+12%", Icons.restaurant, Colors.blue, true),
            _buildCategoryRow("Transportasi", "20% dari total", "Rp 1.100.000", "-4%", Icons.directions_car, Colors.teal, false),
            _buildCategoryRow("Hiburan", "15% dari total", "Rp 825.000", "Tetap", Icons.movie, Colors.orange, null),
            _buildCategoryRow("Lain-lain", "20% dari total", "Rp 1.100.000", "+2%", Icons.more_horiz, Colors.deepPurple, true),

            const SizedBox(height: 16),

           
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                // ignore: deprecated_member_use
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blueAccent),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text("Sisa anggaran bulan ini", style: TextStyle(color: Colors.white, fontSize: 14)),
                  ),
                  const Text("Rp 1.450.000", style: TextStyle(color: Colors.blueAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_download_outlined),
                label: const Text("Unduh Laporan PDF", style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,       
                  foregroundColor: Colors.white,     
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTab(String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E293B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.white38,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String title, String subtitle, String amount, String trend, IconData icon, Color color, bool? isUp) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            // ignore: deprecated_member_use
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  if (isUp != null)
                    Icon(isUp ? Icons.trending_up : Icons.trending_down, size: 12, color: isUp ? Colors.red : Colors.green),
                  const SizedBox(width: 4),
                  Text(trend, style: TextStyle(color: isUp == null ? Colors.white38 : (isUp ? Colors.red : Colors.green), fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class DoughnutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

   
    _drawArc(canvas, center, radius, -pi / 2, pi * 0.9, Colors.blue, paint);
    _drawArc(canvas, center, radius, pi * 0.4, pi * 0.4, Colors.teal, paint);
    _drawArc(canvas, center, radius, pi * 0.8, pi * 0.3, Colors.orange, paint);
    _drawArc(canvas, center, radius, pi * 1.1, pi * 0.4, Colors.purpleAccent, paint);
  }

  void _drawArc(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Color color, Paint paint) {
    paint.color = color;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius - 10), startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}