import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  // final _formKey = GlobalKey<FormState>();
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
    request.files.add(
      await http.MultipartFile.fromPath(
        'image_file',
        imageFile.path,
      ),
    );
    final response = await request.send();
    final responseBody = await response.stream.toBytes();
    final tempDir = await getTemporaryDirectory();
    final bgRemovedImage = File(
      '${tempDir.path}/bg_removed_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await bgRemovedImage.writeAsBytes(responseBody);
    return bgRemovedImage;
  }

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
        await FirebaseFirestore.instance.collection('products').add(
          {
            'title': _titleController.text,
            'pur_rate': _purchaseRateController.text,
            'sale_rate': _saleRateController.text,
            'mrp': _mrpController.text,
            'qty': _qtyController.text,
            'category': _categoryController.text,
            'description': _descriptionController.text,
            'image_url': imageUrl,
          },
        );

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

        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          const SnackBar(
            content: Text(
              'Product added successfully!',
            ),
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add product: $e',
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields and upload an image.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sarkar Infotech Pvt. Ltd.',
        ),
        backgroundColor: Colors.yellow[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(
          20,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_isUploadingImage) const CircularProgressIndicator(),
              if (_image != null && !_isUploadingImage)
                CircleAvatar(
                  maxRadius: 60,
                  backgroundImage: FileImage(_image!),
                  backgroundColor: Colors.transparent,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(
                    Colors.yellow[700]!,
                  ),
                ),
                onPressed: _isUploadingImage ? null : _pickImage,
                child: const Text(
                  'Upload Image',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              _buildTextFormField(_titleController, 'Title', 'Enter title'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(
                  _purchaseRateController, 'Pur rate', 'Enter purchase rate'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(
                  _saleRateController, 'Sale rate', 'Enter sale rate'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(_mrpController, 'Mrp', 'Enter mrp'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(_qtyController, 'Qty', 'Enter qty'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(
                  _categoryController, 'Category', 'Enter category'),
              const SizedBox(
                height: 10,
              ),
              _buildTextFormField(
                  _descriptionController, 'Description', 'Enter description'),
              const SizedBox(
                height: 20,
              ),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                      ),
                      child: const Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller, String label, String validationMsg) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            10,
          ),
        ),
      ),
      validator: (value) => value!.isEmpty ? validationMsg : null,
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.yellow[700],
        hintColor: Colors.yellow[700],
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.yellow[700],
          textTheme: ButtonTextTheme.primary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.yellow[700],
        ),
      ),
      home: const AddProductScreen(),
    ),
  );
}
