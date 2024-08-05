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
                        fetchProductDetails(selectedProduct!);
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
                onPressed: saveBillToFirestore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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

  void calculateTotalAmount() {
    if (purchaseRate != null && quantity != null) {
      totalAmount = purchaseRate! * quantity!;
      totalAmountController.text = totalAmount!.toStringAsFixed(2);
    } else {
      totalAmount = 0.0;
      totalAmountController.text = '';
    }
  }

  void calculateSaleRate() {
    if (mrp != null && margin != null) {
      saleRate = mrp! * (1 + (margin! / 100));
      saleRateController.text = saleRate!.toStringAsFixed(2);
    } else {
      saleRate = 0.0;
      saleRateController.text = '';
    }
  }

  void calculateMargin() {
    if (mrp != null && saleRate != null) {
      margin = ((saleRate! - mrp!) / mrp!) * 100;
      marginController.text = margin!.toStringAsFixed(2);
    } else {
      margin = 0.0;
      marginController.text = '';
    }
  }

  void calculateGrandTotal() {
    grandTotal = billItems.fold(
        0.0, (sum, item) => sum + (item['totalAmount'] as double? ?? 0.0));
    grandTotalController.text = grandTotal.toStringAsFixed(2);
  }

  void addProductToBill() {
    if (selectedProduct != null &&
        quantity != null &&
        purchaseRate != null &&
        saleRate != null &&
        totalAmount != null) {
      setState(() {
        billItems.add({
          'productName': selectedProduct,
          'quantity': quantity,
          'purchaseRate': purchaseRate,
          'saleRate': saleRate,
          'totalAmount': totalAmount,
          'imageUrl': imgUrl,
          'mrp': mrp,
        });
        calculateGrandTotal();
        clearForm();
      });
    }
  }

  void updateProductInBill() {
    if (selectedProduct != null &&
        quantity != null &&
        purchaseRate != null &&
        saleRate != null &&
        totalAmount != null &&
        editingIndex != null) {
      setState(() {
        billItems[editingIndex!] = {
          'productName': selectedProduct,
          'quantity': quantity,
          'purchaseRate': purchaseRate,
          'saleRate': saleRate,
          'totalAmount': totalAmount,
          'imageUrl': imgUrl,
          'mrp': mrp,
        };
        calculateGrandTotal();
        clearForm();
        editingIndex = null;
      });
    }
  }

  void editProduct(int index) {
    setState(() {
      editingIndex = index;
      final item = billItems[index];
      selectedProduct = item['productName'];
      quantity = item['quantity'];
      purchaseRate = item['purchaseRate'];
      saleRate = item['saleRate'];
      totalAmount = item['totalAmount'];
      imgUrl = item['imageUrl'];
      mrp = item['mrp'];

      selectedParty = selectedParty;
      quantityController.text = quantity.toString();
      purchaseRateController.text = purchaseRate.toString();
      saleRateController.text = saleRate.toString();
      totalAmountController.text = totalAmount.toString();
      mrpController.text = mrp.toString();
      marginController.text = margin.toString();
    });
  }

  void clearForm() {
    selectedProduct = null;
    quantity = null;
    purchaseRate = null;
    saleRate = null;
    totalAmount = null;
    imgUrl = null;
    mrp = null;

    quantityController.clear();
    purchaseRateController.clear();
    saleRateController.clear();
    totalAmountController.clear();
    mrpController.clear();
    marginController.clear();
  }

  void saveBillToFirestore() {
    if (billItems.isEmpty || selectedParty == null) {
      return;
    }

    FirebaseFirestore.instance.collection('purchaseBills').add({
      'purchasePartyAccount': selectedParty,
      'billItems': billItems,
      'grandTotal': grandTotal,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((value) {
      // Clear the form and bill items after saving
      setState(() {
        billItems.clear();
        clearForm();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill saved successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save bill: $error')),
      );
    });
  }

  void fetchProductDetails(String productName) async {
    final productRef = FirebaseFirestore.instance
        .collection('products')
        .where('title', isEqualTo: productName);

    final snapshot = await productRef.get();
    if (snapshot.docs.isNotEmpty) {
      final product = snapshot.docs.first;
      setState(() {
        mrp =
            product.data().containsKey('mrp') ? product['mrp'].toDouble() : 0.0;
        imgUrl = product.data().containsKey('image_url')
            ? product['image_url']
            : null;
        mrpController.text = mrp.toString();
      });
    } else {
      setState(() {
        mrp = 0.0;
        imgUrl = null;
        mrpController.clear();
      });
    }
  }
}
