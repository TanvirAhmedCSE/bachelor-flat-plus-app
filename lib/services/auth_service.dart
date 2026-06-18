import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Generate flat code like FLAT-A3X9
  static String _generateFlatCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = DateTime.now().millisecondsSinceEpoch;
    String code = 'FLAT-';
    final r = rand.toString();
    for (int i = 0; i < 4; i++) {
      code +=
          chars[(rand + i * 7 + int.parse(r[r.length - 1 - i])) % chars.length];
    }
    return code;
  }

  // Create new flat + register user as admin
  static Future<String?> registerAndCreateFlat({
    required String email,
    required String password,
    required String name,
    required String flatName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.sendEmailVerification();

      // Generate unique flat code
      String flatCode = _generateFlatCode();
      while (true) {
        final existing = await _db.collection('flats').doc(flatCode).get();
        if (!existing.exists) break;
        flatCode = _generateFlatCode();
      }

      // Create flat document
      await _db.collection('flats').doc(flatCode).set({
        'flatId': flatCode,
        'flatName': flatName,
        'createdBy': user.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'memberCount': 1,
      });

      // Create user document: admin is always active
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: 'admin',
        flatId: flatCode,
        joinedAt: DateTime.now(),
        status: 'active',
      );
      await _db.collection('users').doc(user.uid).set(userModel.toMap());

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Join existing flat — status: pending, add to join_requests
  static Future<String?> registerAndJoinFlat({
    required String email,
    required String password,
    required String name,
    required String flatCode,
  }) async {
    try {
      final normalizedCode = flatCode.toUpperCase();

      // Check if flat exists
      final flatDoc = await _db.collection('flats').doc(normalizedCode).get();
      if (!flatDoc.exists) {
        return 'Flat not found! Check your Flat Code.';
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      await user.sendEmailVerification();

      // Create user document with status: pending
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: 'member',
        flatId: normalizedCode,
        joinedAt: DateTime.now(),
        status: 'pending',
      );
      await _db.collection('users').doc(user.uid).set(userModel.toMap());

      // Add to flat's join_requests sub-collection
      await _db
          .collection('flats')
          .doc(normalizedCode)
          .collection('join_requests')
          .doc(user.uid)
          .set({
            'uid': user.uid,
            'name': name,
            'email': email,
            'requestedAt': DateTime.now().toIso8601String(),
          });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Submit join request for a removed/unflat user (from HomeScreen)
  static Future<String?> submitJoinRequest({required String flatCode}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return 'Not logged in';

      final normalizedCode = flatCode.toUpperCase();
      final flatDoc = await _db.collection('flats').doc(normalizedCode).get();
      if (!flatDoc.exists) {
        return 'Flat not found! Check your Flat Code.';
      }

      final userDoc = await _db.collection('users').doc(uid).get();
      if (!userDoc.exists) return 'User data not found';

      final userData = userDoc.data()!;

      // Update user doc
      await _db.collection('users').doc(uid).update({
        'flatId': normalizedCode,
        'status': 'pending',
      });

      // Add to join_requests
      await _db
          .collection('flats')
          .doc(normalizedCode)
          .collection('join_requests')
          .doc(uid)
          .set({
            'uid': uid,
            'name': userData['name'] ?? '',
            'email': userData['email'] ?? '',
            'requestedAt': DateTime.now().toIso8601String(),
          });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  static Future<void> logout() async {
    await FirebaseFirestore.instance.terminate();
    await FirebaseFirestore.instance.clearPersistence();
    await _auth.signOut();
  }

  static Future<void> resendVerificationEmail() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  static Future<UserModel?> getCurrentUserModel() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!);
  }

  static Future<String?> getFlatName(String flatId) async {
    final doc = await _db.collection('flats').doc(flatId).get();
    if (!doc.exists) return null;
    return doc.data()?['flatName'] as String?;
  }
}
