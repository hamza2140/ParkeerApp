import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/vehicles.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    print("loading");
    Future.delayed(const Duration(seconds: 2)).then((value) => {
          if (auth.currentUser != null)
            {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShowVehicles()),
              )
            }
          else
            {
              auth.authStateChanges().listen((User? user) async {
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ShowVehicles()),
                  );
                }
              })
            }
        });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
