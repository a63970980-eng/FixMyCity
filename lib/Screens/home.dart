import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../Functions/bottomnav.dart';
import 'profile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController issueController = TextEditingController();

  File? imageFile;
  String imageUrl = '';

  Position? currentPosition;

  String selectedCategory = 'Electricity Issue';
  bool showCustomField = false;

  final List<String> categories = [
    'Electricity Issue',
    'Water Problem',
    'Road Damage',
    'Waste Issue',
    'Other'
  ];

  final CollectionReference complaints =
      FirebaseFirestore.instance.collection('complaints');

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() => currentPosition = position);
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source);

    if (file == null) return;

    setState(() => imageFile = File(file.path));

    final uniqueName = DateTime.now().millisecondsSinceEpoch.toString();

    final ref = FirebaseStorage.instance
        .ref()
        .child('complaints')
        .child(uniqueName);

    await ref.putFile(File(file.path));

    imageUrl = await ref.getDownloadURL();
  }

  Future<void> submitComplaint() async {
    if (!formKey.currentState!.validate()) return;

    if (imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image')),
      );
      return;
    }

    if (currentPosition == null) return;

    await complaints.add({
      'title': issueController.text,
      'category': selectedCategory,
      'imageUrl': imageUrl,
      'latitude': currentPosition!.latitude,
      'longitude': currentPosition!.longitude,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Complaint submitted successfully')),
    );

    setState(() {
      issueController.clear();
      imageFile = null;
      imageUrl = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNav(selectedIndex: 0),

      appBar: AppBar(
        title: const Text('خدمات عدن الحكومية'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          )
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: submitComplaint,
        icon: const Icon(Icons.send),
        label: const Text('إرسال البلاغ'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تقديم بلاغ جديد',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: categories
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                            showCustomField = value == 'Other';
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'نوع البلاغ',
                        ),
                      ),

                      const SizedBox(height: 10),

                      if (showCustomField)
                        TextFormField(
                          controller: issueController,
                          decoration: const InputDecoration(
                            labelText: 'اكتب نوع المشكلة',
                          ),
                        )
                      else
                        TextFormField(
                          controller: issueController,
                          decoration: const InputDecoration(
                            labelText: 'وصف البلاغ',
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: ListTile(
                  title: const Text('الموقع الحالي'),
                  subtitle: Text(
                    currentPosition != null
                        ? '${currentPosition!.latitude}, ${currentPosition!.longitude}'
                        : 'جاري تحديد الموقع...',
                  ),
                  leading: const Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 20),

              Card(
                child: Column(
                  children: [
                    imageFile != null
                        ? Image.file(imageFile!, height: 180, fit: BoxFit.cover)
                        : const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('لم يتم اختيار صورة'),
                          ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.camera),
                          label: const Text('كاميرا'),
                          onPressed: () => pickImage(ImageSource.camera),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.image),
                          label: const Text('معرض'),
                          onPressed: () => pickImage(ImageSource.gallery),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}