import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_uang/ui/provider/product_provider.dart';
import 'package:management_uang/ui/screens/main_screen.dart';

class DetailList extends StatelessWidget {
  final String imagePath;
  final String name;
  final String price;
  final String description;
  final String category; // 🔹 Tambahan: kategori ("minuman" / "makanan")

  const DetailList({
    super.key,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
  });

  List<Map<String, dynamic>> _getInfoByCategory(String category) {
    switch (category) {
      case "makanan":
        return [
          {"icon": Icons.restaurant_menu, "label": "Porsi Besar"},
          {"icon": Icons.local_fire_department, "label": "Hangat"},
          {"icon": Icons.timer, "label": "Fresh Cooked"},
        ];

      case "minuman":
        return [
          {"icon": Icons.local_drink, "label": "500ml"},
          {"icon": Icons.ac_unit, "label": "Less Ice"},
          {"icon": Icons.spa, "label": "Sugar"},
        ];

      case "dessert":
        return [
          {"icon": Icons.cake, "label": "Manis"},
          {"icon": Icons.icecream, "label": "Dingin"},
          {"icon": Icons.favorite, "label": "Best Seller"},
        ];

      default:
        return [];
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductProvider>(context);

    // 🔹 Pilih list berdasarkan kategori
    late final List<Map<String, dynamic>> productList;

    switch (category) {
      case "makanan":
        productList = provider.makanan;
        break;
      case "minuman":
        productList = provider.minuman;
        break;
      case "dessert":
        productList = provider.dessert;
        break;
      default:
        productList = [];
    }


    // 🔹 Cari produk di list yang sesuai
    final index = productList.indexWhere((p) => p["name"] == name);
    final product = productList[index];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 108, 184, 50), // hijau lembut
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔹 Tombol back + favorite
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),

            // 🔹 Konten detail
            Expanded(
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Bagian putih bawah
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.only(top: 120, left: 24, right: 24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              style:
                                  const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),

                            // Rating
                            Row(
                              children: List.generate(
                                5,
                                (index) => const Icon(Icons.star,
                                    color: Colors.amber, size: 18),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // 🔹 Info tambahan sesuai kategori
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                for (var item in _getInfoByCategory(category))
                                  _buildFeature(item["icon"], item["label"]),
                              ],
                            ),

                            const SizedBox(height: 30),

                            // 🔹 Kontrol Quantity
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline,
                                      color: Colors.green, size: 30),
                                  onPressed: () {
                                    if (category == "makanan") {
                                      provider.decrement_makanan(index);
                                    } else if(category == "minuman") {
                                      provider.decrement(index);
                                    } else {
                                      provider.decrement_dessert(index);
                                    }
                                  },
                                ),
                                Text(
                                  '${product["quantity"]}',
                                  style: const TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline,
                                      color: Colors.green, size: 30),
                                  onPressed: () {
                                    if (category == "makanan") {
                                      provider.increment_makanan(index);
                                    } else if(category == "minuman"){
                                      provider.increment(index);
                                    } else {
                                      provider.increment_dessert(index);
                                    }
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // 🔹 Tombol Pesan
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  if (product["quantity"] == 0) {
                                    if (category == "makanan") {
                                      provider.increment_makanan(index);
                                    } else if (category == "minuman"){
                                      provider.increment(index);
                                    } else{
                                      provider.increment_dessert(index);
                                    }
                                  }

                                  // 🔹 Setelah pesan, arahkan ke halaman pesanan
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MainScreen(initialIndex: 1),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: Text(
                                  product["quantity"] > 0
                                      ? "Sudah Dipesan (${product["quantity"]})"
                                      : "Pesan Sekarang",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 103, 202, 72),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 80, vertical: 16),
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Gambar produk
                  Positioned(
                    top: 0,
                    child: Hero(
                      tag: imagePath,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          imagePath,
                          width: 250,
                          height: 250,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(height: 8),
          Text(
            text,
            style: const TextStyle(color: Colors.green, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
