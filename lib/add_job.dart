import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/my_jobs.dart';
import 'package:grocery_app_admin/announcements.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AddJob extends StatefulWidget {
  const AddJob({super.key});

  @override
  State<AddJob> createState() => _AddJobState();
}

class _AddJobState extends State<AddJob> {
  final List<String> fooditems = [
    'Forces Jobs',
    'Govt Jobs',
    'Private Jobs',
    'Semi-Govt Jobs',
    'Others'
  ];
  String? value;
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController(); // Last Date
  TextEditingController detailController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController locationController = TextEditingController(); // NEW
  TextEditingController vacanciesController = TextEditingController(); // NEW
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    selectedImage = File(image!.path);
    setState(() {});
  }

  bool isLoading = false;

  Future<void> uploadItem() async {
    if (selectedImage == null ||
        nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        detailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(
          "Please fill in all fields and select an image",
          style: TextStyle(fontSize: 16.0),
        ),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String addId = randomAlphaNumeric(10);
      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImages/$addId");

      UploadTask task = firebaseStorageRef.putFile(selectedImage!);
      String downloadUrl = await (await task).ref.getDownloadURL();

      DocumentReference productRef =
          FirebaseFirestore.instance.collection("products").doc();

      Map<String, dynamic> addItem = {
        "id": productRef.id,
        "image": downloadUrl,
        "name": nameController.text.trim(),
        "price": priceController.text.trim(),
        "quantity": quantityController.text.trim(),
        "detail": detailController.text.trim(),
        "location": locationController.text.trim(),
        "vacancies": vacanciesController.text.trim(),
        "timestamp": FieldValue.serverTimestamp(),
        "adminId": FirebaseAuth.instance.currentUser!.uid,
        "type": value,
        "favourite": [],
      };

      await productRef.set(addItem);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Food item has been added successfully!",
          style: TextStyle(fontSize: 16.0),
        ),
      ));

      nameController.clear();
      priceController.clear();
      detailController.clear();
      quantityController.clear();
      locationController.clear();
      vacanciesController.clear();

      selectedImage = null;
      value = null;

      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error: ${e.toString()}",
          style: const TextStyle(fontSize: 16.0),
        ),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0XFF8a4af3),
        centerTitle: true,
        title: const Text(
          "Add Job",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: SafeArea(
          child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0XFF8a4af3),
              ),
              child: Center(
                child: Text(
                  "Job Portal",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Top items
            ListTile(
              leading: const Icon(Icons.add_box, color: Color(0XFF8a4af3)),
              title: Text(
                'Add a Job',
                style: AppWidgets.boldTextFieldStyle(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddJob()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.work_outline, color: Color(0XFF8a4af3)),
              title: Text(
                'My Jobs',
                style: AppWidgets.boldTextFieldStyle(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyJobs()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.announcement, color: Color(0XFF8a4af3)),
              title: Text(
                'Announcements',
                style: AppWidgets.boldTextFieldStyle(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AnnouncementsScreen()),
                );
              },
            ),

            // This pushes the logout to the bottom
            Expanded(child: Container()),

            ListTile(
              leading: const Icon(Icons.logout, color: Color(0XFF8a4af3)),
              title: Text(
                'Log Out',
                style: AppWidgets.boldTextFieldStyle(),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminLogIn()),
                );
              },
            ),
          ],
        ),
      )),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.only(
              left: 20.0, right: 20.0, top: 20.0, bottom: 50.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Upload the Job Picture",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(
                height: 20.0,
              ),
              selectedImage == null
                  ? GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.camera_alt_outlined,
                                color: Colors.black),
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        getImage();
                      },
                      child: Center(
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 1.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 30.0),
              Text("Job Name", style: AppWidgets.semiBoldTextFieldStyle()),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Job Name",
                      hintStyle: AppWidgets.lightTextFieldStyle()),
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                "Last Date:",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: priceController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Last Date",
                    hintStyle: AppWidgets.lightTextFieldStyle(),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              Text(
                "Job Description",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: const Color(0xFFececf8),
                    borderRadius: BorderRadius.circular(10)),
                child: TextField(
                  maxLines: 6,
                  controller: detailController,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Job Details",
                      hintStyle: AppWidgets.semiBoldTextFieldStyle()),
                ),
              ),
              const SizedBox(height: 30),
              Text("Job Location", style: AppWidgets.semiBoldTextFieldStyle()),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                    controller: locationController,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Job Location",
                        hintStyle: AppWidgets.lightTextFieldStyle())),
              ),
              const SizedBox(height: 30.0),
              Text(
                "Vacancies",
                style: AppWidgets.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 10.0),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: vacanciesController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Number of Vacancies",
                    hintStyle: AppWidgets.lightTextFieldStyle(),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Text("Select Category",
                  style: AppWidgets.semiBoldTextFieldStyle()),
              const SizedBox(height: 10.0),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: const Color(0xFFececf8),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                          items: fooditems
                              .map((item) => DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: const TextStyle(
                                        fontSize: 18.0, color: Colors.black),
                                  )))
                              .toList(),
                          onChanged: ((value) => setState(() {
                                this.value = value;
                              })),
                          dropdownColor: Colors.white,
                          hint: const Text("Select Category"),
                          iconSize: 36,
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.black),
                          value: value))),
              const SizedBox(height: 30.0),
              GestureDetector(
                onTap: isLoading ? null : uploadItem,
                child: Center(
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      width: 150,
                      decoration: BoxDecoration(
                        color: Color(0XFF8a4af3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text("Add",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
