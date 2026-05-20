import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key});

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    user = auth.currentUser;

    user?.sendEmailVerification();

    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkEmailVerified();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await user?.reload();
    user = auth.currentUser;

    if (user != null && user!.emailVerified) {
      timer?.cancel();

      await _markUserVerified();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SignInPage()),
        (route) => false,
      );
    }
  }

  Future<void> _markUserVerified() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .update({
      'isVerified': true,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B3A67),
              Color(0xFF132847),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mark_email_unread,
                      size: 70,
                      color: Color(0xFF0B3A67),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'تأكيد البريد الإلكتروني',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      user?.email ?? '',
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'تم إرسال رسالة تأكيد إلى بريدك الإلكتروني.\n'
                      'يرجى فتح الرسالة والنقر على رابط التفعيل لإكمال التسجيل.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5),
                    ),

                    const SizedBox(height: 25),

                    const CircularProgressIndicator(),

                    const SizedBox(height: 15),

                    const Text(
                      'جاري التحقق تلقائيًا...',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}