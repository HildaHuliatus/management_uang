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

  void _showTransactionDetail(BuildContext context, Map<String, dynamic> trx, String username) {
    final cat = trx['tbl_category'];
    final iconInfo = getCategoryIcon(cat['icon']);
    final isIncome = trx['transaction_type'] == 'income';

    showModalBottomSheet(
      context: context,
      backgroundColor: cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle Bar Atas
              Container(
                width: 40,
                height: 4,
                // Perbaikan di baris ini:
                margin: const EdgeInsets.only(bottom: 20), 
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header Detail
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: iconInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(iconInfo.icon, color: iconInfo.color, size: 30),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cat['name'],
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          trx['transaction_date'],
                          style: const TextStyle(color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isIncome ? '+' : '-'} Rp ${trx['amount']}',
                    style: TextStyle(
                      color: isIncome ? successGreen : dangerRed,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(color: Colors.white10),
              const SizedBox(height: 10),
              
              // Bagian Deskripsi
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Catatan:", style: TextStyle(color: Colors.white38, fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(
                      trx['description'] ?? '-',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),

              // Tombol Aksi
              Row(
                children: [
                  // Tombol Delete
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: dangerRed),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        debugPrint("DEBUG DETAIL: ID = ${trx['id']} | Tipe = ${trx['id'].runtimeType}");
                        Navigator.pop(context); // Tutup modal
                        _confirmDelete(context, trx['id'], username);
                      },
                      icon: Icon(Icons.delete_outline, color: dangerRed),
                      label: Text("Hapus", style: TextStyle(color: dangerRed)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Tombol Update
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Tutup modal
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTransaksi(
                              username: username,
                              existingTrx: trx,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Cari fungsi ini di TransaksiScreen dan ubah:
void _confirmDelete(BuildContext context, dynamic id, String username) {
  debugPrint("DEBUG CONFIRM: ID asli = $id | Tipe asli = ${id.runtimeType}");
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: cardColor,
      title: const Text("Hapus Transaksi?", style: TextStyle(color: Colors.white)),
      content: const Text("Data yang dihapus tidak dapat dikembalikan.", style: TextStyle(color: Colors.white70)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal", style: TextStyle(color: Colors.white38)),
        ),
        TextButton(
          onPressed: () {
            // LANGSUNG panggil tanpa int.parse
            context.read<TransactionProvider>().deleteTransaction(id, username);
            Navigator.pop(context);
          },
          child: Text("Hapus", style: TextStyle(color: dangerRed)),
        ),
      ],
    ),
  );
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
                                  // Langsung kirim id apa adanya
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
                                    _showTransactionDetail(context, trx, widget.username);
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

