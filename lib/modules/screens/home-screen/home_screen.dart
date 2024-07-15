import 'package:flutter/material.dart';
import 'package:malavi_management/utils/components/all_products.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: GridView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllProducts(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(30),
            splashColor: Colors.yellow,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.yellow.withOpacity(0.5),
                borderRadius: const BorderRadius.all(
                  Radius.circular(30),
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 1,
                    ),
                    Icon(
                      Icons.shopping_bag,
                      size: 50,
                    ),
                    Text(
                      "All Products",
                      style: TextStyle(
                          fontSize: 22,
                          letterSpacing: 1,
                          fontStyle: FontStyle.italic),
                    ),
                    SizedBox(
                      height: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.green.shade200,
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(30),
          //     ),
          //   ),
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.green.shade200,
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(30),
          //     ),
          //   ),
          // ),
          // Container(
          //   decoration: BoxDecoration(
          //     color: Colors.green.shade200,
          //     borderRadius: BorderRadius.all(
          //       Radius.circular(30),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
