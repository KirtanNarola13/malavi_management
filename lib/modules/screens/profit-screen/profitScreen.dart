import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfitScreen extends StatelessWidget {
  const ProfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference sellBillsCollection =
        FirebaseFirestore.instance.collection('sellBills');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: sellBillsCollection.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bills = snapshot.data!.docs;
          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index].data() as Map<String, dynamic>;
              final items = bill['items'] as List<dynamic>;

              double totalProfit = 0.0;
              for (var item in items) {
                final purchaseRate = item['purchaseRate'];
                final saleRate = item['saleRate'] as double;
                final quantity = item['quantity'] as int;

                if (saleRate != null &&
                    purchaseRate != null &&
                    quantity != null) {
                  totalProfit += (saleRate - purchaseRate) * quantity;
                }
              }

              return Card(
                margin: const EdgeInsets.all(15),
                color: Colors.yellow.shade200.withOpacity(0.8),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(bill['party_name']),
                    subtitle: Text(bill['date']),
                    children: [
                      Column(
                        children: items.map<Widget>((item) {
                          double purchaseRate = item['purchaseRate'] ?? 00.00;
                          double saleRate = item['saleRate'] ?? 00.00;
                          int quantity = item['quantity'] ?? 00;
                          double profit = (saleRate - purchaseRate) * quantity;

                          return ListTile(
                            title: Text('Product: ${item['productName']}'),
                            subtitle: Text(
                                'Quantity: ${item['quantity']}, Profit: ${profit.toStringAsFixed(2)}'),
                          );
                        }).toList(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Total Profit: ${totalProfit.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
