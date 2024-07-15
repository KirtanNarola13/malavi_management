import 'dart:developer';
import 'dart:io';

import 'package:app_code/modules/utils/controllers/add_user_controller.dart';
import 'package:app_code/modules/utils/globals/routes.dart';
import 'package:app_code/modules/utils/helpers/fcm_helper.dart';
import 'package:app_code/modules/utils/helpers/firebase_auth_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AddUserPageComponet extends StatelessWidget {
  AddUserPageComponet({super.key});
  GlobalKey<FormState> addUserKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController departmentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    TextScaler textScaler = MediaQuery.textScalerOf(context);
    Size size = MediaQuery.of(context).size;
    double h = size.height;
    double w = size.width;
    return StreamBuilder(
      stream: FCMHelper.fcmHelper.getAdminData(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text("${snapshot.error}"),
          );
        } else if (snapshot.hasData) {
          DocumentSnapshot<Map<String, dynamic>>? data = snapshot.data;
          Map<String, dynamic> userData = data!.data() ?? {};

          return Consumer<AddUserController>(
            builder: (context, provider, child) {
              return Padding(
                padding: EdgeInsets.only(top: h * 0.02),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: h * 0.25,
                          width: w,
                          color: Colors.white,
                        ),
                        Container(
                          height: h * 0.2,
                          width: w,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            image: DecorationImage(
                              image: (provider.addUserModel.bgImage != null)
                                  ? FileImage(
                                      provider.addUserModel.bgImage as File)
                                  : const NetworkImage(
                                      "https://picsum.photos/200/300",
                                    ) as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                          padding: EdgeInsets.all(h * 0.015),
                          alignment: Alignment.topRight,
                          child: IconButton.filled(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: h * 0.25,
                                    width: w,
                                    padding: EdgeInsets.only(left: w * 0.05),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: h * 0.01,
                                          width: w * 0.15,
                                          margin:
                                              EdgeInsets.only(top: h * 0.025),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            borderRadius:
                                                BorderRadius.circular(w * 0.05),
                                          ),
                                        ),
                                        const Spacer(),
                                        ListTile(
                                          leading: const Icon(Icons.camera_alt),
                                          onTap: () {
                                            provider.pickBgImage(
                                              image: ImageSource.camera,
                                            );
                                            Navigator.pop(context);
                                          },
                                          title: const Text(
                                            "View or edit profile photo",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.photo_size_select_actual,
                                          ),
                                          onTap: () {
                                            provider.pickBgImage(
                                              image: ImageSource.gallery,
                                            );
                                            Navigator.pop(context);
                                          },
                                          title: const Text(
                                            "Add frame",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.white,
                              ),
                            ),
                            icon: const Icon(Icons.edit),
                            color: Colors.blueAccent,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: w * 0.035,
                            top: h * 0.1,
                          ),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: w * 0.17,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: w * 0.16,
                                  backgroundImage:
                                      (provider.addUserModel.profileImage !=
                                              null)
                                          ? FileImage(provider.addUserModel
                                              .profileImage as File)
                                          : const NetworkImage(
                                              "https://picsum.photos/200",
                                            ) as ImageProvider,
                                ),
                              ),
                              CircleAvatar(
                                radius: w * 0.06,
                                backgroundColor: Colors.white,
                                child: Transform.scale(
                                  scale: 0.9,
                                  child: FloatingActionButton.small(
                                    backgroundColor: Colors.blue.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(w * 0.1),
                                    ),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            height: h * 0.25,
                                            width: w,
                                            padding:
                                                EdgeInsets.only(left: w * 0.05),
                                            child: Column(
                                              children: [
                                                Container(
                                                  height: h * 0.01,
                                                  width: w * 0.15,
                                                  margin: EdgeInsets.only(
                                                      top: h * 0.025),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            w * 0.05),
                                                  ),
                                                ),
                                                const Spacer(),
                                                ListTile(
                                                  leading: const Icon(
                                                      Icons.camera_alt),
                                                  onTap: () {
                                                    provider.pickProfileImage(
                                                      image: ImageSource.camera,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  title: const Text(
                                                    "View or edit profile photo",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                ListTile(
                                                  leading: const Icon(
                                                    Icons
                                                        .photo_size_select_actual,
                                                  ),
                                                  onTap: () {
                                                    provider.pickProfileImage(
                                                      image:
                                                          ImageSource.gallery,
                                                    );
                                                    Navigator.pop(context);
                                                  },
                                                  title: const Text(
                                                    "Add frame",
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Icon(
                                      Icons.add,
                                      size: h * 0.035,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(w * 0.65, h * 0.20),
                          child: OutlinedButton(
                            onPressed: () {
                              if (addUserKey.currentState!.validate()) {
                                addUserKey.currentState!.save();
                                String email = userData['Email Id'];
                                String password = userData['Password'];
                                FCMHelper.fcmHelper
                                    .addUserData(
                                  profileImage:
                                      provider.addUserModel.profileImage ??
                                          "https://picsum.photos/200",
                                  bgImage: provider.addUserModel.bgImage ??
                                      "https://picsum.photos/200/300",
                                  fullName: provider.addUserModel.fullName,
                                  userName: provider.addUserModel.userName,
                                  bio: provider.addUserModel.bio,
                                  userEmail: provider.addUserModel.email,
                                  password: provider.addUserModel.password,
                                  phoneNumber:
                                      provider.addUserModel.phoneNumber,
                                  dob: provider.addUserModel.dobController.text,
                                  gender: provider.addUserModel.gender,
                                  department:
                                      provider.addUserModel.department ?? "",
                                  companyName: userData['Company Name'],
                                  location: userData['Business Location'],
                                )
                                    .then((value) async {
                                  Map<String, dynamic> res =
                                      await FireBaseAuthHelper.firebaseAuth
                                          .signUpWithEmailAddress(
                                    email: provider.addUserModel.email,
                                    password: provider.addUserModel.password,
                                  );
                                  if (res['error'] != null) {
                                    SnackBar snackBar = SnackBar(
                                      content: Text("ERROR : ${res['error']}"),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(12),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }

                                  if (res['user'] != null) {
                                    SnackBar snackBar = SnackBar(
                                      content: Text(
                                          "${provider.addUserModel.fullName} Added Successfully"),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(12),
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);

                                    await FireBaseAuthHelper.firebaseAuth
                                        .signInWithEmailAddress(
                                            email: email, password: password);

                                    log("CURRENT USER : ${FireBaseAuthHelper.firebaseAuth.firebase.currentUser!.email}");

                                    nameController.clear();
                                    userNameController.clear();
                                    emailController.clear();
                                    passwordController.clear();
                                    phoneNumberController.clear();
                                    provider.addUserModel.dobController.clear();
                                    provider.addUserModel.gender = "";
                                    bioController.clear();
                                    departmentController.clear();
                                    provider.assignNullValue();
                                  }
                                });
                              }
                            },
                            child: const Text("CREATE"),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      flex: 3,
                      child: Form(
                        key: addUserKey,
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: h * 0.025, right: h * 0.025),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: h * 0.065,
                                  child: TextFormField(
                                    // initialValue: profilePageModel.fullName,
                                    controller: nameController,
                                    validator: (val) =>
                                        (val!.isEmpty) ? "Enter name" : null,
                                    onSaved: (val) {
                                      provider.addUserModel.fullName =
                                          val ?? "";
                                    },
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: Text("Name"),
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.065,
                                  child: TextFormField(
                                    controller: userNameController,
                                    // initialValue: profilePageModel.userName,
                                    textInputAction: TextInputAction.next,
                                    validator: (val) => (val!.isEmpty)
                                        ? "Enter user name"
                                        : null,
                                    onSaved: (val) {
                                      provider.addUserModel.userName =
                                          val ?? "";
                                    },
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: Text("Username"),
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.065,
                                  child: TextFormField(
                                    controller: emailController,
                                    // initialValue: profilePageModel.userName,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (val) =>
                                        (val!.isEmpty) ? "Enter email" : null,
                                    onSaved: (val) {
                                      provider.addUserModel.email = val ?? "";
                                    },
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: Text("Email"),
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.065,
                                  child: TextFormField(
                                    controller: passwordController,
                                    obscureText:
                                        provider.addUserModel.isPasswordVisible,
                                    // initialValue: profilePageModel.bio,
                                    validator: (val) => (val!.isEmpty)
                                        ? "Enter password"
                                        : null,
                                    onSaved: (val) {
                                      provider.addUserModel.password =
                                          val ?? "";
                                    },
                                    textInputAction: TextInputAction.next,

                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          provider.changeVisibilityPassword();
                                        },
                                        icon: (provider
                                                .addUserModel.isPasswordVisible)
                                            ? const Icon(Icons.visibility_off)
                                            : const Icon(Icons.visibility),
                                      ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: const Text("Password"),
                                      labelStyle: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.07,
                                  child: DropdownButton(
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    value: provider.addUserModel.department,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    hint: const Text("Department"),
                                    isExpanded: true,
                                    items: departmentList
                                        .map(
                                          (e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      provider.storeDepartment(
                                          department: value! as String);
                                    },
                                  ),
                                ),
                                // Padding(
                                //   padding: EdgeInsets.only(top: h * 0.005),
                                //   child: TextFormField(
                                //     controller: departmentController,
                                //     // initialValue: profilePageModel.bio,
                                //     validator: (val) => (val!.isEmpty)
                                //         ? "Enter department"
                                //         : null,
                                //     onSaved: (val) {
                                //       provider.addUserModel.department =
                                //           val ?? "";
                                //     },
                                //     textInputAction: TextInputAction.next,
                                //     decoration: const InputDecoration(
                                //       enabledBorder: UnderlineInputBorder(
                                //         borderSide: BorderSide(
                                //           color: Colors.grey,
                                //         ),
                                //       ),
                                //       label: Text("Department"),
                                //       labelStyle: TextStyle(
                                //         color: Colors.grey,
                                //       ),
                                //       focusedBorder: UnderlineInputBorder(
                                //         borderSide: BorderSide(
                                //           color: Colors.blue,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                                SizedBox(
                                  height: h * 0.065,
                                  child: TextFormField(
                                    controller: bioController,
                                    // initialValue: profilePageModel.bio,
                                    validator: (val) =>
                                        (val!.isEmpty) ? "Enter bio" : null,
                                    onSaved: (val) {
                                      provider.addUserModel.bio = val ?? "";
                                    },
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: Text("Bio"),
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.09,
                                  child: TextFormField(
                                    controller: phoneNumberController,
                                    // initialValue: profilePageModel.phoneNumber,
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.number,
                                    maxLength: 10,
                                    validator: (val) => (val!.isEmpty)
                                        ? "Enter name"
                                        : (val.length < 10)
                                            ? "Enter valid number"
                                            : null,
                                    onSaved: (val) {
                                      provider.addUserModel.phoneNumber =
                                          val ?? "";
                                    },
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      label: Text("Phone Number"),
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.blue,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: h * 0.065,
                                  child: GestureDetector(
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );

                                      if (pickedDate != null) {
                                        String formattedDate =
                                            DateFormat('MM-dd-yyyy')
                                                .format(pickedDate);

                                        provider.getDateOfBirthDay(
                                            date: formattedDate);
                                      }
                                    },
                                    child: TextFormField(
                                      controller:
                                          provider.addUserModel.dobController,
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      cursorColor: const Color(0xff6AABDA),
                                      validator: (val) => (val!.isEmpty)
                                          ? "Enter Date..."
                                          : null,
                                      decoration: const InputDecoration(
                                        label: Text("Birth Date"),
                                        labelStyle: TextStyle(
                                          color: Colors.grey,
                                        ),
                                        enabled: false,
                                        disabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Gender",
                                      style: TextStyle(
                                        fontSize: textScaler.scale(18),
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Radio(
                                      value: "Male",
                                      groupValue: provider.addUserModel.gender,
                                      onChanged: (val) {
                                        provider.getGenderValue(
                                            gender: val ?? "");
                                      },
                                    ),
                                    Text(
                                      "Male",
                                      style: TextStyle(
                                        fontSize: textScaler.scale(15),
                                      ),
                                    ),
                                    Radio(
                                      value: "Female",
                                      groupValue: provider.addUserModel.gender,
                                      onChanged: (val) {
                                        provider.getGenderValue(
                                            gender: val ?? "");
                                      },
                                    ),
                                    Text(
                                      "Female",
                                      style: TextStyle(
                                        fontSize: textScaler.scale(15),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
