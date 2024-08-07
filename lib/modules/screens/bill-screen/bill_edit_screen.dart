import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/modules/screens/bill-screen/const.dart';

import '../nav-bar-screen/nav_bar_screen.dart';

class BillEditScreen extends StatefulWidget {
  const BillEditScreen({super.key});

  @override
  State<BillEditScreen> createState() => _BillEditScreenState();
}

class _BillEditScreenState extends State<BillEditScreen> {
  Map bill = {};
  double cashDiscount = 0.0;
  double grandTotal = 0.0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null) {
      setState(() {
        bill = arguments;
        bill['billItems'] = bill['billItems'] ?? [];
        if (saleBillProduct.isNotEmpty) {
          for (var product in bill['billItems']) {
            if (saleBillProduct['productName'] == product['productName']) {
              bill['billItems'].remove(product);
              bill['billItems'].add(saleBillProduct);
              break;
            }
          }
        }
      });
    } else {
      print("No arguments found for this route.");
    }
  }

  Future<void> updateBill() async {
    try {
      final billId = bill['billDocId'];
      if (billId == null) {
        print("billId is null, cannot update document.");
        return;
      }

      // Unfocus any focused text fields
      FocusScope.of(context).unfocus();

      DocumentReference billRef =
          FirebaseFirestore.instance.collection('sellBills').doc(billId);

      DocumentSnapshot docSnapshot = await billRef.get();
      if (docSnapshot.exists) {
        updateGrandTotal();
        log("$billRef bill item : ${bill['billItems']} grandTotal : ${bill['grandTotal']}");
        await billRef.update({
          'items': bill['billItems'],
          'grandTotal': bill['grandTotal'],
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Bill updated successfully.")),
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const NavBarScreen(
              initialIndex: 0,
            ),
          ),
          (route) => false,
        );
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
              updateBill();
            },
            icon: Icon(Icons.save),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: bill['billItems'].length,
        itemBuilder: (context, index) {
          final item = bill['billItems'][index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(item['productName']),
              subtitle: Text(item['quantity'].toString()),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: () async {
                      final saleBillProduct = await Navigator.of(context)
                          .pushNamed('saleBillProductEdit', arguments: {
                        ...item,
                        'billId': bill['billDocId'],
                        'grandTotal': bill['grandTotal'],
                      });

                      if (saleBillProduct != null && saleBillProduct is Map) {
                        setState(() {
                          for (var product in bill['billItems']) {
                            if (saleBillProduct['productName'] ==
                                product['productName']) {
                              bill['billItems'].remove(product);
                              bill['billItems'].add(saleBillProduct);
                              break;
                            }
                          }
                          updateBill();
                        });
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Confirm the removal
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Removal'),
                          content: const Text(
                              'Are you sure you want to remove this product?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                removeProduct(index);
                                Navigator.of(context).pop();
                              },
                              child: const Text('Remove'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void updateGrandTotal() {
    grandTotal = 0.0;
    for (var item in bill['billItems']) {
      if (item['totalAmount'] != null) {
        grandTotal += double.parse(item['totalAmount']);
      }
    }
    bill['grandTotal'] = grandTotal.toString();
  }

  removeProduct(int index) {
    setState(() {
      bill['billItems'].removeAt(index);
      updateBill();
    });
  }
}
