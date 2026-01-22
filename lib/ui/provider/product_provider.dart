import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import 'dart:math';

class TransactionProvider with ChangeNotifier {
  final _supabase = Supabase.instance.client;

  double saldo = 0;
  double pemasukan = 0;
  double pengeluaran = 0;
  
  List<Map<String, dynamic>> transaksiTerakhir = []; 
  List<Map<String, dynamic>> semuaTransaksi = [];    
  
  bool isLoading = false;
  String fullName = '';
  List<Map<String, dynamic>> kategoriList = [];
  List<Map<String, dynamic>> dataLaporanTerolah = [];

  // --- Helper: Icon Kategori ---
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

  // --- Helper: Warna Kategori ---
  Color getCategoryColor(String? iconName) {
    switch (iconName) {
      case 'restaurant': return Colors.orange;
      case 'wifi': return Colors.blue;
      case 'movie': return Colors.deepPurple;
      case 'shopping_bag': return Colors.pink;
      case 'attach_money': return Colors.green;
      case 'bolt': return Colors.amber;
      case 'directions_car': return Colors.lightBlue;
      case 'account_balance_wallet': return Colors.teal;
      default: return Colors.grey;
    }
  }

  Future<void> fetchDashboard(String username, {bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final user = await _supabase.from('tbl_user').select().eq('username', username).single();
      fullName = user['full_name'];

      final allResponse = await _supabase
          .from('tbl_transaction')
          .select('id, amount, transaction_type, transaction_date, description, tbl_category(id, name, icon)')
          .eq('user_id', user['id'])
          .order('transaction_date', ascending: false);

      final allData = List<Map<String, dynamic>>.from(allResponse);
      semuaTransaksi = allData; 

      final oneMonthAgo = DateTime.now().subtract(const Duration(days: 30));
      transaksiTerakhir = allData.where((t) {
        final date = DateTime.parse(t['transaction_date']);
        return date.isAfter(oneMonthAgo);
      }).toList();

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
      if (!silent) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> fetchKategori() async {
    final data = await _supabase.from('tbl_category').select('name, type');
    kategoriList = List<Map<String, dynamic>>.from(data);
    notifyListeners();
  }

  Future<void> deleteTransaction(dynamic id, String username) async {
    try {
      await _supabase
          .from('tbl_transaction')
          .delete()
          .eq('id', id.toString()); 

      await refreshAll(username);
      debugPrint("Berhasil menghapus UUID: $id");
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
  }

  // Variabel baru untuk menyimpan hasil olahan laporan
  

  Future<void> fetchLaporan(String username, {bool silent = false}) async {
    if (!silent) {
      isLoading = true;
      notifyListeners();
    }

    dataLaporanTerolah = [];

    try {
      final user = await _supabase.from('tbl_user').select('id').eq('username', username).single();
      
      final response = await _supabase
          .from('tbl_transaction')
          .select('amount, tbl_category(name, icon)')
          .eq('user_id', user['id'])
          .eq('transaction_type', 'expense');

      final rawData = List<Map<String, dynamic>>.from(response);

      Map<String, double> groupedData = {};
      Map<String, String?> categoryIcons = {};
      double totalPengeluaranLaporan = 0;

      for (var t in rawData) {
        final cat = t['tbl_category'];
        final String name = cat != null ? cat['name'] : 'Lain-lain';
        final double amount = (t['amount'] as num).toDouble();

        totalPengeluaranLaporan += amount;
        groupedData[name] = (groupedData[name] ?? 0) + amount;
        categoryIcons[name] = cat != null ? cat['icon'] : null;
      }

      // Perbaikan Sorting: Pastikan casting ke num agar compareTo berfungsi
      var resultList = groupedData.entries.map((entry) {
        final iconStr = categoryIcons[entry.key];
        double fraction = totalPengeluaranLaporan > 0 ? (entry.value / totalPengeluaranLaporan) : 0;
        
        return {
          'title': entry.key,
          'amount': entry.value, // Ini double
          'fraction': fraction,
          'subtitle': "${(fraction * 100).toStringAsFixed(0)}% dari total",
          'icon': getCategoryIcon(iconStr),
          'color': getCategoryColor(iconStr),
        };
      }).toList();

      // Memperbaiki error .compareTo dengan casting eksplisit
      resultList.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

      dataLaporanTerolah = resultList;
      pengeluaran = totalPengeluaranLaporan;

    } catch (e) {
      debugPrint("Error Laporan: $e");
    } finally {
      if (!silent) {
        isLoading = false;
        notifyListeners();
      }
    }
  } 

  Future<void> refreshAll(String username) async {
    isLoading = true;
    notifyListeners();

    try {
      await fetchDashboard(username, silent: true);
      await fetchLaporan(username, silent: true);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

}

