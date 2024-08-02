// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class SellBillScreen extends StatefulWidget {
//   const SellBillScreen({super.key});
//
//   @override
//   _SellBillScreenState createState() => _SellBillScreenState();
// }
//
// class _SellBillScreenState extends State<SellBillScreen> {
//   String? selectedParty;
//   String? selectedProduct;
//   String? selectedPartyProduct;
//   String? salesMan;
//   double? mrp;
//   double? marginPercentage;
//   double? saleRate;
//   int? quantity;
//   int? freeQuantity;
//   double? amount;
//   double? discount;
//   double? netAmount;
//   List<Map<String, dynamic>> billItems = [];
//   String? billNumber; // Add this field to store the bill number
//
//   final amountController = TextEditingController();
//   final freeQuantityController = TextEditingController();
//   final salesManController = TextEditingController();
//   final discountController = TextEditingController();
//   final netAmountController = TextEditingController();
//   final marginController = TextEditingController();
//   final mrpController = TextEditingController();
//   final saleRateController = TextEditingController();
//
//   void _showProductSelectionDialog() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('Select Product'),
//           content: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('productStock')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return Text('No products found');
//               }
//               return ListView(
//                 children: snapshot.data!.docs.map((doc) {
//                   return ListTile(
//                     title: Text(doc['productName']),
//                     onTap: () {
//                       setState(() {
//                         selectedProduct = doc['productName'];
//                         Navigator.pop(context);
//                       });
//                       fetchProductDetails(selectedProduct!);
//                     },
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text('Cancel'),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset: true,
//       appBar: AppBar(
//         title: const Text('Create Sell Bill'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Dropdown to select purchase party from "sale party account" collection
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('sale party account')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Text('No party accounts found');
//                   }
//                   return DropdownButtonFormField<String>(
//                     value: selectedParty,
//                     items: snapshot.data!.docs.map((doc) {
//                       return DropdownMenuItem<String>(
//                         value: doc['account_name'],
//                         child: Text(doc['account_name']),
//                       );
//                     }).toList(),
//                     decoration: InputDecoration(
//                       labelText: 'Sell party account',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedParty = value!;
//                       });
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(height: 10),
//
//               // Dropdown to select product from "productStock" collection
//               StreamBuilder<QuerySnapshot>(
//                 stream: FirebaseFirestore.instance
//                     .collection('productStock')
//                     .snapshots(),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                     return const Text('No products found');
//                   }
//                   return DropdownButtonFormField<String>(
//                     value: selectedProduct,
//                     items: snapshot.data!.docs.map((doc) {
//                       return DropdownMenuItem<String>(
//                         value: doc['productName'],
//                         child: Text(doc['productName']),
//                       );
//                     }).toList(),
//                     decoration: InputDecoration(
//                       labelText: 'Select Product',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                     onChanged: (value) {
//                       setState(() {
//                         selectedProduct = value!;
//                         fetchProductDetails(selectedProduct!);
//                       });
//                     },
//                   );
//                 },
//               ),
//
//               const SizedBox(height: 10),
//               // Dropdown to select party's product associated with selected product
//               if (selectedProduct != null)
//                 StreamBuilder<QuerySnapshot>(
//                   stream: FirebaseFirestore.instance
//                       .collection('productStock')
//                       .doc(selectedProduct)
//                       .collection('purchaseHistory')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return const Text('No party products found');
//                     }
//                     return DropdownButtonFormField<String>(
//                       hint: const Text('Select Party\'s Product'),
//                       value: selectedPartyProduct,
//                       items: snapshot.data!.docs.map((doc) {
//                         return DropdownMenuItem<String>(
//                           value: doc.id,
//                           child: SingleChildScrollView(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   doc['partyName'],
//                                 ),
//                                 Text(
//                                   "MRP: ${doc['mrp']} | Margin: ${doc['margin']} | Purchase Rate: ${doc['saleRate']}",
//                                   style: const TextStyle(
//                                     fontSize: 10,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                       decoration: InputDecoration(
//                         labelText: 'Party products',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(
//                             10,
//                           ),
//                         ),
//                       ),
//                       onChanged: (value) {
//                         var selectedDoc = snapshot.data!.docs
//                             .firstWhere((doc) => doc.id == value);
//                         setState(() {
//                           selectedPartyProduct = value!;
//                           mrpController.text = selectedDoc['mrp'].toString();
//                           marginController.text =
//                               selectedDoc['margin'].toString();
//                           saleRateController.text =
//                               selectedDoc['saleRate'].toString();
//                           fetchProductDetails(selectedProduct!);
//                           calculateAmount();
//                         });
//                       },
//                     );
//                   },
//                 ),
//               const SizedBox(height: 15),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: TextFormField(
//                   decoration: const InputDecoration(
//                     labelText: 'Sales Man',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                       borderSide: BorderSide(color: Colors.yellow),
//                     ),
//                   ),
//                   controller: salesManController,
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() {
//                       salesMan = value;
//                     });
//                   },
//                 ),
//               ),
//               // Quantity input
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: TextFormField(
//                   decoration: const InputDecoration(
//                     labelText: 'Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                       borderSide: BorderSide(color: Colors.yellow),
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: (value) {
//                     setState(() {
//                       quantity = int.tryParse(value);
//                       calculateAmount(); // Call calculateAmount() on quantity change
//                     });
//                   },
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 16.0),
//                 child: TextFormField(
//                   decoration: const InputDecoration(
//                     labelText: 'Free Quantity',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.all(Radius.circular(10.0)),
//                       borderSide: BorderSide(color: Colors.yellow),
//                     ),
//                   ),
//                   controller: freeQuantityController,
//                   keyboardType: TextInputType.number,
//                 ),
//               ),
//
//               // MRP and Margin in a single row
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'MRP',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       readOnly: true,
//                       controller: mrpController,
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'Margin (%)',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       controller: marginController,
//                       onChanged: (value) {
//                         setState(() {
//                           if (mrp != null && value.isNotEmpty) {
//                             marginPercentage = double.tryParse(value);
//                             calculateSaleRate();
//                           }
//                         });
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//
//               // Sale Rate and Amount in a single row
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'Sale Rate',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       controller: saleRateController,
//                       onChanged: (value) {
//                         setState(() {
//                           saleRate = double.tryParse(value);
//                           calculateAmount(); // Call calculateAmount() on sale rate change
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'Amount',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       controller: amountController,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//
//               // Discount and Net Amount in a single row
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'Discount',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       controller: discountController,
//                       onChanged: (value) {
//                         setState(() {
//                           discount = double.tryParse(value);
//                           calculateNetAmount();
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Expanded(
//                     child: TextField(
//                       decoration: const InputDecoration(
//                         labelText: 'Net Amount',
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.all(Radius.circular(10)),
//                         ),
//                       ),
//                       keyboardType: TextInputType.number,
//                       controller: netAmountController,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//
//               // Add Product Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: addProductToBill,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.yellow[700],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 30,
//                       vertical: 10,
//                     ),
//                   ),
//                   child: const Text(
//                     'Add Product',
//                     style: TextStyle(
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // List of added products
//               Visibility(
//                 visible: billItems.isNotEmpty,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Added Products:',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 5),
//                     Container(
//                       height: 200,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.black26),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       child: ListView.builder(
//                         itemCount: billItems.length,
//                         itemBuilder: (context, index) {
//                           final item = billItems[index];
//                           return ListTile(
//                             title: Text(item['productName']),
//                             subtitle: Text('Quantity: ${item['quantity']}'),
//                             trailing: IconButton(
//                               icon: const Icon(Icons.delete),
//                               onPressed: () {
//                                 setState(
//                                   () {
//                                     billItems.removeAt(index);
//                                   },
//                                 );
//                               },
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                   ],
//                 ),
//               ),
//
//               // Save Bill Button
//               Center(
//                 child: ElevatedButton(
//                   onPressed: saveSellBill,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.yellow[700],
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 30,
//                       vertical: 10,
//                     ),
//                   ),
//                   child: const Text(
//                     'Save Sell Bill',
//                     style: TextStyle(
//                       fontSize: 18,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Future<void> fetchProductDetails(String productName) async {
//     final doc = await FirebaseFirestore.instance
//         .collection('productStock')
//         .doc(productName)
//         .get();
//     if (doc.exists) {
//       setState(() {
//         mrp = doc['mrp'];
//         marginPercentage = doc['margin'];
//         saleRate = doc['saleRate'];
//       });
//       mrpController.text = mrp.toString();
//       marginController.text = marginPercentage.toString();
//       saleRateController.text = saleRate.toString();
//       calculateAmount();
//     }
//   }
//
//   void calculateSaleRate() {
//     if (mrp != null && marginPercentage != null) {
//       saleRate = mrp! * (1 - (marginPercentage! / 100));
//       saleRateController.text = saleRate!.toStringAsFixed(2);
//     }
//   }
//
//   void calculateAmount() {
//     if (saleRate != null && quantity != null) {
//       amount = saleRate! * quantity!;
//       amountController.text = amount!.toStringAsFixed(2);
//       calculateNetAmount();
//     }
//   }
//
//   void calculateNetAmount() {
//     if (amount != null && discount != null) {
//       netAmount = amount! - (amount! * (discount! / 100));
//       netAmountController.text = netAmount!.toStringAsFixed(2);
//     }
//   }
//
//   void addProductToBill() {
//     if (selectedProduct != null && quantity != null && netAmount != null) {
//       setState(() {
//         billItems.add({
//           'partyName': selectedParty,
//           'productName': selectedProduct,
//           'quantity': quantity,
//           'freeQuantity': freeQuantityController.text,
//           'mrp': mrp,
//           'margin': marginPercentage,
//           'saleRate': saleRate,
//           'amount': amount,
//           'discount': discount,
//           'netAmount': netAmount,
//           'date':
//               "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
//         });
//         quantity = null;
//         amount = null;
//         discount = null;
//         netAmount = null;
//         salesMan = null;
//         salesManController.clear();
//         amountController.clear();
//         discountController.clear();
//         netAmountController.clear();
//         freeQuantityController.clear();
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please complete the product details')),
//       );
//     }
//   }
//
//   Future<void> fetchLastBillNumber() async {
//     final billsCollection = FirebaseFirestore.instance.collection('sellBills');
//     final lastBillDoc = await billsCollection
//         .orderBy('billNumber', descending: true)
//         .limit(1)
//         .get();
//
//     if (lastBillDoc.docs.isNotEmpty) {
//       final lastBillNumber = lastBillDoc.docs.first['billNumber'];
//       final currentNumber = int.parse(
//           lastBillNumber.substring(1)); // Remove the 'A' and convert to int
//       final newNumber = currentNumber + 1;
//       billNumber = 'A${newNumber.toString().padLeft(2, '0')}';
//     } else {
//       billNumber = 'A00'; // Start with A00 if no bills exist
//     }
//   }
//
//   void saveSellBill() async {
//     if (billItems.isNotEmpty) {
//       await fetchLastBillNumber(); // Fetch the last bill number and generate a new one
//       double grandTotal = 0;
//       List<Map<String, dynamic>> itemsToSave = [];
//
//       for (var item in billItems) {
//         grandTotal += item['netAmount'];
//         itemsToSave.add({
//           'partyName': item['partyName'],
//           'productName': item['productName'],
//           'salesMan': item['salesMan'],
//           'quantity': item['quantity'],
//           'freeQuantity': item['freeQuantity'],
//           'mrp': item['mrp'],
//           'margin': item['margin'],
//           'saleRate': item['saleRate'],
//           'amount': item['amount'],
//           'discount': item['discount'],
//           'netAmount': item['netAmount'],
//           'date':
//               "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
//         });
//       }
//
//       await FirebaseFirestore.instance.collection('sellBills').add({
//         'billNumber': billNumber,
//         'grandTotal': grandTotal,
//         'items': itemsToSave,
//         'salesMan': salesMan,
//         'date':
//             "${DateTime.now().day} / ${DateTime.now().month} / ${DateTime.now().year}",
//         'party_name': selectedParty,
//       });
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Sell Bill Saved')),
//       );
//
//       setState(() {
//         billItems.clear();
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No items to save')),
//       );
//     }
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:malavi_management/utils/components/sale_bill_edit.dart';

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
  String? billNumber;

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
        title: const Text(
          'Create Sell Bill',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        child: Text(doc['productName']),
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
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc['partyName']),
                                Text(
                                  "MRP: ${doc['mrp']} | Margin: ${doc['margin']} | Purchase Rate: ${doc['saleRate']}",
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
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
                    setState(() {
                      salesMan = value;
                    });
                  },
                ),
              ),
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
                    setState(() {
                      quantity = int.tryParse(value);
                      calculateAmount(); // Call calculateAmount() on quantity change
                    });
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
                        setState(() {
                          if (mrp != null) {
                            marginPercentage = double.tryParse(value);
                            calculateSaleRate();
                            calculateAmount();
                          }
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
                      decoration: const InputDecoration(
                        labelText: 'Sale Rate',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      readOnly: true,
                      controller: saleRateController,
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
                      readOnly: true,
                      controller: amountController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

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
                        setState(() {
                          discount = double.tryParse(value);
                          calculateNetAmount(); // Recalculate net amount on discount change
                        });
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
                      readOnly: true,
                      controller: netAmountController,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Add Product Button
              Center(
                child: ElevatedButton(
                  onPressed: addProductToBill,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow[700],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                  ),
                  child: const Text(
                    'Add Product',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductScreen(
                                          product: item,
                                          onUpdate: (updatedProduct) {
                                            setState(() {
                                              billItems[index] = updatedProduct;
                                              calculateAmount(); // Update amounts
                                            });
                                          },
                                        ),
                                      ),
                                    );
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

  Future<void> fetchProductDetails(String productName) async {
    final doc = await FirebaseFirestore.instance
        .collection('productStock')
        .doc(productName)
        .get();
    if (doc.exists) {
      setState(() {
        mrp = doc['mrp'];
        marginPercentage = doc['margin'];
        saleRate = doc['saleRate'];
        mrpController.text = mrp.toString();
        marginController.text = marginPercentage.toString();
        saleRateController.text = saleRate.toString();
        calculateAmount();
      });
    }
  }

  void calculateSaleRate() {
    if (mrp != null && marginPercentage != null) {
      final margin = marginPercentage! / 100;
      final saleRate = mrp! * (1 - margin);
      saleRateController.text = saleRate.toStringAsFixed(2);
      calculateAmount();
    }
  }

  void calculateAmount() {
    if (saleRate != null && quantity != null) {
      final amount = saleRate! * quantity!;
      amountController.text = amount.toStringAsFixed(2);
      calculateNetAmount();
    }
  }

  void calculateNetAmount() {
    if (amount != null && discount != null) {
      final netAmount = (amount! - (amount! * (discount! / 100)));
      netAmountController.text = netAmount.toStringAsFixed(2);
    }
  }

  void addProductToBill() {
    if (selectedProduct != null && quantity != null) {
      final product = {
        'productName': selectedProduct!,
        'quantity': quantity!,
        'freeQuantity': freeQuantityController.text,
        'amount': double.tryParse(amountController.text) ?? 0,
        'discount': double.tryParse(discountController.text) ?? 0,
        'netAmount': double.tryParse(netAmountController.text) ?? 0,
      };
      setState(() {
        billItems.add(product);
        clearProductDetails();
      });
    }
  }

  void clearProductDetails() {
    setState(() {
      selectedProduct = null;
      quantity = null;
      freeQuantityController.clear();
      amountController.clear();
      discountController.clear();
      netAmountController.clear();
    });
  }

  Future<void> fetchLastBillNumber() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sellBill')
        .orderBy('billNumber', descending: true)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final lastBillNumber = snapshot.docs.first['billNumber'];
      setState(() {
        billNumber = (int.parse(lastBillNumber) + 1).toString();
      });
    } else {
      setState(() {
        billNumber = '1';
      });
    }
  }

  void saveSellBill() async {
    await fetchLastBillNumber();
    final billData = {
      'billNumber': billNumber,
      'party': selectedParty,
      'salesMan': salesManController.text,
      'items': billItems,
      'totalAmount': double.tryParse(netAmountController.text) ?? 0,
    };
    await FirebaseFirestore.instance.collection('sellBill').add(billData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sell Bill saved successfully!')),
    );
    setState(() {
      billItems.clear();
      clearProductDetails();
    });
  }
}
