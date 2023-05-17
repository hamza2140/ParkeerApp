import 'package:flutter/material.dart';
import 'package:project/database_manager.dart';
import 'package:project/vehicles.dart';

class BrandModelForm extends StatefulWidget {
  @override
  _BrandModelFormState createState() => _BrandModelFormState();
}

class _BrandModelFormState extends State<BrandModelForm> {
  final _formKey = GlobalKey<FormState>();
  String _brand = '';
  String _model = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brand Model Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Merk',
                ),
                onChanged: (value) {
                  setState(() {
                    _brand = value;
                  });
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Model',
                ),
                onChanged: (value) {
                  setState(() {
                    _model = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    DatabaseManager().addData(_brand, _model);
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ShowVehicles()));
                  },
                  child: const Text('Voeg Toe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
