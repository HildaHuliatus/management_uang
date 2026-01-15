import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TambahTransaksi extends StatefulWidget {
  const TambahTransaksi({super.key});

  @override
  State<TambahTransaksi> createState() => _TambahTransaksiState();
}

class _TambahTransaksiState extends State<TambahTransaksi> {
  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF1E88E5);

  bool _isPengeluaran = true;
  String _selectedCategory = 'Makanan';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();

  // --- FORMULIR KATEGORI (Sama seperti sebelumnya) ---
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

  @override
  void dispose() {
    _jumlahController.dispose();
    _customCategoryController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(primary: primaryBlue, surface: cardColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> kategoriAktif = _isPengeluaran ? _kategoriPengeluaran : _kategoriPemasukan;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text('Tambah Transaksi', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: Colors.white), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOGGLE
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildToggleItem('Pengeluaran', _isPengeluaran, () {
                        setState(() { _isPengeluaran = true; _selectedCategory = _kategoriPengeluaran[0]['nama']; });
                      }),
                      _buildToggleItem('Pemasukan', !_isPengeluaran, () {
                        setState(() { _isPengeluaran = false; _selectedCategory = _kategoriPemasukan[0]['nama']; });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 2. KATEGORI
                const Text('Pilih Kategori', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kategoriAktif.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    var item = kategoriAktif[index];
                    bool isSelected = _selectedCategory == item['nama'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = item['nama']),
                      child: _buildCategoryItem(item['icon'], item['nama'], isSelected: isSelected),
                    );
                  },
                ),

                const SizedBox(height: 20),
                if (_selectedCategory == 'Lainnya') ...[
                  const Text('Kategori', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _customCategoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Tulis kategori...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                      filled: true, fillColor: cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],

                const SizedBox(height: 25),

                // 3. INPUT JUMLAH DENGAN FORMAT UANG
                const Text('Jumlah', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(), // Memanggil formatter buatan sendiri
                  ],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text('Rp', style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    hintText: '0',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true, fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 25),

                // 4. TANGGAL
                const Text('Tanggal', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Text(DateFormat('EEEE, dd MMMM yyyy').format(_selectedDate), style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // 5. CATATAN
                const Text('Catatan', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan catatan...',
                    hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
                    filled: true, fillColor: cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),

          // TOMBOL SIMPAN
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [scaffoldBg.withOpacity(0.0), scaffoldBg]),
              ),
              child: SizedBox(
                width: double.infinity, height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Cara mengambil angka asli tanpa titik:
                    String cleanValue = _jumlahController.text.replaceAll('.', '');
                    // ignore: avoid_print
                    print("Jumlah asli: $cleanValue");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: isActive ? const Color(0xFF131C2E) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
          child: Center(child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal))),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor, borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? primaryBlue : Colors.white10, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? primaryBlue : Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}

// --- CLASS FORMATTER UANG ---
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    // Ambil angka saja
    double value = double.parse(newValue.text);
    
    // Format menjadi Rupiah dengan titik
    final formatter = NumberFormat.decimalPattern('id');
    String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}