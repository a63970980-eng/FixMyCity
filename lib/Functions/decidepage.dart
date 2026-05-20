import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:fixmycity/Models/user_model.dart';
import 'package:fixmycity/Screens/home.dart';
import 'package:fixmycity/Screens/remindv.dart';

class VerifyCheckPage extends StatefulWidget {
  const VerifyCheckPage({super.key});

  @override
  State<VerifyCheckPage> createState() => _VerifyCheckPageState();
}

class _VerifyCheckPageState extends State<VerifyCheckPage> {
  final User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get();

      loggedInUser = UserModel.fromMap(doc.data());

      _navigateBasedOnVerification();
    } catch (e) {
      debugPrint("Error: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  void _navigateBasedOnVerification() {
    final isVerified = loggedInUser.isVerified ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (isVerified) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RemindVerifyPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}