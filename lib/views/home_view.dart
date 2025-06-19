// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
// import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:mobile_audit_tracking/views/audit_view.dart';
import 'package:mobile_audit_tracking/views/profile_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _pageController = PageController();
  int _selectedIndex = 0;

  String? token;
  bool isLoading = true;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    _pages = [
      AuditView(token: token!),
      // SynchronizeView(),
      ProfileView(token: token),
    ];
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue.shade800,
        unselectedItemColor: Colors.white30,
        selectedItemColor: Colors.white,
        // type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.sync),
          //   label: 'Sinkronisasi',
          // ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.sync_sharp),
          //   label: 'Sinkronisasi',
          // ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Akun'),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        },
      ),
    );
  }
}
