import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/utils/components/product_edit_purchase_bill_history.dart';
import 'package:malavi_management/utils/const.dart';

class PurchaseBillEditProductList extends StatefulWidget {
  const PurchaseBillEditProductList({super.key});

  @override
  State<PurchaseBillEditProductList> createState() =>
      _PurchaseBillEditProductListState();
}

class _PurchaseBillEditProductListState
    extends State<PurchaseBillEditProductList> {
  Map bill = {};
  double grandTotal = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // Check if arguments are not null and cast them correctly
        final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
        if (arguments != null) {
          bill = arguments;
          bill['billItems'] =
              bill['billItems'] ?? []; // Ensure billItems is initialized

          if (updatedProduct.isNotEmpty) {
            for (var product in bill['billItems']) {
              if (updatedProduct['productName'] == product['productName']) {
                bill['billItems'].remove(product);
                bill['billItems'].add(updatedProduct);
                break;
              }
            }
            updateGrandTotal();
            updateBill();
          }
        } else {
          print("No arguments found for this route.");
        }
      });
    });
  }

  void updateGrandTotal() {
    grandTotal = 0.0; // Reset grand total
    for (var item in bill['billItems']) {
      grandTotal += item['totalAmount'];
    }
    bill['grandTotal'] = grandTotal.toString();
  }

  Future<void> updateBill() async {
    try {
      final billId = bill['billId'];
      if (billId == null) {
        print("billId is null, cannot update document.");
        return;
      }

      DocumentReference billRef =
          FirebaseFirestore.instance.collection('pendingBills').doc(billId);

      // Check if document exists
      DocumentSnapshot docSnapshot = await billRef.get();
      print("Checking for document with ID: $billId");
      if (docSnapshot.exists) {
        await billRef.update({
          'billItems': bill['billItems'],
          'grandTotal': bill['grandTotal'],
        });
        Navigator.pop(context); // Navigate back after updating
      } else {
        print("Document with ID $billId does not exist.");
      }
    } catch (e) {
      print("Error updating document: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Bill'),
        actions: [
          IconButton(
            onPressed: () {
              updateGrandTotal();
              updateBill();
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: bill['billItems'] == null
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: bill['billItems'].length,
              itemBuilder: (context, index) {
                Map billItem = bill['billItems'][index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    color: Colors.yellow.shade200.withOpacity(0.5),
                    child: ListTile(
                      title: Text(billItem['productName']),
                      trailing: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              'productEditScreenPurchaseBillHistory',
                              arguments: {
                                ...billItem,
                                'billId': bill['billId'], // Pass bill ID
                                'grandTotal': bill['grandTotal'],
                              });
                          setState(() {
                            updatedProduct.clear();
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
