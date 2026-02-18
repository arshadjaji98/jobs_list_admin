// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/add_job.dart';
import 'package:grocery_app_admin/widgets/utils.dart';

class MyJobs extends StatefulWidget {
  const MyJobs({super.key});

  @override
  State<MyJobs> createState() => _MyJobsState();
}

class _MyJobsState extends State<MyJobs> {
  String? selectedCategory = "All Jobs"; // 👈 Default set to All Jobs
  List<String> categories = [
    'All Jobs',
    'Forces Jobs',
    'Govt Jobs',
    'Private Jobs',
    'Semi-Govt Jobs',
    'Others'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const AddJob()));
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        centerTitle: true,
        title: const Text("My Jobs",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0XFF8a4af3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: "Select Category",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon:
                    const Icon(Icons.category, color: Color(0XFF8a4af3)),
              ),
              initialValue: selectedCategory,
              isExpanded: true,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              },
              items: categories
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder(
                stream: (selectedCategory == null ||
                        selectedCategory == 'All Jobs')
                    ? FirebaseFirestore.instance
                        .collection("products")
                        .where("adminId",
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .snapshots()
                    : FirebaseFirestore.instance
                        .collection("products")
                        .where("adminId",
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .where("type", isEqualTo: selectedCategory)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No jobs found",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  var jobs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: jobs.length,
                    itemBuilder: (context, index) {
                      final job = jobs[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: job['image'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    job['image'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.work, size: 40),
                          title: Text(
                            job['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            "Last Date: ${job['price']}",
                            style: const TextStyle(fontSize: 14),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon:
                                    const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  _openEditDialog(context, job);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () {
                                  _deleteProduct(job.id);
                                },
                              ),
                            ],
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
      ),
    );
  }

  void _openEditDialog(BuildContext context, DocumentSnapshot job) {
    final TextEditingController nameController =
        TextEditingController(text: job['name']);
    final TextEditingController dateController =
        TextEditingController(text: job['price'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Job"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Job Name"),
              ),
              TextField(
                controller: dateController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: "Last Date"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("products")
                  .doc(job.id)
                  .update({
                'name': nameController.text,
                'price': dateController.text,
              }).then((value) {
                Navigator.pop(context);
                Utils.toastMessage("Job updated successfully!");
              }).catchError((error) {
                Utils.toastMessage("Failed to update job: $error");
              });
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(String jobId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Job"),
        content: const Text("Are you sure you want to delete this job?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection("products")
                  .doc(jobId)
                  .delete()
                  .then((value) {
                Navigator.pop(context);
                Utils.toastMessage("Job deleted successfully!");
              }).catchError((error) {
                Utils.toastMessage("Failed to delete job: $error");
              });
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
