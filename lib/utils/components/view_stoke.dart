import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStock extends StatefulWidget {
  const ViewStock({super.key});

  @override
  State<ViewStock> createState() => _ViewStockState();
}

class _ViewStockState extends State<ViewStock> {
  final TextEditingController searchController = TextEditingController();

  List _allResult = [];
  List _resutlList = [];

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
    getAllProducts();
  }

  getAllProducts() async {
    var data =
        await FirebaseFirestore.instance.collection('productStock').get();
    setState(
      () {
        _allResult = data.docs;
      },
    );
    searchResultList();
  }

  // @override
  // void initState() {
  //   searchController.addListener(_onSearchChanged);
  //   super.initState();
  // }

  void _onSearchChanged() {
    searchResultList();
  }

  void searchResultList() {
    var showResult = [];
    if (searchController.text.isNotEmpty) {
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
  // _onSearchChanged() {
  //   searchResultList();
  // }
  //
  // searchResultList() {
  //   var showResult = [];
  //   if (searchController.text != "") {
  //     for (var productSnapshot in _allResult) {
  //       var name = productSnapshot['title'].toString().toLowerCase();
  //       if (name.contains(searchController.text.toLowerCase())) {
  //         showResult.add(productSnapshot);
  //       }
  //     }
  //   } else {
  //     showResult = List.from(_allResult);
  //   }
  //
  //   setState(
  //     () {
  //       _resutlList = showResult;
  //     },
  //   );
  // }

  // @override
  // void dispose() {
  //   searchController.removeListener(
  //     _onSearchChanged,
  //   );
  //   super.dispose();
  // }

  @override
  void didChangeDependencies() {
    getAllProducts();
    super.didChangeDependencies();
  }
  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    double height = MediaQuery.sizeOf(context).height;
    double width = MediaQuery.sizeOf(context).width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Product Stock',
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('productStock').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.only(
                      left: 10,
                    ),
                    margin: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    height: height / 16,
                    width: width / 1.2,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        40,
                      ),
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
                        SizedBox(
                          width: width / 35,
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: width / 1.5,
                          child: TextFormField(
                            controller: searchController,
                            decoration: const InputDecoration(
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
                      var productDoc = _resutlList[index];
                      var productName = productDoc.id;

                      return Card(
                        margin: const EdgeInsets.all(
                          10,
                        ),
                        color: Colors.yellow.shade200.withOpacity(0.5),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            title: Text(productName),
                            subtitle: FutureBuilder<QuerySnapshot>(
                              future: FirebaseFirestore.instance
                                  .collection('productStock')
                                  .doc(productName)
                                  .collection('purchaseHistory')
                                  .get(),
                              builder: (context, historySnapshot) {
                                if (!historySnapshot.hasData) {
                                  return const Text('Loading...');
                                }

                                var historyDocs = historySnapshot.data!.docs;
                                var totalQuantity = historyDocs.fold<int>(
                                  0,
                                  (previousValue, element) {
                                    var historyData =
                                        element.data() as Map<String, dynamic>;
                                    return previousValue +
                                        (historyData['quantity'] as int? ?? 0);
                                  },
                                );
                                return Text(
                                  'Total Quantity: $totalQuantity',
                                );
                              },
                            ),
                            children: [
                              FutureBuilder<QuerySnapshot>(
                                future: FirebaseFirestore.instance
                                    .collection('productStock')
                                    .doc(productName)
                                    .collection('purchaseHistory')
                                    .get(),
                                builder: (context, historySnapshot) {
                                  if (!historySnapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  var historyDocs = historySnapshot.data!.docs;

                                  return Column(
                                    children: historyDocs.map((doc) {
                                      var historyData =
                                          doc.data() as Map<String, dynamic>;
                                      var partyName = historyData['partyName'];
                                      var quantity =
                                          historyData['quantity'] as int? ?? 0;
                                      var totalAmount = historyData[
                                          'totalAmount']; // assuming it's a double or int, handle accordingly
                                      var date =
                                          historyData['date'] as Timestamp;
                                      var formattedDate =
                                          date.toDate().toLocal().toString();

                                      return ListTile(
                                        title: Text('Party: $partyName'),
                                        subtitle: Text(
                                          'Quantity: $quantity\nTotal Amount: $totalAmount\nDate: $formattedDate',
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
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
