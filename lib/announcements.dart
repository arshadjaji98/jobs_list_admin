// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:random_string/random_string.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;
  bool isLoading = false;

  Future getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    selectedImage = File(image.path);
    setState(() {});
  }

  Future<void> uploadAnnouncement() async {
    if (titleController.text.trim().isEmpty &&
        bodyController.text.trim().isEmpty &&
        selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text("Please provide a title, body or image for announcement"),
      ));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String? downloadUrl;
      if (selectedImage != null) {
        String addId = randomAlphaNumeric(10);
        Reference ref =
            FirebaseStorage.instance.ref().child('announcements/$addId');
        UploadTask task = ref.putFile(selectedImage!);
        downloadUrl = await (await task).ref.getDownloadURL();
      }

      DocumentReference docRef =
          FirebaseFirestore.instance.collection('announcements').doc();

      Map<String, dynamic> announcement = {
        'id': docRef.id,
        'title': titleController.text.trim(),
        'body': bodyController.text.trim(),
        'image': downloadUrl ?? '',
        'adminId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      };

      await docRef.set(announcement);

      // Send FCM Notification
      await sendNotificationToAll(
        titleController.text.trim(),
        bodyController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.green,
        content: Text('Announcement posted & notification sent'),
      ));

      titleController.clear();
      bodyController.clear();
      selectedImage = null;
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text('Error: ${e.toString()}'),
      ));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

// Function to send notification to all users subscribed to "all" topic
  Future<void> sendNotificationToAll(String title, String body) async {
    const serverKey =
        'AAAApADv0BQ:APA91bH2SWI7WDqWsiI2QjVa73ia3JMh8-SSYt_sySeFXHXkQ5mIJoyO76wOnmmaddilnXUyJ_vONiNN2Xpc4C6dg0IYhWZBLoa_CJ1wDmigzp83TpcQTXJJKll7rZNYkrGPmyEp4h6p';
    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        "to": "/topics/all", // send to all users
        "notification": {
          "title": title.isEmpty ? 'New Announcement' : title,
          "body": body.isEmpty ? 'Check the app for details' : body,
        },
        "priority": "high",
      }),
    );

    print('FCM Response: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: const Text('Announcements'),
        backgroundColor: const Color(0XFF8a4af3),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Announcement',
                style: AppWidgets.semiBoldTextFieldStyle()),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                filled: true,
                fillColor: Color(0xFFececf8),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Body',
                filled: true,
                fillColor: Color(0xFFececf8),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                selectedImage == null
                    ? GestureDetector(
                        onTap: getImage,
                        child: Container(
                          width: 120,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFececf8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(child: Icon(Icons.image)),
                        ),
                      )
                    : GestureDetector(
                        onTap: getImage,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(selectedImage!,
                              width: 120, height: 80, fit: BoxFit.cover),
                        ),
                      ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : uploadAnnouncement,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0XFF8a4af3)),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text(
                            'Post Announcement',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Recent Announcements',
                style: AppWidgets.semiBoldTextFieldStyle()),
            const SizedBox(height: 12),
            SizedBox(
              height: 400,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('announcements')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No announcements yet'));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var doc = snapshot.data!.docs[index];
                        String title = doc['title'] ?? '';
                        String body = doc['body'] ?? '';
                        String image = doc['image'] ?? '';
                        Timestamp? ts = doc['timestamp'];
                        String date = ts != null
                            ? DateTime.fromMillisecondsSinceEpoch(
                                    ts.seconds * 1000)
                                .toString()
                            : '';
                        return Card(
                          child: ListTile(
                            leading: image.isNotEmpty
                                ? Image.network(image,
                                    width: 56, fit: BoxFit.cover)
                                : null,
                            title: Text(title.isEmpty ? '(No title)' : title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Actions'),
                                      content: const Text(
                                          "Do you want to delete this announcement?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('announcements')
                                                .doc(doc.id)
                                                .delete();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(body,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(date,
                                    style: const TextStyle(
                                        fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
