import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewStock extends StatefulWidget {
  const ViewStock({super.key});

  @override
  State<ViewStock> createState() => _ViewStockState();
}

class _ViewStockState extends State<ViewStock> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Stock'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('productStock').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var productDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: productDocs.length,
            itemBuilder: (context, index) {
              var productDoc = productDocs[index];
              var productName = productDoc.id;
              var productData = productDoc.data() as Map<String, dynamic>;
              var imgUrl = productData['image_url'];

              return Card(
                margin: EdgeInsets.all(10),
                color: Colors.yellow.shade200.withOpacity(0.5),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: Container(
                      height: 50,
                      width: 50,
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                                (historyData['quantity'] as int);
                          },
                        );

                        return Text('Total Quantity: $totalQuantity');
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
                              var quantity = historyData['quantity'];
                              var totalAmount = historyData['totalAmount'];
                              var date = historyData['date'] as Timestamp;
                              var formattedDate =
                                  date.toDate().toLocal().toString();

                              return ListTile(
                                title: Text('Party: $partyName'),
                                subtitle: Text(
                                    'Quantity: $quantity\nTotal Amount: $totalAmount\nDate: $formattedDate'),
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
          );
        },
      ),
    );
  }
}
