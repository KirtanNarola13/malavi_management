import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAccount extends StatefulWidget {
  const AddAccount({super.key});

  @override
  State<AddAccount> createState() => _AddAccountState();
}

class _AddAccountState extends State<AddAccount> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String? _selectedAccountType;
  bool _isLoading = false;

  @override
  void dispose() {
    _accountNameController.dispose();
    _addressController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  Future<void> _uploadData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // Determine collection name based on account type
        String collectionName = _selectedAccountType == 'Sale party'
            ? 'sale party account'
            : 'purchase party account';

        // Save data to Firestore
        await FirebaseFirestore.instance.collection(collectionName).add({
          'account_name': _accountNameController.text,
          'address': _addressController.text,
          'phone_number': _phoneNumberController.text,
          'account_type': _selectedAccountType,
        });

        // Clear form
        _formKey.currentState!.reset();
        setState(() {
          _isLoading = false;
          _accountNameController.clear();
          _addressController.clear();
          _phoneNumberController.clear();
          _selectedAccountType = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Account added successfully!')));
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to add account: $e')));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill all fields.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _accountNameController,
                decoration: const InputDecoration(labelText: 'Account Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter account name' : null,
              ),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (value) => value!.isEmpty ? 'Enter address' : null,
              ),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter phone number' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Account Type'),
                value: _selectedAccountType,
                items: const [
                  DropdownMenuItem(
                    value: 'Sale party',
                    child: Text('Sale Party'),
                  ),
                  DropdownMenuItem(
                    value: 'Purchase party',
                    child: Text('Purchase Party'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAccountType = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select account type' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _uploadData,
                      child: const Text('Add Account'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
