import 'package:flutter/material.dart';
import 'tambah_transaksi_screen.dart'; // Pastikan file ini ada di project Anda

class TransaksiScreen extends StatefulWidget {
  const TransaksiScreen({super.key});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  // Warna Tema
  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  // State untuk Filter
  String _selectedType = 'Semua';
  String _selectedCategory = 'Semua Kategori';

  final List<String> _types = ['Semua', 'Pengeluaran', 'Pemasukan'];

  // Data Kategori Sesuai Permintaan
  final List<Map<String, dynamic>> _kategoriPengeluaran = [
    {'nama': 'Makanan', 'icon': Icons.restaurant},
    {'nama': 'Transport', 'icon': Icons.directions_car},
    {'nama': 'Belanja', 'icon': Icons.shopping_bag},
    {'nama': 'Kesehatan', 'icon': Icons.medical_services},
    {'nama': 'Tagihan', 'icon': Icons.receipt_long},
    {'nama': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  final List<Map<String, dynamic>> _kategoriPemasukan = [
    {'nama': 'Gaji', 'icon': Icons.payments},
    {'nama': 'Bonus', 'icon': Icons.card_giftcard},
    {'nama': 'Investasi', 'icon': Icons.trending_up},
    {'nama': 'Hadiah', 'icon': Icons.redeem},
    {'nama': 'Tabungan', 'icon': Icons.account_balance_wallet},
    {'nama': 'Lainnya', 'icon': Icons.more_horiz},
  ];

  // Fungsi untuk mendapatkan list kategori secara dinamis
  List<String> _getDropdownCategories() {
    List<String> list = ['Semua Kategori'];
    if (_selectedType == 'Pengeluaran') {
      list.addAll(_kategoriPengeluaran.map((e) => e['nama'] as String));
    } else if (_selectedType == 'Pemasukan') {
      list.addAll(_kategoriPemasukan.map((e) => e['nama'] as String));
    } else {
      // Jika 'Semua', gabungkan semua kategori unik
      var allNames = {
        ..._kategoriPengeluaran.map((e) => e['nama'] as String),
        ..._kategoriPemasukan.map((e) => e['nama'] as String)
      };
      list.addAll(allNames);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      
      // ===== APP BAR =====
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Daftar Transaksi",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        
      ),

      // ===== FLOATING ACTION BUTTON =====
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTransaksi()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      body: Column(
        children: [
          // 1. SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Cari transaksi...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white38),
                filled: true,
                fillColor: cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 2. FILTER DROPDOWNS (CHIPS STYLE)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // Filter Tipe
                _buildFilterDropdown(
                  value: _selectedType,
                  items: _types,
                  onChanged: (val) {
                    setState(() {
                      _selectedType = val!;
                      _selectedCategory = 'Semua Kategori'; // Reset kategori saat tipe berubah
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Filter Kategori (Dinamis)
                _buildFilterDropdown(
                  value: _selectedCategory,
                  items: _getDropdownCategories(),
                  onChanged: (val) {
                    setState(() => _selectedCategory = val!);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. DAFTAR TRANSAKSI
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader("Hari Ini", "-Rp 145.000", isExpense: true),
                _buildTransactionItem("Makan Siang", "Makan di McD Sarinah", "-Rp 85.000", "12:30", Icons.restaurant, dangerRed),
                _buildTransactionItem("Transportasi", "Grab Car ke Kantor", "-Rp 60.000", "08:15", Icons.directions_car, dangerRed),
                
                const SizedBox(height: 24),
                _buildSectionHeader("Kemarin", "+Rp 4.850.000", isExpense: false),
                _buildTransactionItem("Gaji Bulanan", "Transfer Gaji PT Jaya", "+Rp 5.000.000", "10:00", Icons.payments, successGreen),
                _buildTransactionItem("Belanja", "Supermarket Indomaret", "-Rp 150.000", "19:45", Icons.shopping_bag, dangerRed),

                const SizedBox(height: 80), // Padding bawah agar tidak tertutup FAB
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Dropdown bergaya Chip
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    // Memastikan value tetap valid dalam list items
    String safeValue = items.contains(value) ? value : items.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: safeValue.contains('Semua') ? cardColor : primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: safeValue,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
          dropdownColor: cardColor,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(
              value: val,
              child: Text(val),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget Helper: Header Tanggal
  Widget _buildSectionHeader(String title, String total, {required bool isExpense}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text(
            "TOTAL: $total",
            style: TextStyle(
              // ignore: deprecated_member_use
              color: isExpense ? Colors.white38 : successGreen.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Helper: Baris Transaksi
  Widget _buildTransactionItem(String title, String sub, String amount, String time, IconData icon, Color amountColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF0F172A).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: primaryBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: amountColor, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}