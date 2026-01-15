import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _minuman = [];
  List<Map<String, dynamic>> _makanan = [];
  List<Map<String, dynamic>> _dessert = [];

  bool isLoading = false;

  // =====================
  // FETCH DATA SUPABASE
  // =====================
  Future<void> fetchProducts() async {
    isLoading = true;
    notifyListeners();

    final response = await supabase.from('products').select();

    _minuman = response
        .where((p) => p['category'] == 'minuman')
        .map(_mapProduct)
        .toList();

    _makanan = response
        .where((p) => p['category'] == 'makanan')
        .map(_mapProduct)
        .toList();

    _dessert = response
        .where((p) => p['category'] == 'dessert')
        .map(_mapProduct)
        .toList();

    isLoading = false;
    notifyListeners();
  }

  // Tambahkan quantity default
  Map<String, dynamic> _mapProduct(dynamic p) {
    return {
      "id": p["id"],
      "image": p["image"],
      "name": p["name"],
      "price": "Rp. ${p["price"]}",
      "deskripsi": p["deskripsi"],
      "quantity": 0,
      "category": p["category"],
    };
  }

  // =====================
  // GETTER
  // =====================
  List<Map<String, dynamic>> get minuman => _minuman;
  List<Map<String, dynamic>> get makanan => _makanan;
  List<Map<String, dynamic>> get dessert => _dessert;

  // =====================
  // QUANTITY (TIDAK BERUBAH)
  // =====================
  void increment(int index) {
    _minuman[index]["quantity"]++;
    notifyListeners();
  }

  void decrement(int index) {
    if (_minuman[index]["quantity"] > 0) {
      _minuman[index]["quantity"]--;
      notifyListeners();
    }
  }

  void increment_makanan(int index) {
    _makanan[index]["quantity"]++;
    notifyListeners();
  }

  void decrement_makanan(int index) {
    if (_makanan[index]["quantity"] > 0) {
      _makanan[index]["quantity"]--;
      notifyListeners();
    }
  }

  void increment_dessert(int index) {
    _dessert[index]["quantity"]++;
    notifyListeners();
  }

  void decrement_dessert(int index) {
    if (_dessert[index]["quantity"] > 0) {
      _dessert[index]["quantity"]--;
      notifyListeners();
    }
  }

  // =====================
  // ORDER
  // =====================
  List<Map<String, dynamic>> get orderedMinuman =>
      _minuman.where((p) => p["quantity"] > 0).toList();

  List<Map<String, dynamic>> get orderedMakanan =>
      _makanan.where((p) => p["quantity"] > 0).toList();

  List<Map<String, dynamic>> get orderedDessert =>
      _dessert.where((p) => p["quantity"] > 0).toList();

  void clearOrders() {
    for (var p in [..._minuman, ..._makanan, ..._dessert]) {
      p["quantity"] = 0;
    }
    notifyListeners();
  }
}
