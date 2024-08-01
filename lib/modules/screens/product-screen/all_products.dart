import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_edit.dart';

class AllProducts extends StatefulWidget {
  const AllProducts({super.key});

  @override
  State<AllProducts> createState() => _AllProductsState();
}

class _AllProductsState extends State<AllProducts> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController searchController = TextEditingController();

  List _allResult = [];

  Future<List<Map<String, dynamic>>> _fetchProducts() async {
    QuerySnapshot querySnapshot = await _firestore.collection('products').get();

    List<Map<String, dynamic>> products = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> productData = doc.data() as Map<String, dynamic>;
      productData['id'] = doc.id; // Add document ID to the map
      products.add(productData);
    }

    return products;
  }

  void _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      setState(() {}); // Refresh the list after deleting
    } catch (e) {
      if (kDebugMode) {
        print(
          "Error deleting product: $e",
        );
      }
    }
  }

  @override
  void initState() {
    searchController.addListener(_onSearchChanged);
    super.initState();
    getAllProducts();
  }

  Future<void> getAllProducts() async {
    var data = await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      _allResult = data.docs;
    });
    searchResultList();
  }

  void _onSearchChanged() {
    searchResultList();
  }

  void searchResultList() {
    var showResult = [];
    if (searchController.text.isNotEmpty) {
      for (var productSnapshot in _allResult) {
        var name = productSnapshot['category'].toString().toLowerCase();
        if (name.contains(searchController.text.toLowerCase())) {
          showResult.add(productSnapshot);
        }
      }
    } else {
      showResult = List.from(_allResult);
    }

    setState(
      () {
        _allResult = showResult;
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Products",
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                margin: const EdgeInsets.only(bottom: 10),
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
                    SizedBox(
                      width: width / 35,
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: width / 1.5,
                      child: TextFormField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search by products',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 8,
            child: FutureBuilder<List<Map<String, dynamic>>>(
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
                      padding: const EdgeInsets.all(
                        8.0,
                      ),
                      child: Card(
                        color: Colors.yellow.shade200.withOpacity(
                          0.8,
                        ),
                        child: Theme(
                          data: ThemeData()
                              .copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: NetworkImage(
                                product['image_url'],
                              ),
                            ),
                            title: Text(product['title'] ?? 'No title'),
                            subtitle: Text("Category: ${product['category']}"),
                            children: [
                              ListTile(
                                title: Text(
                                  "Company : ${product['company'] ?? 'No company'}",
                                ),
                                subtitle: Text(
                                  "Unit : ${product['units'] ?? 'No units'}",
                                ),
                              ),
                              ButtonBar(
                                children: [
                                  TextButton.icon(
                                    onPressed: () async {
                                      // Navigate to edit screen
                                      bool? result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProduct(product: product),
                                        ),
                                      );
                                      if (result == true) {
                                        // Refresh the list after editing
                                        setState(() {});
                                      }
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
                                          title: const Text(
                                            "Delete Product",
                                          ),
                                          content: const Text(
                                            "Are you sure you want to delete this product?",
                                          ),
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
                                                _deleteProduct(
                                                  product['id'],
                                                );
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
          ),
        ],
      ),
    );
  }
}
