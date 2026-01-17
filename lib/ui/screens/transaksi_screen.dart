import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_transaksi_screen.dart';

class TransaksiScreen extends StatefulWidget {
  final String username;
  const TransaksiScreen({super.key, required this.username});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // WARNA
  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  // FILTER
  String _selectedType = 'Semua';
  String _selectedCategory = 'Semua Kategori';
  String _search = '';

  final List<String> _types = ['Semua', 'Pengeluaran', 'Pemasukan'];

  bool isLoading = true;

  // DATA
  List<Map<String, dynamic>> transaksi = [];
  List<Map<String, dynamic>> kategoriList = [];

  @override
  void initState() {
    super.initState();
    fetchKategori();
    fetchTransaksi();
  }

  // ============================
  // FETCH SEMUA KATEGORI
  // ============================
  Future<void> fetchKategori() async {
    try {
      final data = await supabase
          .from('tbl_category')
          .select('name, type');

      setState(() {
        kategoriList = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      debugPrint('ERROR KATEGORI: $e');
    }
  }

  // ============================
  // FETCH TRANSAKSI USER
  // ============================
  Future<void> fetchTransaksi() async {
    setState(() => isLoading = true); // Pastikan loading muncul saat refresh
    try {
      final user = await supabase
          .from('tbl_user')
          .select('id')
          .eq('username', widget.username)
          .single();

      final data = await supabase
          .from('tbl_transaction')
          .select('''
            amount,
            description,
            transaction_type,
            transaction_date,
            tbl_category(name, icon)
          ''')
          .eq('user_id', user['id'])
          .order('transaction_date', ascending: false);

      setState(() {
        transaksi = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR TRANSAKSI: $e');
      setState(() => isLoading = false);
    }
  }

  // ============================
  // DROPDOWN KATEGORI SESUAI TYPE
  // ============================
  List<String> _getDropdownCategories() {
    final filtered = kategoriList.where((k) {
      if (_selectedType == 'Pengeluaran') return k['type'] == 'expense';
      if (_selectedType == 'Pemasukan') return k['type'] == 'income';
      return true;
    });

    return [
      'Semua Kategori',
      ...filtered.map((e) => e['name'] as String),
    ];
  }

  // ============================
  // FILTER + SEARCH
  // ============================
  List<Map<String, dynamic>> get filteredTransaksi {
    return transaksi.where((trx) {
      final type = trx['transaction_type'];
      final category = trx['tbl_category']['name'].toString().toLowerCase();
      final desc = (trx['description'] ?? '').toString().toLowerCase();
      final amount = trx['amount'].toString().toLowerCase();

      if (_selectedType == 'Pengeluaran' && type != 'expense') return false;
      if (_selectedType == 'Pemasukan' && type != 'income') return false;

      if (_selectedCategory != 'Semua Kategori' &&
          _selectedCategory != trx['tbl_category']['name']) {
        return false;
      }

      if (_search.isNotEmpty &&
          !category.contains(_search) &&
          !desc.contains(_search) &&
          !amount.contains(_search)) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
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
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahTransaksi(username: widget.username),
            ),
          );
          fetchTransaksi(); // Memanggil ulang data setelah kembali
        },
      ),

      body: Column(
        children: [
          // SEARCH
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

          // FILTER FULL WIDTH
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
                    items: _getDropdownCategories(),
                    onChanged: (val) =>
                        setState(() => _selectedCategory = val!),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // LIST
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTransaksi.isEmpty
                    ? const Center(
                        child: Text(
                          'Data tidak ada',
                          style:
                              TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: filteredTransaksi.map((trx) {
                          final cat = trx['tbl_category'];
                          final iconData =
                              getCategoryIcon(cat['icon'] as String?);
                          final income =
                              trx['transaction_type'] == 'income';

                          return _buildTransactionItem(
                            cat['name'],
                            trx['description'] ?? '',
                            '${income ? '+' : '-'}Rp ${trx['amount']}',
                            trx['transaction_date'],
                            iconData.icon,
                            income ? successGreen : dangerRed,
                            iconData.color,
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  // ============================
  // UI COMPONENT
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
          icon: const Icon(Icons.keyboard_arrow_down,
              color: Colors.white70),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
          onChanged: onChanged,
          items: items
              .map((val) =>
                  DropdownMenuItem(value: val, child: Text(val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTransactionItem(
    String title,
    String sub,
    String amount,
    String time,
    IconData icon,
    Color amountColor,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(sub,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount,
                  style: TextStyle(
                      color: amountColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(time,
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================
// ICON + WARNA KATEGORI
// ============================
class CategoryIcon {
  final IconData icon;
  final Color color;
  CategoryIcon(this.icon, this.color);
}

CategoryIcon getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'restaurant':
      return CategoryIcon(Icons.restaurant, Colors.orange);
    case 'wifi':
      return CategoryIcon(Icons.wifi, Colors.blue);
    case 'movie':
      return CategoryIcon(Icons.movie, Colors.purple);
    case 'shopping_bag':
      return CategoryIcon(Icons.shopping_bag, Colors.pink);
    case 'attach_money':
      return CategoryIcon(Icons.attach_money, Colors.green);
    case 'bolt':
      return CategoryIcon(Icons.bolt, Colors.yellow);
    case 'directions_car':
      return CategoryIcon(Icons.directions_car, Colors.red);
    case 'account_balance_wallet':
      return CategoryIcon(Icons.account_balance_wallet, Colors.teal);
    case 'lainnya':
      return CategoryIcon(Icons.more_horiz, Colors.grey);
    default:
      return CategoryIcon(Icons.category_outlined, Colors.grey);
  }
}