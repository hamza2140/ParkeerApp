import 'package:flutter/material.dart';
import 'package:project/database_manager.dart';

class EditableCard extends StatefulWidget {
  String brand;
  String model;
  int index;

  EditableCard({
    required this.brand,
    required this.model,
    required this.index,
  });
  @override
  _EditableCardState createState() => _EditableCardState();
}

class _EditableCardState extends State<EditableCard> {
  final brandTextEditingController = TextEditingController();
  final modelTextEditingController = TextEditingController();
  bool _isEditing = false;

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
    if (!_isEditing) {
      widget.brand = brandTextEditingController.text;
      widget.model = modelTextEditingController.text;
    }
  }

  void deleteCard() async {
    await DatabaseManager().deleteDoc(widget.index);
  }

  void updateCard() async {
    _toggleEditing();
    await DatabaseManager()
        .updateVehicle(widget.brand, widget.model, widget.index);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              title: _isEditing
                  ? TextFormField(
                      controller: brandTextEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Voer een nieuwe merk in',
                      ),
                    )
                  : Text("Merk: ${widget.brand}"),
              subtitle: _isEditing
                  ? TextFormField(
                      controller: modelTextEditingController,
                      decoration: const InputDecoration(
                        labelText: 'Voer een nieuwe model in',
                      ),
                    )
                  : Text("Model: ${widget.model}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isEditing)
                    IconButton(
                      icon: const Icon(Icons.save),
                      onPressed: updateCard,
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: _toggleEditing,
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: deleteCard,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
