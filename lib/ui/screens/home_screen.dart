import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tambah_transaksi_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;
  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  // ================= ICON =================
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
        return Icons.category_outlined;
    }
  }

  Color getCategoryColor(String? iconName) {
    switch (iconName) {
      case 'restaurant':
        return Colors.orange;
      case 'wifi':
        return Colors.blue;
      case 'movie':
        return Colors.deepPurple;
      case 'shopping_bag':
        return Colors.pink;
      case 'attach_money':
        return Colors.green;
      case 'bolt':
        return Colors.amber;
      case 'directions_car':
        return Colors.lightBlue;
      case 'account_balance_wallet':
        return Colors.teal;
      case 'lainnya':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // ================= STATE =================
  String fullName = 'Loading...';
  bool isLoading = true;

  double saldo = 0;
  double pemasukan = 0;
  double pengeluaran = 0;

  List<Map<String, dynamic>> transaksiTerakhir = [];

  // ================= UI COLOR =================
  final Color scaffoldBg = const Color(0xFF0F172A);
  final Color cardColor = const Color(0xFF1E293B);
  final Color primaryBlue = const Color(0xFF3B82F6);
  final Color successGreen = const Color(0xFF10B981);
  final Color dangerRed = const Color(0xFFEF4444);

  final NumberFormat rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();
    fetchDashboard();
  }

  // ================= FETCH =================
  Future<void> fetchDashboard() async {
    try {
      final user = await supabase
          .from('tbl_user')
          .select('id, full_name')
          .eq('username', widget.username)
          .single();

      final userId = user['id'];

      // Hitung tanggal 1 bulan yang lalu (30 hari)
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      final formattedDate = DateFormat('yyyy-MM-dd').format(oneMonthAgo);

      final transaksi = await supabase
          .from('tbl_transaction')
          .select('amount, transaction_type')
          .eq('user_id', userId);

      double totalIn = 0;
      double totalOut = 0;

      for (var t in transaksi) {
        if (t['transaction_type'] == 'income') {
          totalIn += (t['amount'] as num).toDouble();
        } else {
          totalOut += (t['amount'] as num).toDouble();
        }
      }

      final last = await supabase
          .from('tbl_transaction')
          .select(
              'amount, transaction_type, transaction_date, tbl_category(name, icon)')
          .eq('user_id', userId)
          .gte('transaction_date', formattedDate) // Filter 1 bulan terakhir
          .order('transaction_date', ascending: false);

      setState(() {
        fullName = user['full_name'];
        pemasukan = totalIn;
        pengeluaran = totalOut;
        saldo = totalIn - totalOut;
        transaksiTerakhir = List<Map<String, dynamic>>.from(last);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR DASHBOARD: $e');
      setState(() => isLoading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBg,
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TambahTransaksi(username: widget.username),
            ),
          );
          fetchDashboard();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scaffoldBg,
            elevation: 0,
            toolbarHeight: 80,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/profile.jpg'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Selamat Datang',
                        style:
                            TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(
                      isLoading ? 'Loading...' : fullName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ================= CONTENT =================
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _saldoCard(),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _infoCard('Pemasukan', rupiah.format(pemasukan),
                        successGreen, Icons.arrow_downward),
                    const SizedBox(width: 12),
                    _infoCard('Pengeluaran', rupiah.format(pengeluaran),
                        dangerRed, Icons.arrow_upward),
                  ],
                ),
                const SizedBox(height: 28),
                const Text('Transaksi Terakhir',
                    style:
                        TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 12),

                ...transaksiTerakhir.map((trx) {
                  final category = trx['tbl_category'] ?? {};
                  final iconName = category['icon'];
                  final income = trx['transaction_type'] == 'income';

                  return _transactionTile(
                    category['name'] ?? 'Lainnya',
                    rupiah.format(trx['amount']),
                    income,
                    getCategoryIcon(iconName),
                    getCategoryColor(iconName),
                    trx['transaction_date'].toString(),
                  );
                }),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ================= WIDGET =================
  Widget _saldoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
            colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Saldo',
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            rupiah.format(saldo),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _transactionTile(
    String title,
    String amount,
    bool income,
    IconData icon,
    Color iconColor,
    String date,
  ) {
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
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
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
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(date,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Text(
            income ? '+$amount' : '-$amount',
            style: TextStyle(
                color: income ? successGreen : dangerRed,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}