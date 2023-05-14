import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseManager {
  FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot> getListUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot;
  }

  Future<QuerySnapshot> getVehiclesFromUser(String uid) async {
    var documentReference =
        FirebaseFirestore.instance.collection("users").doc(uid);
    var subcollectionReference = documentReference.collection('vehicles ');
    QuerySnapshot querySnapshot = await subcollectionReference.get();
    return querySnapshot;
  }

  Future<void> Login(String _email, String _password) async {
    await _auth.signInWithEmailAndPassword(email: _email, password: _password);
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
}
