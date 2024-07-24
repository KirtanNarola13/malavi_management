
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
  double? mrp;
  double? saleRate;
  double? margin;
  double? totalAmount;

  final marginController = TextEditingController();
  final saleRateController = TextEditingController();
  final totalAmountController = TextEditingController();

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
                        value: doc.id,
                        child: Text(doc['account_name']),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Purchase party account',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          selectedParty = value!;
                        },
                      );
                    },
                  );
                },
              ),

              const SizedBox(
                height: 10,
              ),
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
                      return DropdownMenuItem<String>(
                        value: doc.id,
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
              const SizedBox(
                height: 10,
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.yellow),
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
              const SizedBox(
                height: 10,
              ),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'MRP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    mrp = double.tryParse(value);
                    calculatePurchaseRate();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),

              TextField(
                controller: marginController,
                decoration: const InputDecoration(
                  labelText: 'Margin (%)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    margin = double.tryParse(value) ?? 0.0;
                    calculatePurchaseRate();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),

              TextField(
                controller: saleRateController,
                decoration: const InputDecoration(
                  labelText: 'Purchase Rate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    saleRate = double.tryParse(value) ?? 0.0;
                    calculateMargin();
                    calculateTotalAmount();
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),

              TextField(
                decoration: const InputDecoration(
                  labelText: 'Total Amount',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(
                        10.0,
                      ),
                    ),
                    borderSide: BorderSide(color: Colors.yellow),
                  ),
                ),
                keyboardType: TextInputType.number,
                readOnly: true,
                controller: totalAmountController,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: savePurchaseBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                ),
                child: const Text('Save Purchase Bill'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void calculatePurchaseRate() {
    if (mrp != null && margin != null && margin! > 0) {
      setState(() {
        saleRate = mrp! / (1 + (margin! / 100));
        saleRateController.text = saleRate!.toStringAsFixed(2);
        calculateTotalAmount(); // Recalculate total amount whenever purchase rate changes
      });
    }
  }

  void calculateMargin() {
    if (mrp != null && saleRate != null && saleRate! > 0) {
      setState(() {
        margin = ((mrp! - saleRate!) / mrp!) * 100;
        marginController.text = margin!.toStringAsFixed(2);
      });
    }
  }

  void calculateTotalAmount() {
    if (quantity != null && saleRate != null) {
      setState(() {
        totalAmount = quantity! * saleRate!;
        totalAmountController.text = totalAmount!.toStringAsFixed(2);
      });
    }
  }

  void clearFormFields() {
    setState(() {
      selectedProduct = null;
      selectedParty = null;
      quantity = null;
      mrp = null;
      saleRate = null;
      margin = null;
      totalAmount = null;
      marginController.clear();
      saleRateController.clear();
      totalAmountController.clear();
    });
  }

  void savePurchaseBill() async {
    if (selectedProduct != null &&
        selectedParty != null &&
        quantity != null &&
        mrp != null &&
        saleRate != null &&
        totalAmount != null) {
      // Fetch party and product details
      final partyDoc = await FirebaseFirestore.instance
          .collection('purchase party account')
          .doc(selectedParty)
          .get();
      final productDoc = await FirebaseFirestore.instance
          .collection('products')
          .doc(selectedProduct)
          .get();

      final billData = {
        'partyId': selectedParty,
        'partyName': partyDoc['account_name'],
        'productId': selectedProduct,
        'productName': productDoc['title'],
        'quantity': quantity,
        'mrp': mrp,
        'saleRate': saleRate,
        'totalAmount': totalAmount,
        'margin': margin,
        'date': Timestamp.now(),
      };

      // Save to purchaseBills collection
      await FirebaseFirestore.instance
          .collection('purchaseBills')
          .add(billData);

      // Save to pendingBills collection
      await FirebaseFirestore.instance
          .collection('pendingBills')
          .add(billData)
          .then(
        (value) {
          clearFormFields();
        },
      );

      // Perform the query to get the product data
      QuerySnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('title', isEqualTo: productDoc['title'])
          .get();

// Ensure there is data returned from the query
      if (productSnapshot.docs.isNotEmpty) {
        // Assuming you want to use the first document returned from the query
        Map<String, dynamic> productData =
            productSnapshot.docs.first.data() as Map<String, dynamic>;

        // Reference to the main collection 'productStock'
        CollectionReference productStockCollection =
            FirebaseFirestore.instance.collection('productStock');

        // Reference to the subcollection with the product name
        DocumentReference productSubcollectionRef =
            productStockCollection.doc(productDoc['title']);

        // Check if the subcollection with the product name exists
        DocumentSnapshot productSubcollectionSnapshot =
            await productSubcollectionRef.get();

        if (productSubcollectionSnapshot.exists) {
          // If the subcollection document exists, add purchase history to the subcollection's subcollection
          await productSubcollectionRef
              .collection('purchaseHistory')
              .add(billData);
        } else {
          // If the subcollection document does not exist, create it with the product data
          await productSubcollectionRef.set(productData);

          // Add purchase history to the subcollection's subcollection
          await productSubcollectionRef
              .collection('purchaseHistory')
              .add(billData);
        }
      } else {
        // Handle the case where no matching product was found
        print('No matching product found.');
      }

      // Update product stock quantity
      final productStockRef = FirebaseFirestore.instance
          .collection('productStock')
          .doc(selectedProduct);
      await productStockRef.update({
        'quantity': FieldValue.increment(quantity!),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Purchase Bill Saved')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
    }
  }
}
