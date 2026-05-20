class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  bool isVerified;
  String role; // citizen / admin
  DateTime? createdAt;

  UserModel({
    this.uid,
    this.email,
    this.firstName,
    this.secondName,
    this.isVerified = false,
    this.role = 'citizen',
    this.createdAt,
  });

  /// 🔄 Receive data from Firestore
  factory UserModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) {
      return UserModel();
    }

    return UserModel(
      uid: map['uid'],
      email: map['email'],
      firstName: map['firstName'],
      secondName: map['secondName'],
      isVerified: map['isVerified'] ?? false,
      role: map['role'] ?? 'citizen',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  /// 📤 Send data to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}