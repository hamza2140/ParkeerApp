import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/database_manager.dart';
import 'package:project/editable_card.dart';
import 'package:project/forms/login_page.dart';
import 'package:project/forms/vehicles_form.dart';
import 'package:project/map_homepage.dart';
import 'bottom_navbar.dart';

class ShowVehicles extends StatefulWidget {
  const ShowVehicles({Key? key}) : super(key: key);

  @override
  _ShowVehiclesState createState() => _ShowVehiclesState();
}

class _ShowVehiclesState extends State<ShowVehicles> {
  Stream<QuerySnapshot> documentStream = const Stream.empty();
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    print("show vehicles");
    documentStream = FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .collection("vehicles")
        .snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapWidget()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Autos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => {
              DatabaseManager().logout(),
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              )
            },
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: documentStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final documents = snapshot.data!.docs;
          if (documents.isEmpty) {
            return const Center(
                child: Text("U heeft nog geen autos toegevoegd"));
          }
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              return EditableCard(
                brand: documents[index]['brand'],
                model: documents[index]['model'],
                index: index,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BrandModelForm()),
          );
        },
        tooltip: 'Ga naar formulier',
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
