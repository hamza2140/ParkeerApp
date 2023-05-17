import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseManager {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login(String _email, String _password) async {
    await _auth.signInWithEmailAndPassword(email: _email, password: _password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> addUser(String _email, String _password, String _name) async {
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _email,
      password: _password,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .set({'name': _name});
  }

  Future<void> addData(String brand, String model) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection("vehicles")
        .get();
    int id = snapshot.docs.length;
    await _firestore
        .collection('users')
        .doc(_auth.currentUser?.uid)
        .collection("vehicles")
        .doc('${id}')
        .set({
      'brand': brand,
      'model': model,
    });
  }

  Future<String> getUserName() async {
    DocumentSnapshot snapshot = await _firestore
        .collection('users')
        .doc('${_auth.currentUser?.uid}')
        .get();
    return snapshot.get("name");
  }

  Future<void> deleteDoc(int index) async {
    _firestore
        .collection("users")
        .doc("${_auth.currentUser?.uid}")
        .collection("vehicles")
        .doc("${index}")
        .delete();
  }
}
