import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SelectProductScreen extends StatelessWidget {
  final Function(String, double, double, double) onProductSelected;

  SelectProductScreen({required this.onProductSelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Product'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('productStock').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          return ListView(
            children: snapshot.data!.docs.map((doc) {
              return ListTile(
                title: Text(doc['title']),
                subtitle: Text(
                    '| Margin: ${doc['margin']} | Sale Rate: ${doc['saleRate']}'),
                onTap: () {
                  onProductSelected(
                    doc['title'],
                    doc['mrp'],
                    doc['margin'],
                    doc['saleRate'],
                  );
                  Navigator.pop(context);
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
