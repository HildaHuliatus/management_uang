import 'package:flutter/material.dart';
import 'package:management_uang/ui/provider/product_provider.dart';
import 'package:provider/provider.dart'; // 1. Import Provider
import 'tambah_transaksi_screen.dart';
import 'edit_transaksi_screen.dart';

class TransaksiScreen extends StatefulWidget {
  final String username;
  const TransaksiScreen({super.key, required this.username});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  // WARNA
  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  // FILTER (Tetap di State lokal karena hanya untuk kebutuhan UI filter di layar ini)
  String _selectedType = 'Semua';
  String _selectedCategory = 'Semua Kategori';
  String _search = '';

  final List<String> _types = ['Semua', 'Pengeluaran', 'Pemasukan'];

  @override
  void initState() {
    super.initState();
    // Panggil fetch data dari Provider saat pertama kali buka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final trxProv = context.read<TransactionProvider>();
      
      // 1. Ambil data dashboard/transaksi
      trxProv.fetchDashboard(widget.username);
      
      // 2. AMBIL DATA KATEGORI (Ini yang kurang tadi)
      trxProv.fetchKategori(); 
    });
  }

  // LOGIKA DROPDOWN KATEGORI
  List<String> _getDropdownCategories(TransactionProvider trxProv) {
    final masterKategori = trxProv.kategoriList;

    // 1. Filter berdasarkan tipe
    final filteredList = masterKategori.where((k) {
      if (_selectedType == 'Pengeluaran') return k['type'] == 'expense';
      if (_selectedType == 'Pemasukan') return k['type'] == 'income';
      return true; 
    }).map((e) => e['name'] as String).toList();

    // 2. MENGHILANGKAN DUPLIKASI NAMA
    // .toSet() akan otomatis membuang nama yang sama
    final uniqueCategories = filteredList.toSet().toList();

    // 3. Urutkan secara abjad (opsional agar rapi)
    uniqueCategories.sort();

    return ['Semua Kategori', ...uniqueCategories];
  }

  @override
  Widget build(BuildContext context) {
    // 3. Listen ke TransactionProvider
   final trxProv = context.watch<TransactionProvider>();
    // 4. Logika Filter Client-Side
    final filteredTransaksi = trxProv.semuaTransaksi.where((trx) {
      final type = trx['transaction_type'];
      final categoryName = trx['tbl_category']['name'].toString();
      final desc = (trx['description'] ?? '').toString().toLowerCase();
      final amount = trx['amount'].toString();

      // Filter Tipe
      if (_selectedType == 'Pengeluaran' && type != 'expense') return false;
      if (_selectedType == 'Pemasukan' && type != 'income') return false;

      // Filter Kategori
      if (_selectedCategory != 'Semua Kategori' && _selectedCategory != categoryName) {
        return false;
      }

      // Filter Search
      if (_search.isNotEmpty &&
          !categoryName.toLowerCase().contains(_search) &&
          !desc.contains(_search) &&
          !amount.contains(_search)) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text(
          "Daftar Transaksi",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahTransaksi(username: widget.username),
            ),
          );
        },
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              onChanged: (val) => setState(() => _search = val.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari transaksi...',
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

          // FILTER ROW
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildFilterDropdown(
                    value: _selectedType,
                    items: _types,
                    onChanged: (val) {
                      setState(() {
                        _selectedType = val!;
                        _selectedCategory = 'Semua Kategori';
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildFilterDropdown(
                    value: _selectedCategory,
                    // Gunakan fungsi baru di sini
                    items: _getDropdownCategories(trxProv), 
                    onChanged: (val) => setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LIST DATA
          Expanded(
            child: trxProv.isLoading && trxProv.semuaTransaksi.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () => trxProv.fetchDashboard(widget.username),
                    child: filteredTransaksi.isEmpty
                        ? const Center(
                            child: Text(
                              'Data tidak ditemukan',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTransaksi.length,
                            itemBuilder: (context, index) {
                              final trx = filteredTransaksi[index];
                              final cat = trx['tbl_category'];
                              final iconInfo = getCategoryIcon(cat['icon']);
                              final isIncome = trx['transaction_type'] == 'income';

                              return Dismissible(
                                key: Key(trx['id'].toString()),
                                direction: DismissDirection.endToStart,
                                confirmDismiss: (direction) async {
                                  // Tambahkan konfirmasi hapus jika perlu
                                  return true;
                                },
                                onDismissed: (direction) {
                                  context.read<TransactionProvider>().deleteTransaction(trx['id'], widget.username);
                                },
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditTransaksi(
                                          username: widget.username,
                                          existingTrx: trx,
                                        ),
                                      ),
                                    );
                                  },
                                  child: _buildTransactionItem(
                                    cat['name'],
                                    trx['description'] ?? '',
                                    '${isIncome ? '+' : '-'}Rp ${trx['amount']}',
                                    trx['transaction_date'].toString(),
                                    iconInfo.icon,
                                    isIncome ? successGreen : dangerRed,
                                    iconInfo.color,
                                  ),
                                ),
                              );
                              
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  // ============================
  // UI COMPONENTS
  // ============================
  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    final safeValue = items.contains(value) ? value : items.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: safeValue.contains('Semua') ? cardColor : primaryBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: safeValue,
          dropdownColor: cardColor,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title, String sub, String amount, String time,
    IconData icon, Color amountColor, Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(
                      sub, // Ini adalah deskripsi
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                      maxLines: 2, // Ubah dari 1 ke 2 atau lebih
                      overflow: TextOverflow.visible, // Biarkan teks turun jika panjang
                    ),              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(color: amountColor, fontWeight: FontWeight.bold)),
              Text(time, style: const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// HELPER UNTUK ICON
class CategoryIcon {
  final IconData icon;
  final Color color;
  CategoryIcon(this.icon, this.color);
}

CategoryIcon getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'restaurant': return CategoryIcon(Icons.restaurant, Colors.orange);
    case 'wifi': return CategoryIcon(Icons.wifi, Colors.blue);
    case 'movie': return CategoryIcon(Icons.movie, Colors.purple);
    case 'shopping_bag': return CategoryIcon(Icons.shopping_bag, Colors.pink);
    case 'attach_money': return CategoryIcon(Icons.attach_money, Colors.green);
    case 'bolt': return CategoryIcon(Icons.bolt, Colors.yellow);
    case 'directions_car': return CategoryIcon(Icons.directions_car, Colors.red);
    case 'account_balance_wallet': return CategoryIcon(Icons.account_balance_wallet, Colors.teal);
    default: return CategoryIcon(Icons.more_horiz, Colors.grey);
  }
}