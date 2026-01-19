import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> fetchDashboard(String username) async {
    isLoading = true;
    notifyListeners();

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
      isLoading = false;
      notifyListeners();
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

      await fetchDashboard(username);
      debugPrint("Berhasil menghapus UUID: $id");
    } catch (e) {
      debugPrint("Error Delete: $e");
    }
  }

}