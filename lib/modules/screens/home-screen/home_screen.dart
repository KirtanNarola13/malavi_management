import 'package:flutter/material.dart';
import 'package:malavi_management/utils/components/add_account.dart';
import 'package:malavi_management/utils/components/product_screen.dart';
import 'package:malavi_management/modules/screens/product-screen/all_products.dart';

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
        padding: const EdgeInsets.all(30),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 30,
          crossAxisSpacing: 30,
        ),
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProductScreen(),
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
                      Icons.add_box_outlined,
                      size: 35,
                    ),
                    Text(
                      "Add Products",
                      style: TextStyle(
                          fontSize: 18,
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
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddAccount(),
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
                      Icons.account_box_outlined,
                      size: 35,
                    ),
                    Text(
                      "Add Account",
                      style: TextStyle(
                          fontSize: 18,
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
        ],
      ),
    );
  }
}
