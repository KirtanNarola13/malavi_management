import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share/share.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final CollectionReference sellBillsCollection =
      FirebaseFirestore.instance.collection('sellBills');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
      ),
      body: StreamBuilder(
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
              final bill = bills[index];
              final items = bill['items'] as List;

              return Card(
                margin: EdgeInsets.all(15),
                color: Colors.yellow.shade200.withOpacity(0.8),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(bill['party_name']),
                    subtitle: Text(bill['date']),
                    children: [
                      Column(
                        children: items.map<Widget>((item) {
                          return ListTile(
                            title: Text('Product: ${item['productName']}'),
                            subtitle: Text(
                                'Quantity: ${item['quantity']}, Net Amount: ${item['net amount']}'),
                          );
                        }).toList(),
                      ),
                      ButtonBar(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () async {
                              final pdf = await generatePdf(bill);
                              final tempDir = await getTemporaryDirectory();
                              final file = File('${tempDir.path}/bill.pdf');
                              await file.writeAsBytes(await pdf.save());
                              Share.shareFiles([file.path], text: 'Your Bill');
                            },
                          ),
                          // IconButton(
                          //   icon: const Icon(Icons.edit),
                          //   onPressed: () {
                          //     // Implement editing functionality
                          //   },
                          // ),
                        ],
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

  Future<pw.Document> generatePdf(QueryDocumentSnapshot bill) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('JEWELLERY INVOICE', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Invoice number: ',
                          style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Date of issue: ${bill['date']}',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Billed to: ', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Billed by: ', style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ['Description', 'Quantity', 'Price/Unit', 'Amount'],
                data: (bill['items'] as List).map((item) {
                  return [
                    item['productName'],
                    item['quantity'],
                    item['price/unit'], // Ensure this key exists in your data
                    item['net amount'],
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Subtotal: ', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Discount: ', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Tax rate: ', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Tax: ', style: pw.TextStyle(fontSize: 18)),
                      pw.Text('Invoice total: ${bill['grandTotal']}',
                          style: pw.TextStyle(fontSize: 18)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Terms & Conditions', style: pw.TextStyle(fontSize: 18)),
            ],
          );
        },
      ),
    );

    return pdf;
  }
}
