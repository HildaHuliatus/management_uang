import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TransactionProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  List<Map<String, dynamic>> _allTransactions = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get allTransactions => _allTransactions;
  bool get isLoading => _isLoading;

  // Hitung Saldo Otomatis
  double get totalSaldo {
    double incoming = 0;
    double outgoing = 0;
    for (var t in _allTransactions) {
      if (t['transaction_type'] == 'income') {
        incoming += (t['amount'] as num).toDouble();
      } else {
        outgoing += (t['amount'] as num).toDouble();
      }
    }
    return incoming - outgoing;
  }

  // Fungsi utama untuk ambil data dari mana saja
  Future<void> refreshData(String username) async {
    _isLoading = true;
    notifyListeners(); // Beritahu semua halaman untuk tampilkan loading

    try {
      final user = await _supabase
          .from('tbl_user')
          .select('id')
          .eq('username', username)
          .single();

      final data = await _supabase
          .from('tbl_transaction')
          .select('amount, transaction_type, transaction_date, description, tbl_category(name, icon)')
          .eq('user_id', user['id'])
          .order('transaction_date', ascending: false);

      _allTransactions = List<Map<String, dynamic>>.from(data);
    } catch (e) {
      debugPrint('Provider Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Beritahu semua halaman: "DATA BARU SUDAH DATANG!"
    }
  }
}