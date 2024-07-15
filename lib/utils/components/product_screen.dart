import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  File? _image;
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _purchaseRateController = TextEditingController();
  final _saleRateController = TextEditingController();
  final _mrpController = TextEditingController();
  final _qtyController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  bool _isUploadingImage = false;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isUploadingImage = true;
      });
      File imageFile = File(pickedFile.path);
      File bgRemovedImage = await _removeBackground(imageFile);
      setState(() {
        _image = bgRemovedImage;
        _isUploadingImage = false;
      });
    }
  }

  Future<File> _removeBackground(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.remove.bg/v1.0/removebg'),
    );
    request.headers['X-Api-Key'] = 'VtVBw7j4yoV6DhnMCow42zmv';
    request.files
        .add(await http.MultipartFile.fromPath('image_file', imageFile.path));
    final response = await request.send();
    final responseBody = await response.stream.toBytes();
    final tempDir = await getTemporaryDirectory();
    final bgRemovedImage = File('${tempDir.path}/bg_removed.png');
    await bgRemovedImage.writeAsBytes(responseBody);
    return bgRemovedImage;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _uploadData() async {
      if (_formKey.currentState!.validate() && _image != null) {
        setState(() {
          _isLoading = true;
        });
        try {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance.ref();
          final imageRef =
              storageRef.child('product_images/${basename(_image!.path)}');
          await imageRef.putFile(_image!);
          final imageUrl = await imageRef.getDownloadURL();

          // Save data to Firestore
          await FirebaseFirestore.instance.collection('products').add({
            'title': _titleController.text,
            'pur_rate': _purchaseRateController.text,
            'sale_rate': _saleRateController.text,
            'mrp': _mrpController.text,
            'qty': _qtyController.text,
            'category': _categoryController.text,
            'description': _descriptionController.text,
            'image_url': imageUrl,
          });

          // Clear form
          _formKey.currentState!.reset();
          setState(() {
            _image = null;
            _isLoading = false;
            _categoryController.clear();
            _descriptionController.clear();
            _purchaseRateController.clear();
            _saleRateController.clear();
            _mrpController.clear();
            _qtyController.clear();
            _titleController.clear();
          });

          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Product added successfully!')));
        } catch (e) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to add product: $e')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Please fill all fields and upload an image.')));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Malavi Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isUploadingImage) CircularProgressIndicator(),
              if (_image != null && !_isUploadingImage)
                Image.file(_image!, height: 200, width: 200, fit: BoxFit.cover),
              TextButton(
                onPressed: _isUploadingImage ? null : _pickImage,
                child: const Text('Upload Image'),
              ),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _purchaseRateController,
                decoration: const InputDecoration(labelText: 'Pur rate'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter purchase rate' : null,
              ),
              TextFormField(
                controller: _saleRateController,
                decoration: const InputDecoration(labelText: 'Sale rate'),
                validator: (value) => value!.isEmpty ? 'Enter sale rate' : null,
              ),
              TextFormField(
                controller: _mrpController,
                decoration: const InputDecoration(labelText: 'Mrp'),
                validator: (value) => value!.isEmpty ? 'Enter mrp' : null,
              ),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Qty'),
                validator: (value) => value!.isEmpty ? 'Enter qty' : null,
              ),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Enter category' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadData,
                      child: const Text('Add Product'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
