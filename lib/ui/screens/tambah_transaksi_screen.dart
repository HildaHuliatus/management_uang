import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahTransaksi extends StatefulWidget {
  const TambahTransaksi({super.key});

  @override
  State<TambahTransaksi> createState() => _TambahTransaksiState();
}

class _TambahTransaksiState extends State<TambahTransaksi> {
  final SupabaseClient supabase = Supabase.instance.client;

  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF1E88E5);

  bool _isPengeluaran = true;
  bool _loadingKategori = true;

  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _customCategoryController =
      TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController(); 

  List<Map<String, dynamic>> _kategoriPengeluaran = [];
  List<Map<String, dynamic>> _kategoriPemasukan = [];

  @override
  void initState() {
    super.initState();
    fetchKategori();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _customCategoryController.dispose();
    _descriptionController.dispose(); // ✅
    super.dispose();
  }

  Future<void> fetchKategori() async {
    try {
      final data = await supabase
          .from('tbl_category')
          .select('name, type, icon')
          .order('name');

      final expense = <Map<String, dynamic>>[];
      final income = <Map<String, dynamic>>[];

      for (var item in data) {
        final map = {
          'nama': item['name'],
          'icon': getCategoryIcon(item['icon']),
        };

        if (item['type'] == 'expense') {
          expense.add(map);
        } else if (item['type'] == 'income') {
          income.add(map);
        }
      }

      setState(() {
        _kategoriPengeluaran = expense;
        _kategoriPemasukan = income;
        _selectedCategory =
            expense.isNotEmpty ? expense.first['nama'] : '';
        _loadingKategori = false;
      });
    } catch (e) {
      debugPrint('ERROR FETCH KATEGORI: $e');
      setState(() => _loadingKategori = false);
    }
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
            colorScheme:
                ColorScheme.dark(primary: primaryBlue, surface: cardColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final kategoriAktif =
        _isPengeluaran ? _kategoriPengeluaran : _kategoriPemasukan;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text(
          'Tambah Transaksi',
          style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 140),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _buildToggleItem('Pengeluaran', _isPengeluaran, () {
                        setState(() {
                          _isPengeluaran = true;
                          if (_kategoriPengeluaran.isNotEmpty) {
                            _selectedCategory =
                                _kategoriPengeluaran.first['nama'];
                          }
                        });
                      }),
                      _buildToggleItem('Pemasukann', !_isPengeluaran, () {
                        setState(() {
                          _isPengeluaran = false;
                          if (_kategoriPemasukan.isNotEmpty) {
                            _selectedCategory =
                                _kategoriPemasukan.first['nama'];
                          }
                        });
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'Pilih Kategori',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),

                if (_loadingKategori)
                  const Center(child: CircularProgressIndicator())
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kategoriAktif.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = kategoriAktif[index];
                      final isSelected =
                          _selectedCategory == item['nama'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCategory = item['nama']),
                        child: _buildCategoryItem(
                          item['icon'],
                          item['nama'],
                          isSelected: isSelected,
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                const Text('Jumlah', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CurrencyInputFormatter(),
                  ],
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        'Rp',
                        style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    hintText: '0',
                    hintStyle: const TextStyle(color: Colors.white24),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text('Tanggal', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today,
                            color: primaryBlue, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('EEEE, dd MMMM yyyy')
                              .format(_selectedDate),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                const Text('Deskripsi', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Contoh: Makan siang di kantor',
                    hintStyle:
                        const TextStyle(color: Colors.white24, fontSize: 14),
                    filled: true,
                    fillColor: cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    // ignore: deprecated_member_use
                    scaffoldBg.withOpacity(0.0),
                    scaffoldBg
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                     
                      final user = await supabase
                          .from('tbl_user')
                          .select('id')
                          .single();

                      final userId = user['id'];

                      final category = await supabase
                      .from('tbl_category')
                      .select('id')
                      .eq('name', _selectedCategory)
                      .eq(
                        'type',
                        _isPengeluaran ? 'expense' : 'income',
                      )
                      .single();


                      final categoryId = category['id'];

                      final cleanAmount =
                          _jumlahController.text.replaceAll('.', '');

                      if (cleanAmount.isEmpty) {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Jumlah tidak boleh kosong')),
                        );
                        return;
                      }

                      await supabase.from('tbl_transaction').insert({
                        'user_id': userId,
                        'category_id': categoryId,
                        'amount': double.parse(cleanAmount),
                        'description': _descriptionController.text,
                        'transaction_type':
                            _isPengeluaran ? 'expense' : 'income',
                        'transaction_date':
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                      });

                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transaksi berhasil disimpan')),
                      );

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    } catch (e) {
                      debugPrint('ERROR INSERT TRANSAKSI: $e');
                      // ignore: use_build_context_synchronously
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal menyimpan transaksi')),
                      );
                    }
                  },


                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Simpan Transaksi',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem(
      String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isActive ? const Color(0xFF131C2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey,
                  fontWeight:
                      isActive ? FontWeight.bold : FontWeight.normal),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label,
      {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
            color: isSelected ? primaryBlue : Colors.white10,
            width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon,
              color: isSelected ? primaryBlue : Colors.white, size: 28),
          const SizedBox(height: 8),
          Text(label,
              style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey,
                  fontSize: 12)),
        ],
      ),
    );
  }
}

IconData getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'restaurant':
      return Icons.restaurant;
    case 'wifi':
      return Icons.wifi;
    case 'movie':
      return Icons.movie;
    case 'shopping_bag':
      return Icons.shopping_bag;
    case 'attach_money':
      return Icons.attach_money;
    case 'bolt':
      return Icons.bolt;
    case 'directions_car':
      return Icons.directions_car;
    case 'account_balance_wallet':
      return Icons.account_balance_wallet;
    case 'lainnya':
      return Icons.more_horiz
;
    default:
      return Icons.category;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) return newValue;

    final value = double.parse(newValue.text);
    final formatter = NumberFormat.decimalPattern('id');
    final newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
