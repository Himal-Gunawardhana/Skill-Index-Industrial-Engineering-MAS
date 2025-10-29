import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/style_model.dart';
import '../models/operation_model.dart';
import '../models/assessment_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth Methods
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserCredential> registerUser(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // User Data Methods
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Future<void> createUserData(
    String uid,
    String name,
    String email, {
    bool isAdmin = false,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
    });
  }

  Future<List<UserModel>> getAllIEUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('isAdmin', isEqualTo: false)
        .get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Style Methods
  Future<List<StyleModel>> getStyles() async {
    final snapshot = await _firestore.collection('styles').get();
    return snapshot.docs
        .map((doc) => StyleModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addStyle(String name, double smv) async {
    await _firestore.collection('styles').add({'name': name, 'smv': smv});
  }

  Future<void> updateStyle(String id, String name, double smv) async {
    await _firestore.collection('styles').doc(id).update({
      'name': name,
      'smv': smv,
    });
  }

  Future<void> deleteStyle(String id) async {
    await _firestore.collection('styles').doc(id).delete();
  }

  // Operation Methods
  Future<List<OperationModel>> getOperations() async {
    final snapshot = await _firestore.collection('operations').get();
    return snapshot.docs
        .map((doc) => OperationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> addOperation(String name, String description) async {
    await _firestore.collection('operations').add({
      'name': name,
      'description': description,
    });
  }

  Future<void> updateOperation(
    String id,
    String name,
    String description,
  ) async {
    await _firestore.collection('operations').doc(id).update({
      'name': name,
      'description': description,
    });
  }

  Future<void> deleteOperation(String id) async {
    await _firestore.collection('operations').doc(id).delete();
  }

  // Assessment Methods
  Future<void> saveAssessment(AssessmentModel assessment) async {
    await _firestore.collection('assessments').add(assessment.toMap());
  }

  Future<List<AssessmentModel>> getAssessments({String? userId}) async {
    Query query = _firestore.collection('assessments');

    if (userId != null) {
      query = query.where('createdBy', isEqualTo: userId);
    }

    final snapshot = await query.orderBy('date', descending: true).get();
    return snapshot.docs
        .map(
          (doc) => AssessmentModel.fromMap(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  Future<List<AssessmentModel>> getAssessmentsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final snapshot = await _firestore
        .collection('assessments')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThanOrEqualTo: end)
        .orderBy('date', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AssessmentModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
