import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'bill_edit_screen.dart'; // Import the edit screen

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final CollectionReference sellBillsCollection =
      FirebaseFirestore.instance.collection('sellBills');

  Future<void> _deleteBill(String billId) async {
    await FirebaseFirestore.instance
        .collection('sellBills')
        .doc(billId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill'),
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
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) =>
                              //         EditBillScreen(bill: bill),
                              //   ),
                              // );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () async {
                              final shouldDelete = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Bill'),
                                  content: const Text(
                                      'Are you sure you want to delete this bill?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );

                              if (shouldDelete == true) {
                                await _deleteBill(bills[index].id);
                              }
                            },
                          ),
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

  Future<pw.Document> generatePdf(Map<String, dynamic> bill) async {
    final pdf = pw.Document();

    pw.Widget buildCell(String text, {bool isHeader = false}) {
      return pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text(
          text,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: isHeader ? 10 : 9,
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
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(children: [
                    pw.Text(
                      '${bill['party_name']}',
                      style: const pw.TextStyle(fontSize: 24),
                    ),
                  ]),
                  pw.Column(
                    children: [
                      pw.Text(
                        'PURVA SALES',
                        style: const pw.TextStyle(fontSize: 24),
                      ),
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
                    ],
                  )
                ],
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: {
                  0: const pw.FixedColumnWidth(200),
                  1: const pw.FixedColumnWidth(50),
                  2: const pw.FixedColumnWidth(50),
                  3: const pw.FixedColumnWidth(50),
                  4: const pw.FixedColumnWidth(50),
                  5: const pw.FixedColumnWidth(50),
                  6: const pw.FixedColumnWidth(70),
                },
                children: [
                  pw.TableRow(
                    children: [
                      buildCell('Name', isHeader: true),
                      buildCell('MRP', isHeader: true),
                      buildCell('Quantity', isHeader: true),
                      buildCell('Free', isHeader: true),
                      buildCell('Price', isHeader: true),
                      buildCell('Discount', isHeader: true),
                      buildCell('Amount', isHeader: true),
                    ],
                  ),
                  ...((bill['items'] as List<dynamic>).map((item) {
                    String formattedAmount =
                        item['netAmount'].toStringAsFixed(2);
                    String formattedPrice = item['saleRate'].toStringAsFixed(2);

                    return pw.TableRow(
                      children: [
                        buildCell(item['productName']),
                        buildCell(item['mrp'].toString()),
                        buildCell(item['quantity'].toString()),
                        buildCell(item['freeQuantity'].toString()),
                        buildCell(formattedPrice),
                        buildCell(item['discount'].toString()),
                        buildCell(formattedAmount),
                      ],
                    );
                  }).toList()),
                  pw.TableRow(
                    children: [
                      buildCell(''),
                      buildCell(''),
                      buildCell(''),
                      buildCell(''),
                      buildCell(''),
                      buildCell('Total'),
                      buildCell(
                        '${bill['grandTotal'].toStringAsFixed(2)}',
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

    return pdf;
  }
}
