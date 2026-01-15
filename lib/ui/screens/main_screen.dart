import 'package:flutter/material.dart';
import 'package:management_uang/ui/screens/home_screen.dart';
// Import halaman transaksi yang baru dibuat atau yang sudah ada
import 'package:management_uang/ui/screens/transaksi_screen.dart'; 
import 'package:management_uang/ui/screens/laporan_screen.dart'; 

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

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

  // UPDATE: Tambahkan widget halaman di sini sesuai urutan menu
  static final List<Widget> _screens = [
    const HomeScreen(),    
    const TransaksiScreen(), 
    const LaporanScreen(), 
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan IndexedStack agar status halaman (seperti scroll) tidak hilang saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF0F172A),
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
          ),
          
        ],
      ),
    );
  }
}