import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:grocery_app_admin/add_job.dart';
import 'package:grocery_app_admin/admin_login.dart';
import 'package:grocery_app_admin/responsive/web_responsive.dart';
import 'package:grocery_app_admin/widgets/text_style.dart';
import 'package:grocery_app_admin/widgets/utils.dart';

class AdminSignUp extends StatefulWidget {
  final void Function()? onTap;
  const AdminSignUp({super.key, this.onTap});

  @override
  State<AdminSignUp> createState() => _AdminSignUpState();
}

class _AdminSignUpState extends State<AdminSignUp> {
  bool _isLoading = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController addressController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  // Default role is "admin"
  final String selectType = "admin";

  registration() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      )
          .then((value) {
        Map<String, dynamic> addUserInfo = {
          "name": nameController.text.trim(),
          "email": value.user!.email.toString(),
          "wallet": "0",
          "phone": phoneController.text,
          "address": addressController.text,
          "id": value.user!.uid,
          "favourite": [],
          "profile_image": "",
          "user_role": selectType, // Always "admin"
          "date": DateTime.now(),
          "verify": false, // Admin accounts require verification
        };
        FirebaseFirestore.instance
            .collection("users")
            .doc(value.user!.uid)
            .set(addUserInfo);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AddJob()));
        Utils.toastMessage("Registered Successfully");
      }).onError((e, s) {
        Utils.toastMessage(e.toString());
      });
    } on FirebaseAuthException catch (e) {
      Utils.toastMessage(e.toString());
    } catch (e) {
      Utils.toastMessage(e.toString());
    } finally {
      setState(() {
        _isLoading = false; // End loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 2,
            decoration: const BoxDecoration(
              color: Color(0XFF8a4af3),
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: MediaQuery.of(context).size.height / 3),
            height: double.infinity,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: WebResponsive(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Material(
                              elevation: 5.0,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 20.0, right: 20.0),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Form(
                                  key: _formkey,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(height: 20.0),
                                      Text(
                                        "Create account for Admin",
                                        style:
                                            AppWidgets.headerTextFieldStyle(),
                                      ),
                                      const SizedBox(height: 30.0),
                                      TextFormField(
                                        controller: nameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Name';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Name',
                                          hintStyle: AppWidgets
                                              .semiBoldTextFieldStyle(),
                                          prefixIcon:
                                              const Icon(Icons.person_outlined),
                                        ),
                                      ),
                                      const SizedBox(height: 30.0),
                                      TextFormField(
                                        controller: emailController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter E-mail';
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                            hintText: 'Email',
                                            hintStyle: AppWidgets
                                                .semiBoldTextFieldStyle(),
                                            prefixIcon: const Icon(
                                                Icons.email_outlined)),
                                      ),
                                      const SizedBox(height: 30.0),
                                      TextFormField(
                                        controller: passwordController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please Enter Password';
                                          }
                                          return null;
                                        },
                                        obscureText: true,
                                        decoration: InputDecoration(
                                            hintText: 'Password',
                                            hintStyle: AppWidgets
                                                .semiBoldTextFieldStyle(),
                                            prefixIcon: const Icon(
                                                Icons.password_outlined)),
                                      ),
                                      const SizedBox(height: 50.0),
                                      GestureDetector(
                                        onTap: () async {
                                          if (_formkey.currentState!
                                              .validate()) {
                                            setState(() {});
                                            await registration();
                                          }
                                        },
                                        child: Material(
                                          elevation: 5.0,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            width: 200,
                                            decoration: BoxDecoration(
                                              color: const Color(0XFF8a4af3),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: _isLoading
                                                ? const Center(
                                                    child: SpinKitWave(
                                                        size: 20,
                                                        color: Colors.white))
                                                : const Center(
                                                    child: Text(
                                                      "CREATE",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18.0,
                                                        fontFamily: 'Poppins1',
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10.0),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Already have an account? ",
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14,
                                            ),
                                          ),
                                          TextButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const AdminLogIn()));
                                              },
                                              child: const Text("Login",
                                                  style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 18,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontWeight:
                                                          FontWeight.bold))),
                                        ],
                                      ),
                                      const SizedBox(height: 10.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
