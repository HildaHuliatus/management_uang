import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:management_uang/ui/provider/product_provider.dart';
import 'package:management_uang/ui/widgets/detail_list.dart';

class MakananList extends StatelessWidget {
  final String keyword;
  const MakananList({super.key, required this.keyword});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.makanan;

    // FILTER LIST
    final filtered = products.where((item) {
      return item["name"].toLowerCase().contains(keyword) ||
          item["deskripsi"].toLowerCase().contains(keyword);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        children: [

          Container(
            height: 150,
            color: Colors.white,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 10 : 0,
                  right: index == filtered.length - 1 ? 10 : 0,
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailList(
                          imagePath: filtered[index]["image"]!,
                          name: filtered[index]["name"]!,
                          price: filtered[index]["price"]!,
                          description: filtered[index]["deskripsi"]!,
                          category: filtered[index]["category"]!,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      filtered[index]["image"]!,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Menu tidak tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            )
          else ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    'Pesan :',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔹 LIST PRODUK VERTICAL
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filtered.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final product = filtered[index];

                // INDEX ASLI DI DALAM provider.makanan
                final originalIndex = products.indexOf(product);

                final qty = product["quantity"];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          product["image"]!,
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),

                      // INFORMASI PRODUK
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product["name"]!,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text(product["deskripsi"]!,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  product["price"]!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),

                                // 🔹 TOMBOL TAMBAH & KURANG
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        provider.decrement_makanan(
                                            originalIndex);
                                      },
                                      icon: const Icon(
                                          Icons.remove_circle_outline),
                                    ),
                                    Text(
                                      '$qty',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        provider
                                            .increment_makanan(originalIndex);
                                      },
                                      icon:
                                          const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
