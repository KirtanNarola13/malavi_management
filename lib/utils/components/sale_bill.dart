import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SellBillScreen extends StatefulWidget {
  @override
  _SellBillScreenState createState() => _SellBillScreenState();
}

class _SellBillScreenState extends State<SellBillScreen> {
  String? selectedParty;
  String? selectedProduct;
  String? selectedPartyProduct;
  double? mrp;
  double? marginPercentage;
  double? saleRate;
  int? quantity;
  double? amount;
  double? discount;
  double? netAmount;
  List<Map<String, dynamic>> billItems = [];

  final amountController = TextEditingController();
  final discountController = TextEditingController();
  final netAmountController = TextEditingController();
  final marginController = TextEditingController();
  final mrpController = TextEditingController();
  final saleRateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Sell Bill'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dropdown to select purchase party from "purchase party account" collection
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('purchase party account')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DropdownButton<String>(
                  hint: Text('Select Purchase Party'),
                  value: selectedParty,
                  items: snapshot.data?.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['account_name']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedParty = value!;
                    });
                  },
                );
              },
            ),
            SizedBox(height: 10),
            // Dropdown to select product from "productStock" collection
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('productStock')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                return DropdownButton<String>(
                  hint: Text('Select Product'),
                  value: selectedProduct,
                  items: snapshot.data?.docs.map((doc) {
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc['title']),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedProduct = value!;
                      // Fetch details like MRP, margin, sale rate for selectedProduct
                      fetchProductDetails(selectedProduct!);
                    });
                  },
                );
              },
            ),
            SizedBox(height: 10),
            // Dropdown to select party's product associated with selected product
            if (selectedProduct != null)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('productStock')
                    .doc(selectedProduct)
                    .collection('purchaseHistory')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  return DropdownButton<String>(
                    hint: Text('Select Party\'s Product'),
                    value: selectedPartyProduct,
                    items: snapshot.data?.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doc['partyName']),
                            Text(
                              "MRP: ${doc['mrp']} | Margin: ${doc['margin']} | Purchase Rate: ${doc['purchaseRate']}",
                              style: TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      // Find the selected party product document
                      var selectedDoc = snapshot.data!.docs
                          .firstWhere((doc) => doc.id == value);
                      // Update selected party product and fetch details
                      setState(() {
                        selectedPartyProduct = value!;
                        mrpController.text = selectedDoc['mrp'].toString();
                        marginController.text =
                            selectedDoc['margin'].toString();
                        saleRateController.text =
                            selectedDoc['purchaseRate'].toString();
                        // Update controllers if necessary
                        fetchProductDetails(selectedProduct!);
                        calculateAmount();
                      });
                    },
                  );
                },
              ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantity = int.tryParse(value);
                  calculateAmount(); // Call calculateAmount() on quantity change
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'MRP'),
              keyboardType: TextInputType.number,
              readOnly: true,
              controller: mrpController,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Margin (%)'),
              keyboardType: TextInputType.number,
              controller: marginController,
              onChanged: (value) {
                setState(() {
                  if (mrp != null && value.isNotEmpty) {
                    marginPercentage = double.tryParse(value);
                    calculateSaleRate();
                  }
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Sale Rate'),
              keyboardType: TextInputType.number,
              controller: saleRateController,
              onChanged: (value) {
                setState(() {
                  saleRate = double.tryParse(value);
                  calculateAmount(); // Call calculateAmount() on sale rate change
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              controller: amountController,
              readOnly: true,
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Discount'),
              keyboardType: TextInputType.number,
              controller: discountController,
              onChanged: (value) {
                setState(() {
                  discount = double.tryParse(value);
                  calculateNetAmount();
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: 'Net Amount'),
              keyboardType: TextInputType.number,
              readOnly: true,
              controller: netAmountController,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: addProductToBill,
              child: Text('Add Product to Bill'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: billItems.length,
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  return ListTile(
                    title: Text(item['productName']),
                    subtitle: Text('Quantity: ${item['quantity']}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          billItems.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveSellBill,
              child: Text('Save Sell Bill'),
            ),
          ],
        ),
      ),
    );
  }

  void fetchProductDetails(String productId) async {
    final productDoc = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productId)
        .get();

    setState(() {
      mrp = productDoc['mrp'];
      mrpController.text = mrp.toString();
      marginPercentage = productDoc['margin'];
      marginController.text = marginPercentage!.toStringAsFixed(2);
      saleRate = productDoc['purchaseRate'];
      saleRateController.text = saleRate!.toStringAsFixed(2);
      calculateAmount(); // Call calculateAmount after setting saleRate
    });
  }

  void calculateSaleRate() {
    if (mrp != null && marginPercentage != null) {
      double calculatedMargin = marginPercentage! / 100;
      setState(() {
        saleRate = mrp! * (1 + calculatedMargin);
        saleRateController.text = saleRate!.toStringAsFixed(2);
        calculateAmount();
      });
    }
  }

  void calculateAmount() {
    if (quantity != null && saleRate != null) {
      setState(() {
        amount = quantity! * saleRate!;
        amountController.text =
            amount!.toStringAsFixed(2); // Update amount field
        calculateNetAmount(); // Call calculateNetAmount() if needed
      });
    }
  }

  void calculateNetAmount() {
    if (amount != null && discount != null) {
      setState(() {
        netAmount = amount! - discount!;
        netAmountController.text = netAmount!.toStringAsFixed(2);
      });
    }
  }

  void addProductToBill() {
    if (selectedParty != null &&
        selectedProduct != null &&
        selectedPartyProduct != null &&
        quantity != null &&
        amount != null &&
        netAmount != null) {
      final item = {
        'partyId': selectedParty,
        'productId': selectedProduct,
        'partyProductId': selectedPartyProduct,
        'productName':
            selectedPartyProduct, // Adjust as needed based on actual data structure
        'quantity': quantity,
        'mrp': mrpController.text,
        'margin': marginController.text,
        'saleRate': saleRate,
        'amount': amount,
        'discount': discount,
        'netAmount': netAmount,
      };
      setState(() {
        billItems.add(item);
        // Clear fields after adding item to bill
        selectedPartyProduct = null;
        quantity = null;
        amount = null;
        discount = null;
        netAmount = null;
        amountController.clear();
        discountController.clear();
        netAmountController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
    }
  }

  void saveSellBill() async {
    if (billItems.isNotEmpty) {
      double grandTotal = 0;
      List<Map<String, dynamic>> itemsToSave = [];

      for (var item in billItems) {
        grandTotal += item['netAmount'];
        itemsToSave.add({
          'partyId': item['partyId'],
          'productId': item['productId'],
          'partyProductId': item['partyProductId'],
          'productName': item['productName'],
          'quantity': item['quantity'],
          'mrp': item['mrp'],
          'margin': item['margin'],
          'saleRate': item['saleRate'],
          'amount': item['amount'],
          'discount': item['discount'],
          'netAmount': item['netAmount'],
          'date': Timestamp.now(),
        });
      }

      await FirebaseFirestore.instance.collection('sellBills').add({
        'grandTotal': grandTotal,
        'items': itemsToSave,
        'date': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sell Bill Saved')),
      );

      setState(() {
        billItems.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No items to save')),
      );
    }
  }
}
