import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:management_uang/ui/provider/product_provider.dart';

class LaporanScreen extends StatefulWidget {
  final String username;
  const LaporanScreen({super.key, required this.username});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    // Panggil data saat halaman dibuka
    Future.microtask(() =>
      // ignore: use_build_context_synchronously
      context.read<TransactionProvider>().fetchLaporan(widget.username)
    );
  }

  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final laporan = provider.dataLaporanTerolah;
    final currencyFormat = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text("Statistik Pengeluaran", 
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: provider.isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.blue))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTimeTabSelector(),
                const SizedBox(height: 32),
                const Text("TOTAL PENGELUARAN", style: TextStyle(color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Text(currencyFormat.format(provider.pengeluaran),
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                
                // Chart Section
                SizedBox(
                  height: 220, width: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(220, 220),
                        painter: DoughnutChartPainter(data: laporan),
                      ),
                      const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("Bulan Ini", style: TextStyle(color: Colors.white54)),
                          Icon(Icons.analytics_outlined, color: Colors.blueAccent, size: 30),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text("BREAKDOWN KATEGORI", 
                    style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 16),

                if (laporan.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text("Belum ada data pengeluaran", style: TextStyle(color: Colors.white24)),
                  )
                else
                  Column(
                    children: laporan.map((item) => _buildCategoryRow(item, currencyFormat)).toList(),
                  ),

                const SizedBox(height: 24),
                _buildDownloadButton(),
              ],
            ),
          ),
    );
  }

  Widget _buildTimeTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFF131C2F), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: ["Mingguan", "Bulanan", "Tahunan"].map((e) {
          bool active = e == "Bulanan";
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: active ? cardColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(e, style: TextStyle(color: active ? Colors.white : Colors.white38))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> item, NumberFormat format) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item['color'].withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(item['icon'], color: item['color'], size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(item['subtitle'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          Text(format.format(item['amount']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.file_download_outlined),
        label: const Text("Unduh Laporan PDF"),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red, foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}

class DoughnutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  DoughnutChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.butt;

    double startAngle = -math.pi / 2;

    for (var item in data) {
      final double fraction = (item['fraction'] as num).toDouble();
      if (fraction <= 0) continue;

      paint.color = item['color'];
      final sweepAngle = fraction * 2 * math.pi;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
