// ignore_for_file: use_build_context_synchronously, prefer_interpolation_to_compose_strings
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grocery_app_admin/add_job.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/my_jobs.dart';
import 'package:grocery_app_admin/announcements.dart';
import 'package:grocery_app_admin/services/services.dart';
import 'package:grocery_app_admin/widgets/order_list.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:intl/intl.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  String? storeName;
  String imgUrl = '';

  @override
  void initState() {
    super.initState();
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AdminLogIn()),
    );
  }

  final controller = Get.put(ImagePickerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Orders", style: AppWidgets.boldTextFieldStyle()),
      ),
      drawer: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Drawer(
                backgroundColor: Colors.white,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              snapshot.data!.data()!["email"],
                              style: AppWidgets.boldTextFieldStyle(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ListTile(
                      title: const Text(
                        'Add Product',
                        style: TextStyle(color: Color(0XFF8a4af3)),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddJob()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.cube_box,
                          color: Color(0XFF8a4af3)),
                      title: const Text('My Products',
                          style: TextStyle(color: Color(0XFF8a4af3))),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MyJobs()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.announcement,
                          color: Color(0XFF8a4af3)),
                      title: const Text('Announcements',
                          style: TextStyle(color: Color(0XFF8a4af3))),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const AnnouncementsScreen()));
                      },
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.arrow_right_square,
                          color: Color(0XFF8a4af3)),
                      title: const Text('Logout',
                          style: TextStyle(color: Color(0XFF8a4af3))),
                      onTap: signOut,
                    ),
                  ],
                ),
              );
            } else {
              return const Center(child: SizedBox());
            }
          },
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("users")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection("orders")
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                DateTime dateTime =
                    (snapshot.data!.docs[index]["timestamp"] as Timestamp)
                        .toDate();
                var orderDate = DateFormat('dd-MM-yyyy').format(dateTime);
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: OrderUserListWidget(
                      userId: snapshot.data!.docs[index]["userId"],
                      expendedTile: ExpansionTile(
                        leading: Text("${index + 1}"),
                        title: Text(
                          orderDate,
                          style: const TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        subtitle: Text(
                            snapshot.data!.docs[index]["paymentMethod"],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        trailing: Text(
                            "Total: ${snapshot.data!.docs[index]["totalAmount"]}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black)),
                        children: [
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              itemCount:
                                  snapshot.data!.docs[index]["items"].length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  leading: Text("${i + 1}"),
                                  title: Text(
                                      snapshot.data!.docs[index]["items"][i]
                                          ["name"],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Colors.red)),
                                  subtitle: Row(
                                    children: [
                                      Text("Rs. " +
                                          snapshot.data!.docs[index]["items"][i]
                                              ["price"]),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Text("Qty. " +
                                          snapshot.data!
                                              .docs[index]["items"][i]["count"]
                                              .toString()),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text("Product"),
                                            content: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Reject";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(snapshot.data!
                                                                .docs[index]
                                                            ["userId"])
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Reject";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ["userId"])
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: const Text("Reject"),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("users")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Accept";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(FirebaseAuth
                                                                .instance
                                                                .currentUser!
                                                                .uid)
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                    Navigator.pop(context);
                                                    FirebaseFirestore.instance
                                                        .collection("users")
                                                        .doc(snapshot.data!
                                                                .docs[index]
                                                            ["userId"])
                                                        .collection("orders")
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .get()
                                                        .then((docSnapshot) {
                                                      if (docSnapshot.exists) {
                                                        List items = docSnapshot
                                                            .data()!["items"];
                                                        items[i]["orderType"] =
                                                            "Accept";
                                                        FirebaseFirestore
                                                            .instance
                                                            .collection("users")
                                                            .doc(snapshot.data!
                                                                    .docs[index]
                                                                ["userId"])
                                                            .collection(
                                                                "orders")
                                                            .doc(snapshot.data!
                                                                .docs[index].id)
                                                            .update({
                                                          "items": items
                                                        });
                                                      }
                                                    });
                                                  },
                                                  child: const Text("Accept"),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Text(snapshot.data!.docs[index]
                                        ["items"][i]["orderType"]),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      phoneNumber: snapshot.data!.docs[index]["phoneNumber"],
                      address: snapshot.data!.docs[index]["currentAddress"],
                      fullName: snapshot.data!.docs[index]
                              .data()
                              .containsKey("fullname")
                          ? snapshot.data!.docs[index]["fullname"]
                          : "N/A",
                      city:
                          snapshot.data!.docs[index].data().containsKey("city")
                              ? snapshot.data!.docs[index]["city"]
                              : "N/A",
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
