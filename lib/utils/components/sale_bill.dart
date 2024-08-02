import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellBillScreen extends StatefulWidget {
  const SellBillScreen({super.key});

  @override
  _SellBillScreenState createState() => _SellBillScreenState();
}

class _SellBillScreenState extends State<SellBillScreen> {
  String? selectedParty;
  String? selectedProduct;
  String? selectedPartyProduct;
  String? salesMan;
  double? mrp;
  double? marginPercentage;
  double? saleRate;
  int? quantity;
  int? freeQuantity;
  double? amount;
  double? discount;
  double? netAmount;
  List<Map<String, dynamic>> billItems = [];
  String? billNumber; // Field to store the bill number

  final amountController = TextEditingController();
  final freeQuantityController = TextEditingController();
  final salesManController = TextEditingController();
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
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Sales Man',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                controller: salesManController,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  salesMan = value;
                },
              ),
              const SizedBox(height: 10),
              // Dropdown to select purchase party from "sale party account" collection
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
                        child: Text(
                          doc['account_name'],
                          style: TextStyle(fontSize: 14),
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
                  return DropdownButtonFormField<String>(
                    value: selectedProduct,
                    items: snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['productName'],
                        child: Text(
                          doc['productName'],
                          style: TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Product',
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
                          child: Column(
                            children: [
                              Text(
                                "${doc['partyName']} |  mrp : ${doc['mrp']}",
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        labelText: 'Party products',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onChanged: (value) {
                        var selectedDoc = snapshot.data!.docs
                            .firstWhere((doc) => doc.id == value);
                        setState(() {
                          selectedPartyProduct = value!;
                          mrpController.text = selectedDoc['mrp'].toString();
                          marginController.text =
                              selectedDoc['margin'].toString();
                          saleRateController.text =
                              selectedDoc['saleRate'].toString();
                          fetchProductDetails(selectedProduct!);
                          calculateAmount();
                        });
                      },
                    );
                  },
                ),
              const SizedBox(height: 10),
              // Quantity input
              TextFormField(
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
                  calculateAmount(); // Call calculateAmount() on quantity change
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
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
              const SizedBox(height: 10),
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
                        calculateAmount(); // Call calculateAmount() on discount change
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
                      readOnly: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (validateInputs()) {
                    addToBill();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                },
                child: const Text('Add to Bill'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveSellBill,
                child: const Text('Save Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fetch product details from Firestore and calculate sale rate
  void fetchProductDetails(String productName) async {
    var productDoc = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productName)
        .get();

    if (productDoc.exists) {
      setState(() {
        mrp = productDoc['mrp'];
        saleRate = productDoc['saleRate'];
        marginPercentage = productDoc['margin'];
        mrpController.text = mrp.toString();
        saleRateController.text = saleRate.toString();
      });
    }
  }

  // Calculate the amount based on quantity, sale rate, and discount
  void calculateAmount() {
    if (quantity != null && saleRate != null) {
      double totalAmount = quantity! * (saleRate! - (discount ?? 0));
      setState(() {
        amount = totalAmount;
        amountController.text = totalAmount.toString();
        netAmount = totalAmount - (discount ?? 0);
        netAmountController.text = netAmount.toString();
      });
    }
  }

  // Calculate sale rate based on MRP and margin percentage
  void calculateSaleRate() {
    if (mrp != null && marginPercentage != null) {
      setState(() {
        saleRate = mrp! - (mrp! * (marginPercentage! / 100));
        saleRateController.text = saleRate.toString();
      });
    }
  }

  // Add item to bill list
  void addToBill() {
    setState(() {
      billItems.add({
        'partyName': selectedParty,
        'productName': selectedProduct,
        'salesMan': salesMan,
        'quantity': quantity,
        'freeQuantity': freeQuantity ?? 0,
        'mrp': mrp,
        'margin': marginPercentage,
        'saleRate': saleRate,
        'amount': amount,
        'discount': discount,
        'netAmount': netAmount,
        'date':
            "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
      });
      clearFields();
    });
  }

  // Clear input fields
  void clearFields() {
    salesManController.clear();
    freeQuantityController.clear();
    amountController.clear();
    discountController.clear();
    netAmountController.clear();
    marginController.clear();
    mrpController.clear();
    saleRateController.clear();
    setState(() {
      selectedParty = null;
      selectedProduct = null;
      selectedPartyProduct = null;
      quantity = null;
      freeQuantity = null;
      mrp = null;
      marginPercentage = null;
      saleRate = null;
      amount = null;
      discount = null;
      netAmount = null;
    });
  }

  // Validate inputs
  bool validateInputs() {
    return selectedParty != null &&
        selectedProduct != null &&
        quantity != null &&
        salesMan != null &&
        amount != null &&
        netAmount != null;
  }

  // Save sell bill to Firestore
  Future<void> saveSellBill() async {
    if (billItems.isNotEmpty) {
      await fetchLastBillNumber(); // Fetch the last bill number and generate a new one
      double grandTotal = 0;
      List<Map<String, dynamic>> itemsToSave = [];

      for (var item in billItems) {
        grandTotal += item['netAmount'] as double;
        itemsToSave.add({
          'partyName': item['partyName'],
          'productName': item['productName'],
          'salesMan': item['salesMan'],
          'quantity': item['quantity'],
          'freeQuantity': item['freeQuantity'],
          'mrp': item['mrp'],
          'margin': item['margin'],
          'saleRate': item['saleRate'],
          'amount': item['amount'],
          'discount': item['discount'],
          'netAmount': item['netAmount'],
          'date':
              "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
        });
      }

      // Decrement product quantity in the productStock collection
      for (var item in billItems) {
        var productDoc = FirebaseFirestore.instance
            .collection('productStock')
            .doc(item['productName']); // Assuming productName is the unique ID

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          var productSnapshot = await transaction.get(productDoc);

          if (!productSnapshot.exists) {
            throw Exception("Product not found");
          }

          var currentStock = productSnapshot['quantity'] as int;
          var quantityToDecrement =
              item['quantity'] + item['freeQuantity']?.toInt() ?? 0;

          if (currentStock < quantityToDecrement) {
            throw Exception("Insufficient stock");
          }

          transaction.update(productDoc, {
            'quantity': currentStock - quantityToDecrement,
          });
        });
      }

      // Add sell bill to Firestore
      await FirebaseFirestore.instance.collection('sellBills').add({
        'billNumber': billNumber,
        'grandTotal': grandTotal,
        'items': itemsToSave,
        'salesMan': salesMan,
        'date':
            "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
        'party_name': selectedParty,
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

  // Fetch the last bill number from Firestore and increment
  Future<void> fetchLastBillNumber() async {
    var billQuery = await FirebaseFirestore.instance
        .collection('sellBills')
        .orderBy('billNumber', descending: true)
        .limit(1)
        .get();

    if (billQuery.docs.isNotEmpty) {
      var lastBill = billQuery.docs.first;
      int lastBillNumber = lastBill['billNumber'];
      setState(() {
        billNumber = (lastBillNumber + 1).toString();
      });
    } else {
      setState(() {
        billNumber = '1';
      });
    }
  }
}
