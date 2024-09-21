import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';

class SellBillScreen extends StatefulWidget {
  const SellBillScreen({super.key});

  @override
  _SellBillScreenState createState() => _SellBillScreenState();
}

class _SellBillScreenState extends State<SellBillScreen> {
  String? selectedParty;
  String? selectedProduct;
  String partyAddress = "";
  String? selectedPartyProduct;

  int? selectedQuantity;
  String? salesMan;

  double? mrp;

  double? marginPercentage;
  double? saleRate;
  double? purchaseRate;
  int? quantity;
  int? freeQuantity;
  double? amount;
  double? discount;
  double? netAmount;
  List<Map<String, dynamic>> billItems = [];

  int? editingIndex;
  String? billNumber; // Add this field to store the bill number

  final amountController = TextEditingController();
  final freeQuantityController = TextEditingController();
  final discountController = TextEditingController();
  final netAmountController = TextEditingController();
  final marginController = TextEditingController();
  final mrpController = TextEditingController();
  final saleRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Create Sell Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('salesMan')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No sales man');
                  }
                  return DropdownButtonFormField<String>(
                    value: salesMan,
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['name'],
                        child: Text(doc['name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Sales Man',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        salesMan = value!;
                        log("${salesMan}");
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('sale party account')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No party accounts found');
                  }
                  return DropdownButtonFormField<String>(
                    value: selectedParty,
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['account_name'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${doc['account_name']} |\n ${doc['address']}",
                              style: TextStyle(fontSize: 12),
                            ),
                            Divider(),
                          ],
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Sell party account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        selectedParty = value!;
                        fetchPartyDetail(selectedParty!);
                      });
                    },
                  );
                },
              ),
              const SizedBox(height: 10),

              // Dropdown to select product from "productStock" collection
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productStock')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Text('No products found');
                  }

                  List<Map<String, dynamic>> items =
                      snapshot.data!.docs.map((doc) {
                    return {
                      'id': doc.id,
                      'label':
                          "${doc['productName']} | Stock ${doc['totalStock']}",
                    };
                  }).toList();

                  // Check if the selectedProduct is in the list of items
                  if (selectedProduct != null &&
                      !items.any((item) => item['id'] == selectedProduct)) {
                    selectedProduct = null; // or set it to a default value
                  }

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
                        selectedPartyProduct = null;
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
                },
              ),

              const SizedBox(height: 10),
              // Dropdown to select party's product associated with selected product
              if (selectedProduct != null)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('productStock')
                      .doc(selectedProduct)
                      .collection('purchaseHistory')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text('No party products found');
                    }
                    return DropdownButtonFormField<String>(
                      hint: const Text('Select Party\'s Product'),
                      value: selectedPartyProduct,
                      items: snapshot.data!.docs.map((doc) {
                        return DropdownMenuItem<String>(
                          value: doc.id,
                          child: Text(
                              "MRP: ${doc['mrp']} | Stock : ${doc['quantity']} | ${doc['purchaseRate']}"),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Party products',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedPartyProduct = value!;
                        });

                        // Fetch product details when a party product is selected
                        fetchProductDetails(selectedProduct!, value!);
                      },
                    );
                  },
                ),
              const SizedBox(height: 10),
              // Quantity input
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    quantity = int.tryParse(value);
                    calculateAmount();
                    // Call calculateAmount() on quantity change
                    setState(() {});
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Free Quantity',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.yellow),
                    ),
                  ),
                  controller: freeQuantityController,
                  keyboardType: TextInputType.number,
                ),
              ),

              // MRP and Margin in a single row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'MRP',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      controller: mrpController,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Margin (%)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: marginController,
                      onChanged: (value) {
                        if (mrp != null && value.isNotEmpty) {
                          marginPercentage = double.tryParse(value);
                          calculateSaleRate();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Sale Rate and Amount in a single row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Sale Rate',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: saleRateController,
                      onChanged: (value) {
                        saleRate = double.tryParse(value);
                        calculateAmount(); // Call calculateAmount() on sale rate change
                        calculateMargin();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: amountController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Discount and Net Amount in a single row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Discount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: discountController,
                      onChanged: (value) {
                        discount = double.tryParse(value);
                        calculateNetAmount();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Net Amount',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      controller: netAmountController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Add Product Button
              Center(
                child: ElevatedButton(
                  onPressed: editingIndex == null
                      ? addProductToBill
                      : updateProductInBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: Text(
                      editingIndex == null ? 'Add Product' : 'Update Product'),
                ),
              ),
              const SizedBox(height: 20),

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
                                    setState(() {
                                      editProduct(index);
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    setState(() {
                                      billItems.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                  ],
                ),
              ),

              // Save Bill Button
              Center(
                child: ElevatedButton(
                  onPressed: saveSellBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Save Sell Bill',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> fetchProductDetails(
      String productName, String partyProductId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productName)
        .get();

    if (productDoc.exists) {
      final partyProductDoc = await FirebaseFirestore.instance
          .collection('productStock')
          .doc(productName)
          .collection('purchaseHistory')
          .doc(partyProductId)
          .get();

      if (partyProductDoc.exists) {
        setState(() {
          mrpController.text = partyProductDoc['mrp'].toString();
          marginController.text = partyProductDoc['margin'].toString();
          saleRateController.text = partyProductDoc['saleRate'].toString();
          purchaseRate = partyProductDoc['purchaseRate'];
          selectedQuantity = partyProductDoc['quantity'];
        });

        mrp = double.parse(mrpController.text);
        marginPercentage = double.parse(marginController.text);
        saleRate = double.parse(saleRateController.text);
        calculateAmount();
      } else {
        // Handle the case where the party product document does not exist
        print('Party product document does not exist');
      }
    } else {
      // Handle the case where the main product document does not exist
      print('Product document does not exist');
    }
  }

  Future<void> fetchPartyDetail(String partyName) async {
    try {
      // Query the collection to fetch all documents
      var querySnapshot = await FirebaseFirestore.instance
          .collection('sale party account')
          .get();

      // Loop through all documents to find the one with the matching partyName
      for (var doc in querySnapshot.docs) {
        if (doc['account_name'] == partyName) {
          setState(() {
            partyAddress = doc['address'] ??
                'No address available'; // Handle missing address field
            log(partyAddress);
          });
          return; // Exit the function once the matching document is found
        }
      }

      // If no matching document is found
      setState(() {
        partyAddress = 'No party found'; // Handle case where no documents match
      });
    } catch (e) {
      print('Error fetching party details: $e');
      setState(() {
        partyAddress = 'Error fetching details'; // Handle potential errors
      });
    }
  }

  void calculateSaleRate() {
    if (mrp != null && marginPercentage != null) {
      saleRate = (mrp! / marginPercentage!);
      saleRateController.text = saleRate?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateMargin() {
    if (mrp != null && saleRate != null) {
      marginPercentage = mrp! / saleRate!;
      marginController.text = marginPercentage?.toStringAsFixed(3) ?? '';
    }
  }

  void calculateAmount() {
    amount = saleRate! * quantity!;
    amountController.text = amount!.toStringAsFixed(2);
    calculateNetAmount();
  }

  void calculateNetAmount() {
    double discountPercentage = double.tryParse(discountController.text) ?? 0.0;
    double calculatedDiscount = amount! * (discountPercentage / 100);
    netAmount = amount! - calculatedDiscount;
    netAmountController.text = netAmount!.toStringAsFixed(2);
  }

  void clearFeild() {
    selectedProduct = null;
    quantity = null;
    amount = null;
    discount = null;
    netAmount = null;
    amountController.clear();
    discountController.clear();
    netAmountController.clear();
    freeQuantityController.clear();
  }

  void addProductToBill() {
    if (selectedProduct != null &&
        quantity != null &&
        netAmount != null &&
        saleRate! >= purchaseRate! &&
        (selectedQuantity ?? 0) > 0) {
      setState(() {
        billItems.add({
          'partyName': selectedParty,
          'partyAddress': partyAddress,
          'salesMan': salesMan,
          'productName': selectedProduct,
          'partyProduct': selectedPartyProduct,
          'quantity': quantity,
          'freeQuantity': freeQuantityController.text,
          'mrp': mrpController.text,
          'margin': marginController.text,
          'saleRate': saleRate,
          'purchaseRate': purchaseRate,
          'amount': amount,
          'discount': discountController.text,
          'netAmount': netAmount,
          'date':
              "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
        });
        quantity = null;
        amount = null;
        discount = null;
        netAmount = null;
        amountController.clear();
        discountController.clear();
        netAmountController.clear();
        freeQuantityController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete the product details')),
      );
    }
  }

  void editProduct(int index) {
    final item = billItems[index];

    setState(() {
      salesMan = item['salesMan'] as String?;
      selectedParty = item['partyName'] as String?;
      selectedProduct = item['productName'] as String?;
      selectedPartyProduct = item['partyProduct'] as String?;
      quantity = item['quantity'] as int?;
      freeQuantity = item['freeQuantity'] != null
          ? int.tryParse(item['freeQuantity'].toString())
          : null;
      mrp =
          item['mrp'] != null ? double.tryParse(item['mrp'].toString()) : null;
      marginPercentage = item['margin'] != null
          ? double.tryParse(item['margin'].toString())
          : null;
      saleRate = item['saleRate'] != null
          ? double.tryParse(item['saleRate'].toString())
          : null;
      amount = item['amount'] != null
          ? double.tryParse(item['amount'].toString())
          : null;
      discount = item['discount'] != null
          ? double.tryParse(item['discount'].toString())
          : null;
      netAmount = item['netAmount'] != null
          ? double.tryParse(item['netAmount'].toString())
          : null;

      // Update text controllers if values are not null
      amountController.text = amount?.toString() ?? '';
      freeQuantityController.text = freeQuantity?.toString() ?? '';
      marginController.text = marginPercentage?.toString() ?? '';
      discountController.text = discount?.toString() ?? '';
      netAmountController.text = netAmount?.toString() ?? '';
      saleRateController.text = saleRate?.toString() ?? '';
      mrpController.text = mrp?.toString() ?? '';

      editingIndex = index;
    });
  }

  void updateProductInBill() {
    final product = {
      'partyName': selectedParty,
      'partyAddress': partyAddress,
      'salesMan': salesMan,
      'productName': selectedProduct,
      'partyProduct': selectedPartyProduct,
      'quantity': quantity,
      'freeQuantity': freeQuantityController.text,
      'mrp': mrpController.text,
      'margin': marginController.text,
      'saleRate': saleRate,
      'purchaseRate': purchaseRate,
      'amount': amount,
      'discount': discount,
      'netAmount': netAmount,
    };
    setState(() {
      billItems[editingIndex!] = product;
      clearFeild();
      editingIndex = null;
    });
  }

  Future<void> fetchLastBillNumber() async {
    final billsCollection = FirebaseFirestore.instance.collection('sellBills');
    final lastBillDoc = await billsCollection
        .orderBy('billNumber', descending: true)
        .limit(1)
        .get();

    if (lastBillDoc.docs.isNotEmpty) {
      final lastBillNumber = lastBillDoc.docs.first['billNumber'];
      final currentNumber = int.parse(
          lastBillNumber.substring(1)); // Remove the 'A' and convert to int
      final newNumber = currentNumber + 1;
      billNumber = 'A${newNumber.toString().padLeft(2, '0')}';
    } else {
      billNumber = 'A00'; // Start with A00 if no bills exist
    }
  }

  int fetchQuantity = 0;
  int finalQuantity = 0;
  Future<void> updateProductStock(
      String productName,
      String selectedPartyProductId,
      int quantityToSell,
      String productMrp) async {
    try {
      // Fetch all party product documents with the same product name
      final productDocs = await FirebaseFirestore.instance
          .collection('productStock')
          .doc(productName)
          .collection('purchaseHistory')
          .where('mrp',
              isEqualTo:
                  productMrp) // Assuming selectedPartyProductMrp is available
          .get();

      List<DocumentSnapshot> validDocs = [];
      int remainingQuantityToSell = quantityToSell;

      // Loop through all documents to check available stock
      for (var doc in productDocs.docs) {
        int availableQuantity = doc['quantity'];
        if (availableQuantity > 0) {
          validDocs.add(doc);
        }
      }

      if (validDocs.isEmpty) {
        // Handle case where no documents with matching MRP are found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No stock available with the specified MRP')),
        );
        return;
      }

      // Process sale from the documents with valid stock
      for (var doc in validDocs) {
        String docId = doc.id;
        int availableQuantity = doc['quantity'];

        if (remainingQuantityToSell <= availableQuantity) {
          // Update stock in the current document
          await FirebaseFirestore.instance
              .collection('productStock')
              .doc(productName)
              .collection('purchaseHistory')
              .doc(docId)
              .update(
                  {'quantity': availableQuantity - remainingQuantityToSell});
          remainingQuantityToSell = 0;
          break;
        } else {
          // Update stock in the current document and continue to the next
          await FirebaseFirestore.instance
              .collection('productStock')
              .doc(productName)
              .collection('purchaseHistory')
              .doc(docId)
              .update({'quantity': 0});
          remainingQuantityToSell -= availableQuantity;
        }
      }

      if (remainingQuantityToSell > 0) {
        // Handle case where not enough stock was found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not enough stock to fulfill the sale')),
        );
      } else {
        // Successfully processed the sale
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock updated successfully')),
        );
      }
    } catch (e) {
      print('Error updating stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating stock')),
      );
    }
  }

  void saveSellBill() async {
    log(partyAddress);
    if (billItems.isNotEmpty) {
      await fetchLastBillNumber(); // Fetch the last bill number and generate a new one
      double grandTotal = 0;
      int _dQuantity = 0;
      List<Map<String, dynamic>> itemsToSave = [];
      for (var item in billItems) {
        grandTotal += item['netAmount'];
        int finalFreeQuantity = int.parse(item['freeQuantity'].toString());
        int finalQuantity = int.parse(item['quantity'].toString());
        _dQuantity = finalQuantity + finalFreeQuantity;

        await updateProductStock(item['productName'], selectedPartyProduct!,
            _dQuantity, item['mrp'].toString());
        itemsToSave.add({
          'partyName': item['partyName'],
          'partyAddress': item['partyAddress'],
          'productName': item['productName'],
          'salesMan': item['salesMan'],
          'quantity': item['quantity'],
          'freeQuantity': item['freeQuantity'],
          'mrp': item['mrp'],
          'margin': item['margin'],
          'saleRate': item['saleRate'],
          'purchaseRate': item['purchaseRate'],
          'amount': item['amount'],
          'discount': item['discount'],
          'netAmount': item['netAmount'],
          'date':
              "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
        });
      }

      await FirebaseFirestore.instance.collection('sellBills').add({
        'billNumber': billNumber,
        'grandTotal': grandTotal,
        'salesMan': salesMan,
        'date':
            "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
        'timeStamp': DateTime.now(),
        'party_name': selectedParty,
        'kasar': 0,
        'cashDiscount': 0.0,
        'paymentStatus': 'pending',
        'partyAddress': partyAddress,
        'items': itemsToSave,
      }).then((_) {
        salesMan == null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sell Bill Saved')),
      );

      setState(() {
        billItems.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No items to save')),
      );
    }
  }
}
