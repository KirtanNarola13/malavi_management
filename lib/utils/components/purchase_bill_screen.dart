import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseBillScreen extends StatefulWidget {
  const PurchaseBillScreen({super.key});

  @override
  _PurchaseBillScreenState createState() => _PurchaseBillScreenState();
}

class _PurchaseBillScreenState extends State<PurchaseBillScreen> {
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
  List<Map<String, dynamic>> billItems = [];
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
                  return DropdownButtonFormField<String>(
                    value: selectedProduct,
                    items: snapshot.data?.docs.map((doc) {
                      imgUrl = doc['image_url'];
                      return DropdownMenuItem<String>(
                        value: doc['title'],
                        child: Text(doc['title']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select product',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedProduct = value!;
                      });
                    },
                  );
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
                onPressed: savePurchaseBill,
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
      'imageUrl': imgUrl ?? '',
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
      'imageUrl': imgUrl ?? '',
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
      imgUrl = item['imageUrl'];

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
      saleRate = mrp! - (mrp! * margin! / 100);
      saleRateController.text = saleRate?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateMargin() {
    double minusAmount;
    if (mrp != null && saleRate != null) {
      minusAmount = mrp! - saleRate!;
      margin = (minusAmount / mrp!) * 100;
      marginController.text = margin?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateGrandTotal() {
    grandTotal = billItems.fold(
        0.0, (total, item) => total + (item['totalAmount'] ?? 0.0));
    grandTotalController.text = grandTotal.toString();
  }

  void savePurchaseBill() async {
    if (selectedParty != null && billItems.isNotEmpty) {
      double totalAmount = 0;
      for (final item in billItems) {
        totalAmount += item['totalAmount'];
      }

      final pendingBillsRef =
          FirebaseFirestore.instance.collection('pendingBills');
      final productStockRef =
          FirebaseFirestore.instance.collection('productStock');

      final newBillRef = pendingBillsRef.doc();
      await newBillRef.set({
        'partyName': selectedParty!,
        'billItems': billItems,
        'grandTotal': grandTotal.toString(),
        'createdAt': Timestamp.now(),
      });

      for (final item in billItems) {
        final productName = item['productName'];
        final quantity = item['quantity'];
        final purchaseRate = item['purchaseRate'];
        final mrp = item['mrp'];
        final saleRate = item['saleRate'];
        final image = item['image_url'];
        final totalAmountItem = item['totalAmount'];
        final margin = item['margin']; // Add this line

        final productDocRef = productStockRef.doc(productName);

        await productDocRef.set(
          {
            'quantity': FieldValue.increment(quantity),
            'purchaseRate': purchaseRate,
            'mrp': mrp,
            'productName': productName,
            'image_url': image,
            'saleRate': saleRate,
            'margin': margin, // Add this line
            'partyName': selectedParty!,
            'date': Timestamp.now(),
          },
          SetOptions(merge: true),
        );

        final purchaseHistoryRef =
            productDocRef.collection('purchaseHistory').doc();
        await purchaseHistoryRef.set({
          'quantity': quantity,
          'purchaseRate': purchaseRate,
          'mrp': mrp,
          'productName': productName,
          'image_url': image,
          'saleRate': saleRate,
          'margin': margin, // Add this line
          'totalAmount': totalAmountItem,
          'partyName': selectedParty!,
          'date': Timestamp.now(),
        });
      }

      setState(
        () {
          selectedParty = null;
          billItems.clear();
          clearInputs();
        },
      );

      ScaffoldMessenger.of((!context.mounted) as BuildContext).showSnackBar(
        const SnackBar(
          content: Text(
            'Purchase Bill Saved Successfully',
          ),
        ),
      );
    }
  }
}
