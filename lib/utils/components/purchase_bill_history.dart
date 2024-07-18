import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PurchaseBillHistory extends StatefulWidget {
  const PurchaseBillHistory({super.key});

  @override
  State<PurchaseBillHistory> createState() => _PurchaseBillHistoryState();
}

class _PurchaseBillHistoryState extends State<PurchaseBillHistory> {
  @override
  Widget build(BuildContext context) {
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

          return ListView.builder(
            itemCount: bills.length,
            itemBuilder: (context, index) {
              final bill = bills[index];
              final Timestamp timestamp = bill['date'];
              final DateTime billDate = timestamp.toDate();
              final int daysAgo = DateTime.now().difference(billDate).inDays;

              return Card(
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                color: Colors.yellow.shade200.withOpacity(0.8),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
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
                        subtitle: Text(double.parse(bill['mrp'].toString())
                            .toStringAsFixed(2)),
                      ),
                      ListTile(
                        title: const Text('Purchase Rate'),
                        subtitle: Text(
                            double.parse(bill['purchaseRate'].toString())
                                .toStringAsFixed(2)),
                      ),
                      ListTile(
                        title: const Text('Total Amount'),
                        subtitle: Text(
                            double.parse(bill['totalAmount'].toString())
                                .toStringAsFixed(2)),
                      ),
                      ListTile(
                        title: const Text('Margin'),
                        subtitle: Text(
                            '${double.parse(bill['margin'].toString()).toStringAsFixed(2)}%'),
                      ),
                      ListTile(
                        title: const Text('Date'),
                        subtitle: Text(
                            '${billDate.day} - ${billDate.month} - ${billDate.year}'),
                      ),
                      ListTile(
                        title: const Text('Time'),
                        subtitle: Text('${billDate.hour} : ${billDate.minute}'),
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
