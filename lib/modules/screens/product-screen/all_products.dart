import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({Key? key}) : super(key: key);

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('products').get();

    List<Map<String, dynamic>> products = [];
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;
      productData['id'] = doc.id; // Add document ID to the map
      products.add(productData);
    });

    return products;
  }

  void _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      // Optionally, show a success message or update UI
    } catch (e) {
      // Handle error
      print("Error deleting product: $e");
      // Optionally, show an error message
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Products"),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching products"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No products available"));
          }
          List<Map<String, dynamic>> products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> product = products[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  color: Colors.yellow.shade50.withOpacity(0.5),
                  child: Theme(
                    data:
                        ThemeData().copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: Image.network(
                        product[
                            'image_url'], // Replace with your image URL from Firestore
                        width: 50, // Adjust size as needed
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(product['title'] ?? 'No title'),
                      subtitle: Text("category : ${product['category']}"),
                      children: [
                        ListTile(
                          title:
                              Text(product['description'] ?? 'No description'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Pur rate :${product['pur_rate'] ?? 'No Pur rate'}"),
                              Text(
                                  "Sale rate :${product['sale_rate'] ?? 'No Sale rate'}"),
                              Text("Mrp rate :${product['mrp'] ?? 'No Mrp'}"),
                            ],
                          ),
                          trailing: Text("Qty: ${product['qty']}"),
                        ),
                        ButtonBar(
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                // Navigate to edit screen or show dialog
                                // For simplicity, you can print the product ID here
                                print("Edit product: ${product['id']}");
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Edit',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () {
                                // Show confirmation dialog before deleting
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Product"),
                                    content: const Text(
                                        "Are you sure you want to delete this product?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteProduct(product['id']);
                                        },
                                        child: const Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.black,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
