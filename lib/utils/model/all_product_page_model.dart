class AllProductPageModel {
  String department;
  String title;
  String description;
  int price;
  int qty;

  AllProductPageModel({
    required this.department,
    required this.title,
    required this.description,
    required this.price,
    required this.qty,
  });

  Map<String, dynamic> toMap() {
    return {
      'department': department,
      'title': title,
      'description': description,
      'price': price,
      'qty': qty,
    };
  }
}
