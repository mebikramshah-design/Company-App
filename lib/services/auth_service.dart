import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_user.dart';

enum AuthRole { guest, employee }

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _user;
  AppUser? get user => _user;
  bool get isAuthenticated => _user != null;

  String? _pendingGuestEmail;
  String? get pendingGuestEmail => _pendingGuestEmail;

  Future<void> sendGuestOtp({required String name, required String gmail}) async {
    if (!gmail.toLowerCase().endsWith('@gmail.com')) {
      throw Exception('Only @gmail.com addresses are accepted.');
    }
    _pendingGuestEmail = gmail;
    await _db.collection('guest_otp_requests').add({
      'name': name,
      'email': gmail,
      'createdAt': FieldValue.serverTimestamp(),
    });
    notifyListeners();
  }

  Future<void> verifyGuestOtp(String code) async {
    if (code.length != 6) {
      throw Exception('Enter the 6-digit code.');
    }
    _user = AppUser(
      uid: 'guest-${DateTime.now().millisecondsSinceEpoch}',
      role: AuthRole.guest,
      displayName: 'Guest',
      email: _pendingGuestEmail,
    );
    notifyListeners();
  }

  Future<void> registerEmployee({
    required String fullName,
    required String employeeId,
    required String mobile,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: '$employeeId@darwishinterserve.app',
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'fullName': fullName,
      'employeeId': employeeId,
      'mobile': mobile,
      'role': 'employee',
      'createdAt': FieldValue.serverTimestamp(),
    });
    _user = AppUser(
      uid: cred.user!.uid,
      role: AuthRole.employee,
      displayName: fullName,
      employeeId: employeeId,
      mobile: mobile,
    );
    notifyListeners();
  }

  Future<void> verifyEmployeeMobileOtp(String code) async {
    if (code.length != 6) {
      throw Exception('Enter the 6-digit SMS code.');
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _pendingGuestEmail = null;
    notifyListeners();
  }
}
