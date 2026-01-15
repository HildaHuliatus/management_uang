import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_transaksi_screen.dart';
import 'package:intl/intl.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

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
        return Icons.more_horiz;

      default:
        return Icons.category_outlined; // fallback aman
    }
  }

  // ignore: non_constant_identifier_names
  String full_name = "Loading...";
  bool isLoading = true;

  double saldo = 0;
  double pemasukan = 0;
  double pengeluaran = 0;

  List<Map<String, dynamic>> transaksiTerakhir = [];

  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  // ================= FETCH SEMUA DATA =================
  Future<void> fetchDashboard() async {
    try {
      // ===== 1. AMBIL USER =====
      final user = await supabase
          .from('tbl_user')
          .select('id, full_name')
          .single();

      final userId = user['id'];

      // ===== 2. AMBIL SEMUA TRANSAKSI (UNTUK TOTAL) =====
      final allTransaksi = await supabase
          .from('tbl_transaction')
          .select('amount, transaction_type')
          .eq('user_id', userId);

      double totalIn = 0;
      double totalOut = 0;

      for (var t in allTransaksi) {
        if (t['transaction_type'] == 'income') {
          totalIn += (t['amount'] as num).toDouble();
        } else {
          totalOut += (t['amount'] as num).toDouble();
        }
      }

      // ===== 3. TRANSAKSI 1 BULAN TERAKHIR =====
      final DateTime oneMonthAgo =
          DateTime.now().subtract(const Duration(days: 30));

      final lastTransaksi = await supabase
          .from('tbl_transaction')
          .select(
              'amount, transaction_type, transaction_date, tbl_category(name, icon)')
          .eq('user_id', userId)
          .gte(
            'transaction_date',
            oneMonthAgo.toIso8601String().split('T').first,
          )
          .order('transaction_date', ascending: false)
          .limit(5);

      // ===== 4. SET STATE =====
      setState(() {
        full_name = user['full_name'];
        pemasukan = totalIn;
        pengeluaran = totalOut;
        saldo = totalIn - totalOut;
        transaksiTerakhir =
            List<Map<String, dynamic>>.from(lastTransaksi);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR DASHBOARD: $e");
      setState(() {
        full_name = "Gagal ambil user";
        isLoading = false;
      });
    }
  }

  final NumberFormat rupiahFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );


  // ================= UI (TIDAK DIUBAH) =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,

      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () async {
          print("Tombol diklik!");
          // Navigasi dilakukan secara independen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TambahTransaksi()),
          );
          
          // Refresh data setelah kembali dari halaman tambah
          fetchDashboard();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),

      body: CustomScrollView(
        slivers: [

          // ===== HEADER =====
          SliverAppBar(
            pinned: true,
            backgroundColor: scaffoldBg,
            elevation: 0,
            toolbarHeight: 80,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.blueGrey,
                      backgroundImage:
                          AssetImage('assets/images/profile.jpg'),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Selamat Datang,",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          isLoading ? "Loading..." : full_name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // ===== CONTENT =====
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ===== SALDO =====
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D4ED8),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Saldo",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        //"Rp ${saldo.toStringAsFixed(0)}",
                        rupiahFormat.format(saldo),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ===== RINGKASAN =====
                Row(
                  children: [
                    _infoCard(
                      "Pemasukan",
                      //"Rp ${pemasukan.toStringAsFixed(0)}",
                      rupiahFormat.format(pemasukan),

                      successGreen,
                      Icons.arrow_downward,
                    ),
                    const SizedBox(width: 12),
                    _infoCard(
                      "Pengeluaran",
                      //"Rp ${pengeluaran.toStringAsFixed(0)}",
                      rupiahFormat.format(pengeluaran),

                      dangerRed,
                      Icons.arrow_upward,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ===== TRANSAKSI TERAKHIR =====
                const Text(
                  "Transaksi Terakhir",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                ...transaksiTerakhir.map((trx) {
                  final income = trx['transaction_type'] == 'income';

                  final category = trx['tbl_category'];
                  final iconName = category['icon'];

                  return _transactionTile(
                    category['name'],
                    rupiahFormat.format(trx['amount']),
                    income,
                    getCategoryIcon(iconName),
                    trx['transaction_date'],
                  );

                }),

                const SizedBox(height: 12),
              ]),
              
            ),
          ),
        ],
      ),
    );
  }

  // ===== INFO CARD =====
  static Widget _infoCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== TRANSACTION TILE =====
  Widget _transactionTile(String title, String amount, bool income,
      IconData icon, String date) {
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: scaffoldBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            income ? "+$amount" : "-$amount",
            style: TextStyle(
              color: income ? successGreen : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
