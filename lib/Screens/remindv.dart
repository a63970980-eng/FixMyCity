import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login.dart';

class RemindVerifyPage extends StatefulWidget {
  const RemindVerifyPage({super.key});

  @override
  State<RemindVerifyPage> createState() => _RemindVerifyPageState();
}

class _RemindVerifyPageState extends State<RemindVerifyPage> {
  final User? user = FirebaseAuth.instance.currentUser;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInPage()),
      (route) => false,
    );
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.mark_email_read,
                      size: 70,
                      color: Color(0xFF0B3A67),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      'تأكيد الحساب مطلوب',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      user?.email ?? '',
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'تم إرسال رسالة تأكيد إلى بريدك الإلكتروني. '
                      'يرجى التحقق من البريد لتفعيل الحساب واستخدام التطبيق.',
                      textAlign: TextAlign.center,
                      style: TextStyle(height: 1.5),
                    ),

                    const SizedBox(height: 25),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B3A67),
                          padding: const EdgeInsets.all(14),
                        ),
                        onPressed: _logout,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('العودة لتسجيل الدخول'),
                      ),
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