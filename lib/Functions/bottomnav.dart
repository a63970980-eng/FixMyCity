import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fixmycity/Screens/home.dart';
import 'package:fixmycity/Screens/map.dart';
import 'package:fixmycity/Screens/profile.dart';

class BottomNav extends StatefulWidget {
  final int selectedIndex;

  const BottomNav({super.key, this.selectedIndex = 0});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  String role = 'citizen';

  @override
  void initState() {
    super.initState();
    _getRole();
  }

  Future<void> _getRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    setState(() {
      role = doc.data()?['role'] ?? 'citizen';
    });
  }

  void _navigate(int index) {
    Widget page;

    if (index == 0) {
      page = const HomePage();
    } else if (index == 1) {
      page = const MapPage();
    } else if (index == 2) {
      page = const HomePage(); // هنا لاحقًا تحط صفحة إنشاء بلاغ
    } else if (index == 3 && role == 'admin') {
      page = const HomePage(); // لاحقًا Admin Page
    } else {
      page = const ProfilePage();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = role == 'admin';

    return NavigationBar(
      selectedIndex: widget.selectedIndex,
      onDestinationSelected: _navigate,
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'الرئيسية',
        ),

        const NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'الخريطة',
        ),

        const NavigationDestination(
          icon: Icon(Icons.add_circle_outline),
          selectedIcon: Icon(Icons.add_circle),
          label: 'بلاغ',
        ),

        if (isAdmin)
          const NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'الإدارة',
          ),

        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'الحساب',
        ),
      ],
    );
  }
}