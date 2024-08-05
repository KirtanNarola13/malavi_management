import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditBillScreen extends StatefulWidget {
  final QueryDocumentSnapshot bill;

  const EditBillScreen({super.key, required this.bill});

  @override
  State<EditBillScreen> createState() => _EditBillScreenState();
}

class _EditBillScreenState extends State<EditBillScreen> {

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _partyNameController;
  late TextEditingController _dateController;
  late TextEditingController _billNumberController;
  late TextEditingController _grandTotalController;
  late TextEditingController _mrpTotalController;
  late TextEditingController _netamountController;
  late TextEditingController _amountController;

  @override
  void initState() {
    super.initState();
    final bill = widget.bill.data() as Map<String, dynamic>;
    _partyNameController = TextEditingController(
      text: bill['party_name'],
    );
    _dateController = TextEditingController(
      text: bill['date'],
    );
    _billNumberController = TextEditingController(
      text: bill['billNumber'],
    );
    _mrpTotalController = TextEditingController(
      text: bill['mrpTotal'].toString(),
    );
    _netamountController = TextEditingController(
      text: bill['netAmount'].toString(),
    );
    _amountController = TextEditingController(
      text: bill['AmountTotal'].toString(),
    );
    _grandTotalController = TextEditingController(
      text: bill['grandTotal'].toString(),
    );
  }

  Future<void> _updateBill() async {
    if (_formKey.currentState!.validate()) {
      final updatedBill = {
        'party_name': _partyNameController.text,
        'date': _dateController.text,
        'billNumber': _billNumberController.text,
        'grandTotal': double.parse(_grandTotalController.text),
        'mrpTotal': double.parse(_mrpTotalController.text),
        'netAmount': double.parse(_netamountController.text),
        'AmountTotal': double.parse(_amountController.text),
        // Update other fields as needed
      };

      await FirebaseFirestore.instance
          .collection('sellBills')
          .doc(widget.bill.id)
          .update(updatedBill);

      Navigator.pop((!context.mounted) as BuildContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Bill',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          16.0,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _partyNameController,
                  decoration: const InputDecoration(
                    labelText: 'Party Name',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter party name' : null,
                ),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter date' : null,
                ),
                TextFormField(
                  controller: _billNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Bill Number',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter bill number' : null,
                ),
                TextFormField(
                  controller: _mrpTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Mrp',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter bill number' : null,
                ),
                TextFormField(
                  controller: _netamountController,
                  decoration: const InputDecoration(
                    labelText: 'Net amount',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter bill number' : null,
                ),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount Total',
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter bill number' : null,
                ),
                TextFormField(
                  controller: _grandTotalController,
                  decoration: const InputDecoration(
                    labelText: 'Grand Total',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter grand total' : null,
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _updateBill,
                  child: const Text(
                    'Update Bill',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
