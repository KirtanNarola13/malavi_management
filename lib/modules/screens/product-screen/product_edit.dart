import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProduct extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProduct({super.key, required this.product});

  @override
  State<EditProduct> createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late TextEditingController _purRateController;
  late TextEditingController _saleRateController;
  late TextEditingController _mrpController;
  late TextEditingController _qtyController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product['title']);
    _descriptionController =
        TextEditingController(text: widget.product['description']);
    _categoryController =
        TextEditingController(text: widget.product['category']);
    _purRateController =
        TextEditingController(text: widget.product['pur_rate'].toString());
    _saleRateController =
        TextEditingController(text: widget.product['sale_rate'].toString());
    _mrpController =
        TextEditingController(text: widget.product['mrp'].toString());
    _qtyController =
        TextEditingController(text: widget.product['qty'].toString());
  }

  void _updateProduct() async {
    try {
      await _firestore.collection('products').doc(widget.product['id']).update(
        {
          'title': _titleController.text,
          'description': _descriptionController.text,
          'category': _categoryController.text,
          'pur_rate': double.parse(
            _purRateController.text,
          ),
          'sale_rate': double.parse(
            _saleRateController.text,
          ),
          'mrp': double.parse(
            _mrpController.text,
          ),
          'qty': int.parse(
            _qtyController.text,
          ),
        },
      );
      Navigator.pop(context, true); // Return true to indicate success
    } catch (e) {
      if (kDebugMode) {
        print(
          "Error updating product: $e",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Product",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: ListView(
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _purRateController,
              decoration: const InputDecoration(
                labelText: 'Purchase Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _saleRateController,
              decoration: const InputDecoration(
                labelText: 'Sale Rate',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _mrpController,
              decoration: const InputDecoration(
                labelText: 'MRP',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: _qtyController,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 10,
                ),
              ),
              onPressed: _updateProduct,
              child: const Text(
                "Update Product",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
