import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseBillHistory extends StatefulWidget {
  const PurchaseBillHistory({super.key});

  @override
  State<PurchaseBillHistory> createState() => _PurchaseBillHistoryState();
}

class _PurchaseBillHistoryState extends State<PurchaseBillHistory> {
  final TextEditingController searchController = TextEditingController();

  List _allResult = [];
  List _resutlList = [];

  getAllProducts() async {
    var data =
        await FirebaseFirestore.instance.collection('pendingBills').get();
    setState(() {
      _allResult = data.docs;
    });
    searchResultList();
  }

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged() {
    searchResultList();
  }

  searchResultList() {
    var showResult = [];
    if (searchController.text != "") {
      for (var productSnapshot in _allResult) {
        var name = productSnapshot['partyName'].toString().toLowerCase();
        if (name.contains(searchController.text.toLowerCase())) {
          showResult.add(productSnapshot);
        }
      }
    } else {
      showResult = List.from(_allResult);
    }

    setState(() {
      _resutlList = showResult;
    });
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getAllProducts();
    super.didChangeDependencies();
  }

  Widget build(BuildContext context) {
    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills List'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('pendingBills').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();

          final bills = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    margin: EdgeInsets.only(bottom: 10),
                    height: height / 16,
                    width: width / 1.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.grey.shade700,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_outlined,
                          color: Colors.grey.shade700,
                        ),
                        SizedBox(width: width / 35),
                        Container(
                          alignment: Alignment.center,
                          width: width / 1.5,
                          child: TextFormField(
                            controller: searchController,
                            decoration: InputDecoration(
                              hintText: 'Search product',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height / 1,
                  child: ListView.builder(
                    itemCount: _resutlList.length,
                    itemBuilder: (context, index) {
                      final bill = _resutlList[index];
                      final Timestamp timestamp = bill['date'];
                      final DateTime billDate = timestamp.toDate();
                      final int daysAgo =
                          DateTime.now().difference(billDate).inDays;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        color: Colors.yellow.shade200.withOpacity(0.8),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text('Party: ${bill['partyName']}'),
                            subtitle: Text('Product: ${bill['productName']}'),
                            trailing: Text('$daysAgo days ago'),
                            children: [
                              ListTile(
                                title: const Text('Quantity'),
                                subtitle: Text('${bill['quantity']}'),
                              ),
                              ListTile(
                                title: const Text('MRP'),
                                subtitle: Text(
                                    "₹ ${double.parse(bill['mrp'].toString()).toStringAsFixed(2)}"),
                              ),
                              ListTile(
                                title: const Text('Purchase Rate'),
                                subtitle: Text(
                                    "₹ ${double.parse(bill['purchaseRate'].toString()).toStringAsFixed(2)}"),
                              ),
                              ListTile(
                                title: const Text('Total Amount'),
                                subtitle: Text(
                                    " ₹ ${double.parse(bill['totalAmount'].toString()).toStringAsFixed(2)}"),
                              ),
                              ListTile(
                                title: const Text('Margin'),
                                subtitle: Text(
                                    '${double.parse(bill['margin'].toString()).toStringAsFixed(2)}%'),
                              ),
                              ListTile(
                                title: const Text('Sale rate'),
                                subtitle: Text(
                                    ' ₹ ${double.parse(bill['saleRate'].toString()).toStringAsFixed(2)}'),
                              ),
                              ListTile(
                                title: const Text('Date'),
                                subtitle: Text(
                                    '${billDate.day} - ${billDate.month} - ${billDate.year}'),
                              ),
                              ListTile(
                                title: const Text('Time'),
                                subtitle: Text(
                                    '${billDate.hour} : ${billDate.minute}'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
