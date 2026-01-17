import 'package:flutter/material.dart';
import 'package:management_uang/ui/screens/home_screen.dart';
// Import halaman transaksi yang baru dibuat atau yang sudah ada
import 'package:management_uang/ui/screens/transaksi_screen.dart'; 
import 'package:management_uang/ui/screens/laporan_screen.dart'; 

class MainScreen extends StatefulWidget {
  final int initialIndex;
  final String username;
  const MainScreen({super.key, this.initialIndex = 0, required this.username,});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  // JANGAN gunakan static final di sini karena tidak bisa akses "widget"

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Deklarasikan list di dalam build
    final List<Widget> screens = [
      HomeScreen(username: widget.username), // Sekarang "widget" bisa diakses
      const TransaksiScreen(),
      const LaporanScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens, // Gunakan variabel screens dari sini
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        // ... (sisanya tetap sama)
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Transaksi'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Laporan'),
        ],
      ),
    );
  }
}