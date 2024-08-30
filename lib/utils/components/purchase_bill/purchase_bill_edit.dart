import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:malavi_management/modules/screens/nav-bar-screen/nav_bar_screen.dart';

class PurchaseBillEdit extends StatefulWidget {
  List items = [];
  String billID;
  PurchaseBillEdit({super.key, required this.items, required this.billID});

  @override
  State<PurchaseBillEdit> createState() => _PurchaseBillEditState();
}

class _PurchaseBillEditState extends State<PurchaseBillEdit> {
  String? selectedProduct;
  String? selectedParty;
  int? quantity;
  String? imgUrl;
  double? margin;
  double? purchaseRate;
  double? totalAmount;
  double? mrp;
  double? saleRate;
  double? netAmount;
  double grandTotal = 0.0;
  List billItems = [];
  String? billDocId;
  int? editingIndex;

  final marginController = TextEditingController();
  final purchaseRateController = TextEditingController();
  final saleRateController = TextEditingController();
  final totalAmountController = TextEditingController();
  final quantityController = TextEditingController();
  final mrpController = TextEditingController();
  final netAmountController = TextEditingController();
  final grandTotalController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    billItems = widget.items;
    billDocId = widget.billID;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Purchase Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dropdown to select purchase party from "purchase party account" collection
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('purchase party account')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedParty,
                    items: snapshot.data?.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['account_name'],
                        child: Text(doc['account_name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Purchase party account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedParty = value!;
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              // Dropdown to select product
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('products')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }
                  List<Map<String, dynamic>> items =
                      snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      'label': "${doc['title']}",
                    };
                  }).toList();
                  return DropdownSearch<String>(
                    items:
                        items.map((item) => item['label'] as String).toList(),
                    selectedItem: selectedProduct != null
                        ? items.firstWhere(
                            (item) => item['id'] == selectedProduct)['label']
                        : null,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProduct = items.firstWhere(
                            (item) => item['label'] == newValue)['id'];
                        fetchProductDetails(selectedProduct!);
                      });
                    },
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    clearButtonProps: ClearButtonProps(
                      isVisible: true,
                    ),
                  );
                  // return DropdownButtonFormField<String>(
                  //   value: selectedProduct,
                  //   items: snapshot.data?.docs.map((doc) {
                  //     imgUrl = doc['image_url'];
                  //     return DropdownMenuItem<String>(
                  //       value: doc['title'],
                  //       child: Text(doc['title']),
                  //     );
                  //   }).toList(),
                  //   decoration: InputDecoration(
                  //     labelText: 'Select product',
                  //     border: OutlineInputBorder(
                  //       borderRadius: BorderRadius.circular(10),
                  //     ),
                  //   ),
                  //   onChanged: (value) {
                  //     setState(() {
                  //       selectedProduct = value!;
                  //     });
                  //   },
                  // );
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          quantity = int.tryParse(value);
                          calculateTotalAmount();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: mrpController,
                      decoration: const InputDecoration(
                        labelText: 'MRP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          mrp = double.tryParse(value);
                          calculateSaleRate();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: purchaseRateController,
                      decoration: const InputDecoration(
                        labelText: 'Purchase rate',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          purchaseRate = double.tryParse(value);
                          calculateTotalAmount();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: totalAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Total Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: marginController,
                      decoration: const InputDecoration(
                        labelText: 'Margin (%)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          margin = double.tryParse(value) ?? 0.0;
                          calculateSaleRate();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: saleRateController,
                      decoration: const InputDecoration(
                        labelText: 'Sale Rate',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          saleRate = double.tryParse(value) ?? 0.0;
                          calculateMargin();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Grand Total
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: grandTotalController,
                      decoration: const InputDecoration(
                        labelText: 'Grand Total',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: editingIndex == null
                    ? addProductToBill
                    : updateProductInBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: Text(
                    editingIndex == null ? 'Add Product' : 'Update Product'),
              ),
              const SizedBox(height: 10),
              // List of added products
              Visibility(
                visible: billItems.isNotEmpty,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Added Products:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black26),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView.builder(
                        itemCount: billItems.length,
                        itemBuilder: (context, index) {
                          final item = billItems[index];
                          return ListTile(
                            title: Text(item['productName']),
                            subtitle: Text('Quantity: ${item['quantity']}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () {
                                    editProduct(index);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      billItems.removeAt(index);
                                      calculateGrandTotal();
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  updatePurchaseBill(billDocId!);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                ),
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void addProductToBill() {
    final product = {
      'productName': selectedProduct,
      'quantity': quantity ?? 0,
      'purchaseRate': purchaseRate ?? 0.0,
      'totalAmount': totalAmount ?? 0.0,
      'margin': margin ?? 0.0,
      'saleRate': saleRate ?? 0.0,
      'mrp': mrp ?? 0.0,
      'image_url': imgUrl ?? '',
    };
    setState(() {
      billItems.add(product);
      clearInputs();
      calculateGrandTotal();
    });
  }

  void updateProductInBill() {
    final product = {
      'productName': selectedProduct,
      'quantity': quantity ?? 0,
      'purchaseRate': purchaseRate ?? 0.0,
      'totalAmount': totalAmount ?? 0.0,
      'margin': margin ?? 0.0,
      'saleRate': saleRate ?? 0.0,
      'mrp': mrp ?? 0.0,
      'image_url': imgUrl ?? '',
    };
    setState(() {
      billItems[editingIndex!] = product;
      clearInputs();
      editingIndex = null;
      calculateGrandTotal();
    });
  }

  void editProduct(int index) {
    final item = billItems[index];
    setState(() {
      selectedProduct = item['productName'];
      quantity = item['quantity'];
      purchaseRate = item['purchaseRate'];
      totalAmount = item['totalAmount'];
      margin = item['margin'];
      saleRate = item['saleRate'];
      mrp = item['mrp'];
      imgUrl = item['image_url'];

      quantityController.text = quantity.toString();
      purchaseRateController.text = purchaseRate.toString();
      totalAmountController.text = totalAmount.toString();
      marginController.text = margin.toString();
      saleRateController.text = saleRate.toString();
      mrpController.text = mrp.toString();

      editingIndex = index;
    });
  }

  void clearInputs() {
    selectedProduct = null;
    quantity = null;
    purchaseRate = null;
    totalAmount = null;
    margin = null;
    saleRate = null;
    mrp = null;
    imgUrl = null;

    quantityController.clear();
    purchaseRateController.clear();
    totalAmountController.clear();
    marginController.clear();
    saleRateController.clear();
    mrpController.clear();
  }

  void calculateTotalAmount() {
    if (quantity != null && purchaseRate != null) {
      setState(() {
        totalAmount = (quantity ?? 0) * (purchaseRate ?? 0.0);
        totalAmountController.text = totalAmount.toString();
      });
    }
  }

  void calculateSaleRate() {
    if (mrp != null && margin != null) {
      if (margin == 0) {
        saleRate = mrp; // Set saleRate equal to MRP if margin is 0
      } else {
        saleRate = mrp! / margin!;
      }
      saleRateController.text = saleRate?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateMargin() {
    if (mrp != null && saleRate != null) {
      if (saleRate == 0) {
        margin = 0; // Set margin to 0 if saleRate is 0
      } else {
        margin = mrp! / saleRate!;
      }
      marginController.text = margin?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateGrandTotal() {
    grandTotal = billItems.fold(
        0.0, (total, item) => total + (item['totalAmount'] ?? 0.0));
    grandTotalController.text = grandTotal.toString();
  }

  Future<String> _generateBillNumber() async {
    final billsRef = FirebaseFirestore.instance.collection('pendingBills');

    // Fetch the most recent bill
    final querySnapshot =
        await billsRef.orderBy('billNumber', descending: true).limit(1).get();

    String billNumber;

    if (querySnapshot.docs.isNotEmpty) {
      final lastBillNumber = querySnapshot.docs.first['billNumber'] as String;

      // Remove the 'A' and convert to int
      final currentNumber = int.parse(lastBillNumber.substring(1));
      final newNumber = currentNumber + 1;

      // Generate new bill number with 'A' prefix
      billNumber = 'A${newNumber.toString().padLeft(2, '0')}';
    } else {
      // Start with 'A00' if no bills exist
      billNumber = 'A00';
    }

    return billNumber;
  }

  String companyName = '';
  String categoryName = '';

  Future<void> fetchProductDetails(String productName) async {
    try {
      final productQuery = await FirebaseFirestore.instance
          .collection('products')
          .where('title', isEqualTo: productName)
          .get();

      if (productQuery.docs.isNotEmpty) {
        final productDoc = productQuery.docs.first;

        setState(() {
          companyName = productDoc['company'] ?? '';
          categoryName = productDoc['category'] ?? '';
          log("Company: ${companyName}  Category: ${categoryName}");
        });
      } else {
        // Handle the case where the product document does not exist
        print('Product document does not exist');
      }
    } catch (e) {
      // Handle errors
      print('Error fetching product details: $e');
    }
  }

  void _showSavingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Saving bill..."),
            ],
          ),
        );
      },
    );
  }

  Future<void> updatePurchaseBill(String billId) async {
    _showSavingDialog(context);

    if (selectedParty != null && billItems.isNotEmpty) {
      double totalAmount = 0;
      for (final item in billItems) {
        totalAmount += item['totalAmount'];
      }

      final pendingBillsRef =
          FirebaseFirestore.instance.collection('pendingBills');
      final productStockRef =
          FirebaseFirestore.instance.collection('productStock');

      final existingBillRef = pendingBillsRef.doc(billId);

      // Retrieve the existing bill details
      final existingBillSnapshot = await existingBillRef.get();
      if (!existingBillSnapshot.exists) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bill not found'),
          ),
        );
        return;
      }

      final existingBillData = existingBillSnapshot.data();
      final existingBillItems = existingBillData?['billItems'] ?? [];

      // Update bill details
      await existingBillRef.set({
        'partyName': selectedParty!,
        'billItems': billItems,
        'paymentStatus': 'Pending',
        'grandTotal': grandTotal.toString(),
        'createdAt': existingBillData?[
            'createdAt'], // Preserve the original creation time
        'updatedAt': Timestamp.now(), // Add an updated timestamp
      }, SetOptions(merge: true));

      // Update product stock and purchase history
      for (final existingItem in existingBillItems) {
        final productName = existingItem['productName'];
        final oldQuantity = existingItem['quantity'];

        // Reference to the product document
        final productDocRef = productStockRef.doc(productName);

        // Revert the stock quantity based on the old bill items
        final productDocSnapshot = await productDocRef.get();
        if (productDocSnapshot.exists) {
          final productData = productDocSnapshot.data();
          final totalStock = productData?['totalStock'] ?? 0;

          await productDocRef.update({
            'totalStock': totalStock - oldQuantity,
          });
        }

        // Optionally remove the old purchase history entry if required
      }

      // Update stock and save new purchase history for the new bill items
      for (final item in billItems) {
        final productName = item['productName'];
        final quantity = item['quantity'];
        final purchaseRate = item['purchaseRate'];
        final mrp = item['mrp'];
        final saleRate = item['saleRate'];
        final image = item['image_url'];
        final totalAmountItem = item['totalAmount'];
        final margin = item['margin'];

        // Reference to the product document
        final productDocRef = productStockRef.doc(productName);

        // Calculate and update total stock
        final productDocSnapshot = await productDocRef.get();
        double totalStock = 0.0;
        if (productDocSnapshot.exists) {
          totalStock = productDocSnapshot['totalStock'] ?? 0.0;
        }

        await productDocRef.set({
          'productName': productName,
          'image_url': image,
          'companyName': companyName,
          'categoryName': categoryName,
          'totalStock':
              totalStock + quantity, // Add the new quantity to the total stock
          'date': Timestamp.now(),
        }, SetOptions(merge: true));

        // Save purchase history for the product
        final purchaseHistoryRef = productDocRef.collection('purchaseHistory');
        final purchaseHistoryDocRef = purchaseHistoryRef.doc();
        await purchaseHistoryDocRef.set({
          'quantity': quantity,
          'purchaseRate': purchaseRate,
          'mrp': mrp,
          'productName': productName,
          'image_url': image,
          'saleRate': saleRate,
          'margin': margin,
          'totalAmount': totalAmountItem,
          'partyName': selectedParty!,
          'date': Timestamp.now(),
        });
      }

      setState(() {
        selectedParty = null;
        billItems.clear();
        clearInputs();
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NavBarScreen(
            initialIndex: 0,
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase Bill Updated Successfully'),
        ),
      );
    }
  }
}