import 'dart:developer';

import 'package:app_code/modules/utils/models/all_product_page_model.dart';
import 'package:app_code/modules/utils/models/chat_model.dart';
import 'package:app_code/modules/utils/models/department_page_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/organization_page_model.dart';
import 'firebase_auth_helper.dart';

class FCMHelper {
  FCMHelper._();

  static final FCMHelper fcmHelper = FCMHelper._();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;

  String inventoryCollection = "Inventory-Management";
  String userCollection = "Users";
  String departmentCollection = "Department";
  String summaryCollection = "Summary";
  String requestCollection = "Request";

  static double totalEarning = 0;
  static double totalSales = 0;
  static int items = 0;

  Future<void> storeUserInformationData(
      {required OrganizationPageDataGetModel userData}) async {
    await firestore
        .collection(inventoryCollection)
        .doc(userData.emailId)
        .set(userData.toMap());

    await firestore
        .collection(inventoryCollection)
        .doc(userData.emailId)
        .collection(userCollection)
        .doc(userData.emailId)
        .set({
      'bio': userData.companyName,
      'department': 'Owner',
      'email': userData.emailId,
      'fullName': userData.fullName,
      'profileImage':
          "https://cdn5.vectorstock.com/i/1000x1000/30/24/business-man-entrepreneur-close-up-cartoon-flat-vector-18203024.jpg",
    });

    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .set({
      'items': 0,
      'earning': 0,
      'sales': 0,
    });
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAdminData() {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;
    log(email);
    return firestore.collection(inventoryCollection).doc(email).snapshots();
  }

  Future<void> addUserData({
    required var profileImage,
    required var bgImage,
    required String fullName,
    required String userName,
    required String bio,
    required String userEmail,
    required String password,
    required String phoneNumber,
    required String dob,
    required String gender,
    required String department,
    required String companyName,
    required String location,
  }) async {
    // String fileName = "${profilePageModel.userName}.jpg";
    // Reference reference = storage.ref(fileName);
    var profileReference;
    var bgReference;
    log("Image Value : $profileImage and $bgImage");
    if (profileImage is! String) {
      log("Profile Image If Else is Running");
      profileReference = await storage
          .ref()
          .child("$userName/profile.jpg")
          .putFile(profileImage);
    }
    if (bgImage is! String) {
      log("Bg Image If Else is Running");
      bgReference =
          await storage.ref().child("$userName/bgImage.jpg").putFile(bgImage);
    }

    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(userCollection)
        .doc(userEmail)
        .set({
      'fullName': fullName,
      'userName': userName,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'dob': dob,
      'email': userEmail,
      'password': password,
      'gender': gender,
      'department': department,
      'companyName': companyName,
      'location': location,
      'profileImage': (profileImage is! String)
          ? await profileReference.ref.getDownloadURL()
          : profileImage,
      'bgImage': (bgImage is! String)
          ? await bgReference.ref.getDownloadURL()
          : bgImage,
    });
  }

  Future<void> addDepartmentWiseData(
      DepartmentPageModel departmentPageModel) async {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    var imageReference;

    if (departmentPageModel.image != null) {
      imageReference = await storage
          .ref()
          .child(
              "${departmentPageModel.department}/${departmentPageModel.title}.jpg")
          .putFile(departmentPageModel.image!);
    }

    DocumentSnapshot<Map<String, dynamic>> departmentData = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(departmentPageModel.department)
        .get();

    Map<String, dynamic> department = departmentData.data() ?? {};
    log("MYDEPARTMENT: ${departmentPageModel.department}");
    List items = department[departmentPageModel.department!] ?? [];

    items.add({
      'title': departmentPageModel.title,
      'price': departmentPageModel.price,
      'qty': departmentPageModel.qty,
      'category': departmentPageModel.category,
      'description': departmentPageModel.description,
      'image': (departmentPageModel.image != null)
          ? await imageReference.ref.getDownloadURL()
          : "https://e7.pngegg.com/pngimages/42/191/png-clipart-business-product-sample-marketing-brand-give-away-hand-people-thumbnail.png",
      'department': departmentPageModel.department
    });

    Map<String, dynamic> data = {
      departmentPageModel.department!: items,
    };
    firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(departmentPageModel.department)
        .set(data);

    DocumentSnapshot<Map<String, dynamic>> summaryData = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(departmentPageModel.department)
        .collection(summaryCollection)
        .doc("summary")
        .get();

    Map<String, dynamic> summary = summaryData.data() ?? {};
    int earning = summary['earning'] ?? 0;
    int sales = summary['sales'] ?? 0;

    firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(departmentPageModel.department)
        .collection(summaryCollection)
        .doc("summary")
        .set(
      {
        'earning': earning,
        'sales': sales,
      },
    );

    DocumentSnapshot<Map<String, dynamic>> summaryData2 = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .get();

    Map<String, dynamic> summary2 = summaryData2.data() ?? {};
    int allItems = summary2['items'] ?? 0;
    allItems++;
    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .update({
      'items': allItems,
      'earning': summary2['earning'],
      'sales': summary2['sales'],
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUserAllRequest() {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;
    return firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(requestCollection)
        .snapshots();
  }

  Future<void> deleteRequest({required String date}) async {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;
    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(requestCollection)
        .doc(date)
        .delete();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getTotalEarningAndSales() {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    return firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .snapshots();

    // for (int i = 0; i < departmentList.length; i++) {
    //   firestore
    //       .collection(inventoryCollection)
    //       .doc(email)
    //       .collection(departmentCollection)
    //       .doc(departmentList[i])
    //       .get()
    //       .then((value) {
    //     Map<String, dynamic> data = value.data() ?? {};
    //     List myItems = data[departmentList[i]] ?? [];
    //     items += myItems.length;
    //   });
    //
    //   firestore
    //       .collection(inventoryCollection)
    //       .doc(email)
    //       .collection(departmentCollection)
    //       .doc(departmentList[i])
    //       .collection(summaryCollection)
    //       .doc("summary")
    //       .get()
    //       .then((value) {
    //     Map<String, dynamic> summary = value.data() ?? {};
    //
    //     totalEarning += summary['earning'] ?? 0;
    //     totalSales += summary['sales'] ?? 0;
    //   });
    // }
    //
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getAllProducts(
      {required String department}) {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    log(department);

    return firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(department)
        .snapshots();
  }

  Future<void> deleteProduct({
    required String department,
    required String name,
  }) async {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    DocumentSnapshot<Map<String, dynamic>> data = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(department)
        .get();

    Map<String, dynamic> myData = data.data() ?? {};
    List items = myData[department];

    log("ITEMS : $items");
    items.removeWhere((element) => element['title'] == name);

    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(department)
        .set({
      department: items,
    });

    DocumentSnapshot<Map<String, dynamic>> summaryData2 = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .get();

    Map<String, dynamic> summary2 = summaryData2.data() ?? {};
    int allItems = summary2['items'] ?? 0;
    allItems--;
    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(summaryCollection)
        .doc("summary")
        .update({
      'items': allItems,
      'earning': summary2['earning'],
      'sales': summary2['sales'],
    });
  }

  Future<void> editProduct(
      {required AllProductPageModel allProductPageModel,
      required String title}) async {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;

    DocumentSnapshot<Map<String, dynamic>> data = await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(allProductPageModel.department)
        .get();

    Map<String, dynamic> myData = data.data() ?? {};
    List items = myData[allProductPageModel.department];

    items.forEach((e) {
      if (e['title'] == title) {
        e['description'] = allProductPageModel.description;
        e['price'] = allProductPageModel.price;
        e['qty'] = allProductPageModel.qty;
        e['title'] = allProductPageModel.title;
      }
    });

    await firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(departmentCollection)
        .doc(allProductPageModel.department)
        .set({
      allProductPageModel.department: items,
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    String email = FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email!;
    return firestore
        .collection(inventoryCollection)
        .doc(email)
        .collection(userCollection)
        .snapshots();
  }

  Future<void> sendChat({
    required String senderId,
    required String receiverId,
    required ChatModal chatModal,
  }) async {
    chatModal.type = 'sender';
    await firestore
        .collection(inventoryCollection)
        .doc(senderId)
        .collection(userCollection)
        .doc(senderId)
        .collection(receiverId)
        .doc(chatModal.getId)
        .set(chatModal.toMap);

    chatModal.type = 'receiver';

    await firestore
        .collection(inventoryCollection)
        .doc(senderId)
        .collection(userCollection)
        .doc(receiverId)
        .collection(senderId)
        .doc(chatModal.getId)
        .set(chatModal.toMap);

    // DocumentSnapshot<Map<String, dynamic>> data = await firestore
    //     .collection(inventoryCollection)
    //     .doc(senderId)
    //     .collection(userCollection)
    //     .doc(receiverId)
    //     .collection("show")
    //     .doc("show")
    //     .get();
    //
    // Map<String, dynamic> myData = data.data() ?? {};
    // int isShow = myData['isShow'] ?? 0;
    //
    // await firestore
    //     .collection(inventoryCollection)
    //     .doc(senderId)
    //     .collection(userCollection)
    //     .doc(receiverId)
    //     .collection("show")
    //     .doc("show")
    //     .set({
    //   'isShow': ++isShow,
    // });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getAllChart({
    required String senderId,
    required String receiverId,
  }) {
    return firestore
        .collection(inventoryCollection)
        .doc(senderId)
        .collection(userCollection)
        .doc(senderId)
        .collection(receiverId)
        .snapshots();
  }

  Future<void> deleteChat({
    required String senderId,
    required String receiverId,
    required String date,
  }) async {
    await firestore
        .collection(inventoryCollection)
        .doc(senderId)
        .collection(userCollection)
        .doc(senderId)
        .collection(receiverId)
        .doc(date)
        .delete();

    await firestore
        .collection(inventoryCollection)
        .doc(senderId)
        .collection(userCollection)
        .doc(receiverId)
        .collection(senderId)
        .doc(date)
        .delete();
  }
}
