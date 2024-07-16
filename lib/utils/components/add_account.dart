import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({super.key});

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  // final _formKey = GlobalKey<FormState>();
  // final _accountNameController = TextEditingController();
  // final _addressController = TextEditingController();
  // final _contactPersonController = TextEditingController();
  // final _mrpController = TextEditingController();
  // final _qtyController = TextEditingController();
  // final _categoryController = TextEditingController();
  // final _descriptionController = TextEditingController();
  // bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Future<void> _uploadData() async {
    //   if (_formKey.currentState!.validate()) {
    //     setState(() {
    //       _isLoading = true;
    //     });
    //     try {
    //       // Save data to Firestore
    //       await FirebaseFirestore.instance.collection('products').add({
    //         'title': _titleController.text,
    //         'pur_rate': _purchaseRateController.text,
    //         'sale_rate': _saleRateController.text,
    //         'mrp': _mrpController.text,
    //         'qty': _qtyController.text,
    //         'category': _categoryController.text,
    //         'description': _descriptionController.text,
    //       });

    //       // Clear form
    //       _formKey.currentState!.reset();
    //       setState(() {
    //         _isLoading = false;
    //         _categoryController.clear();
    //         _descriptionController.clear();
    //         _purchaseRateController.clear();
    //         _saleRateController.clear();
    //         _mrpController.clear();
    //         _qtyController.clear();
    //         _titleController.clear();
    //       });
    //
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Account added successfully!')));
    //     } catch (e) {
    //       setState(() {
    //         _isLoading = false;
    //       });
    //       ScaffoldMessenger.of(context).showSnackBar(
    //           SnackBar(content: Text('Failed to add product: $e')));
    //     }
    //   } else {
    //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    //         content: Text('Please fill all fields and upload an image.')));
    //   }
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Malavi Management',
        ),
      ),
      //   ),
      //   body: SingleChildScrollView(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Form(
      //       key: _formKey,
      //       child: Column(
      //         children: [
      //           TextFormField(
      //             controller: _titleController,
      //             decoration: const InputDecoration(labelText: 'Title'),
      //             validator: (value) => value!.isEmpty ? 'Enter title' : null,
      //           ),
      //           TextFormField(
      //             controller: _purchaseRateController,
      //             decoration: const InputDecoration(labelText: 'Pur rate'),
      //             validator: (value) =>
      //                 value!.isEmpty ? 'Enter purchase rate' : null,
      //           ),
      //           TextFormField(
      //             controller: _saleRateController,
      //             decoration: const InputDecoration(labelText: 'Sale rate'),
      //             validator: (value) => value!.isEmpty ? 'Enter sale rate' : null,
      //           ),
      //           TextFormField(
      //             controller: _mrpController,
      //             decoration: const InputDecoration(labelText: 'Mrp'),
      //             validator: (value) => value!.isEmpty ? 'Enter mrp' : null,
      //           ),
      //           TextFormField(
      //             controller: _qtyController,
      //             decoration: const InputDecoration(labelText: 'Qty'),
      //             validator: (value) => value!.isEmpty ? 'Enter qty' : null,
      //           ),
      //           TextFormField(
      //             controller: _categoryController,
      //             decoration: const InputDecoration(labelText: 'Category'),
      //             validator: (value) => value!.isEmpty ? 'Enter category' : null,
      //           ),
      //           TextFormField(
      //             controller: _descriptionController,
      //             decoration: const InputDecoration(labelText: 'Description'),
      //             validator: (value) =>
      //                 value!.isEmpty ? 'Enter description' : null,
      //           ),
      //           const SizedBox(height: 20),
      //           _isLoading
      //               ? CircularProgressIndicator()
      //               : ElevatedButton(
      //                   onPressed: _uploadData,
      //                   child: const Text('Add Product'),
      //                 ),
      //         ],
      //       ),
      //     ),
      //   ),
    );
  }
}
