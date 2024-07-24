import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
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
                margin: const EdgeInsets.all(15),
                color: Colors.yellow.shade200.withOpacity(0.8),
                child: Theme(
                  data: ThemeData().copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    title: Text(
                      bill['party_name'],
                    ),
                    subtitle: Text(
                      bill['date'],
                    ),
                    children: [
                      Column(
                        children: items.map<Widget>((item) {
                          return ListTile(
                            title: Text('Product: ${item['productName']}'),
                            subtitle: Text(
                                'Quantity: ${item['quantity']}, Net Amount: ${item['netAmount']}'),
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
    pw.Widget buildCell(String text, {bool isHeader = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(
          8.0,
        ),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isHeader ? 16 : 14,
            fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('PURVA SALES', style: const pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Invoice number: ${bill['billNumber']}',
                      style: const pw.TextStyle(fontSize: 18)),
                  pw.Text('Date of issue: ${bill['date']}',
                      style: const pw.TextStyle(fontSize: 18)),
                ],
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Table(
                border: pw.TableBorder.all(), // Optional: Adds border to table
                children: [
                  // Table header
                  pw.TableRow(
                    children: [
                      buildCell('Description', isHeader: true),
                      buildCell('Quantity', isHeader: true),
                      buildCell('Price/Unit', isHeader: true),
                      buildCell('Amount', isHeader: true),
                    ],
                  ),
                  // Table rows
                  ...((bill['items'] as List).map((item) {
                    String formattedAmount = item['netAmount'].toStringAsFixed(
                      2,
                    );
                    return pw.TableRow(
                      children: [
                        buildCell(item['productName']),
                        buildCell(item['quantity'].toString()),
                        buildCell(item['discount']
                            .toString()), // Ensure this key exists in your data
                        buildCell(formattedAmount),
                      ],
                    );
                  }).toList()),
                  pw.TableRow(
                    children: [
                      buildCell(''),
                      buildCell(''),
                      buildCell('Total'),
                      buildCell(
                        '${bill['grandTotal'].toStringAsFixed(
                          2,
                        )}',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

// Helper function to build table cells with centered text

    return pdf;
  }
}
