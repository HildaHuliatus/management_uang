import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  double saldo = 0;
  double pemasukan = 0;
  double pengeluaran = 0;
  
  // Pisahkan List untuk Dashboard dan Semua Transaksi
  List<Map<String, dynamic>> transaksiTerakhir = []; // Untuk Home (1 bulan)
  List<Map<String, dynamic>> semuaTransaksi = [];    // Untuk Menu Daftar Transaksi
  
  bool isLoading = false;
  String fullName = '';
  List<Map<String, dynamic>> kategoriList = [];

  Future<void> fetchDashboard(String username) async {
    isLoading = true;
    notifyListeners();

    try {
      final user = await _supabase.from('tbl_user').select().eq('username', username).single();
      fullName = user['full_name'];

      // 1. Ambil SEMUA data untuk menghitung total Saldo, Pemasukan, Pengeluaran
      final allResponse = await _supabase
          .from('tbl_transaction')
          .select('id, amount, transaction_type, transaction_date, description, tbl_category(id, name, icon)')
          .eq('user_id', user['id'])
          .order('transaction_date', ascending: false);

      final allData = List<Map<String, dynamic>>.from(allResponse);
      semuaTransaksi = allData; // Simpan untuk menu Daftar Transaksi

      // 2. Filter data untuk 1 bulan terakhir (untuk tampilan Home)
      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      transaksiTerakhir = allData.where((t) {
        final date = DateTime.parse(t['transaction_date']);
        return date.isAfter(oneMonthAgo);
      }).toList();

      // 3. Hitung Saldo (dari semua data, bukan cuma sebulan)
      double inc = 0; double out = 0;
      for (var t in allData) {
        if (t['transaction_type'] == 'income') {
          inc += (t['amount'] as num).toDouble();
        } else {
          out += (t['amount'] as num).toDouble();
        }
      }

      pemasukan = inc;
      pengeluaran = out;
      saldo = inc - out;
      
    } catch (e) {
      debugPrint("Error Provider: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchKategori() async {
    final data = await _supabase.from('tbl_category').select('name, type');
    kategoriList = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Future<void> deleteTransaction(int id, String username) async {
    try {
      await _supabase.from('tbl_transaction').delete().eq('id', id);
      await fetchDashboard(username); 
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
  }

}