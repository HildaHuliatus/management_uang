import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:management_uang/ui/provider/product_provider.dart';
import 'package:provider/provider.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';

class TambahTransaksi extends StatefulWidget {
  final String username;

  const TambahTransaksi({
    super.key,
    required this.username,
  });

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
  bool _isSaving = false; 

  String _selectedCategory = '';
  DateTime _selectedDate = DateTime.now();

  final TextEditingController _jumlahController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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
    _descriptionController.dispose();
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
        _selectedCategory = expense.isNotEmpty ? expense.first['nama'] : '';
        _loadingKategori = false;
      });
    } catch (e) {
      debugPrint('ERROR FETCH KATEGORI: $e');
      setState(() => _loadingKategori = false);
    }
  }

  Future<void> _simpanTransaksi() async {
    final cleanAmount = _jumlahController.text.replaceAll('.', '');
    if (cleanAmount.isEmpty || cleanAmount == '0') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jumlah tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = await supabase
          .from('tbl_user')
          .select('id')
          .eq('username', widget.username)
          .single();

      final category = await supabase
          .from('tbl_category')
          .select('id')
          .eq('name', _selectedCategory)
          .eq('type', _isPengeluaran ? 'expense' : 'income')
          .single();

      await supabase.from('tbl_transaction').insert({
        'user_id': user['id'],
        'category_id': category['id'],
        'amount': double.parse(cleanAmount),
        'description': _descriptionController.text,
        'transaction_type': _isPengeluaran ? 'expense' : 'income',
        'transaction_date': DateFormat('yyyy-MM-dd').format(_selectedDate),
      });

      if (mounted) {
        await context.read<TransactionProvider>().refreshAll(widget.username);
        
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaksi berhasil disimpan')),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('ERROR INSERT: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan transaksi')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final kategoriAktif = _isPengeluaran ? _kategoriPengeluaran : _kategoriPemasukan;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        title: const Text('Tambah Transaksi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      _buildToggleItem('Pengeluaran', _isPengeluaran, () {
                        setState(() {
                          _isPengeluaran = true;
                          if (_kategoriPengeluaran.isNotEmpty) _selectedCategory = _kategoriPengeluaran.first['nama'];
                        });
                      }),
                      _buildToggleItem('Pemasukan', !_isPengeluaran, () {
                        setState(() {
                          _isPengeluaran = false;
                          if (_kategoriPemasukan.isNotEmpty) _selectedCategory = _kategoriPemasukan.first['nama'];
                        });
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                // Category Selector
                const Text('Pilih Kategori', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                if (_loadingKategori)
                  const Center(child: CircularProgressIndicator())
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: kategoriAktif.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final item = kategoriAktif[index];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = item['nama']),
                        child: _buildCategoryItem(item['icon'], item['nama'], isSelected: _selectedCategory == item['nama']),
                      );
                    },
                  ),
                const SizedBox(height: 25),
                // Input Fields
                _buildLabel('Jumlah'),
                TextField(
                  controller: _jumlahController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, CurrencyInputFormatter()],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  decoration: _inputDecoration(prefix: 'Rp'),
                ),
                const SizedBox(height: 20),
                _buildLabel('Tanggal'),
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
                const SizedBox(height: 20),
                _buildLabel('Deskripsi'),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(hint: 'Contoh: Makan siang'),
                ),
              ],
            ),
          ),
          // Bottom Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _simpanTransaksi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSaving 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan Transaksi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(color: Colors.grey)),
  );

  InputDecoration _inputDecoration({String? prefix, String? hint}) {
    return InputDecoration(
      prefixIcon: prefix != null ? Padding(padding: const EdgeInsets.all(15), child: Text(prefix, style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, fontSize: 18))) : null,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: cardColor,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }

  Widget _buildToggleItem(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF131C2E) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(label, style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItem(IconData icon, String label, {bool isSelected = false}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isSelected ? primaryBlue : Colors.white10, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.blueGrey, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}

IconData getCategoryIcon(String? iconName) {
  switch (iconName) {
    case 'restaurant': return Icons.restaurant;
    case 'wifi': return Icons.wifi;
    case 'movie': return Icons.movie;
    case 'shopping_bag': return Icons.shopping_bag;
    case 'attach_money': return Icons.attach_money;
    case 'bolt': return Icons.bolt;
    case 'directions_car': return Icons.directions_car;
    case 'account_balance_wallet': return Icons.account_balance_wallet;
    default: return Icons.more_horiz;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final value = double.parse(newValue.text);
    final formatter = NumberFormat.decimalPattern('id');
    final newText = formatter.format(value);
    return newValue.copyWith(text: newText, selection: TextSelection.collapsed(offset: newText.length));
  }
}