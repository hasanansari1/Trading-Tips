import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginPage.dart';


class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final formKey = GlobalKey<FormState>();
  var password = false, conPassword = true;
  bool passwordVisible = false;
  bool conPasswordVisible = true;
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  bool isLoading = false;
  String uniquefilename = DateTime.now().millisecondsSinceEpoch.toString();

  Future<bool>doesRegisterExist(String email) async{

    final querySnapshot = await FirebaseFirestore.instance
        .collection("User")
        .where("email", isEqualTo: email)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKey,
          child: Container(
            margin: const EdgeInsets.only(top: 100, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to Equity Star",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                ),
                const Text(
                  "Let's Register in Equity Star",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your name";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: "Enter your username",
                        label: const Text("Username"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.account_box_rounded)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      } else if (!value.contains("@") || !value.contains(".")) {
                        return "Please enter valid email";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                        hintText: "Enter your email",
                        label: const Text("Email"),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.email_outlined)),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    controller: passController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter Password";
                      }
                      return null;
                    },
                    obscureText: !passwordVisible,
                    decoration: InputDecoration(
                      hintText: "Enter your password",
                      label: const Text("Password"),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                    ),
                  ),
                ),

                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: TextFormField(
                    controller: mobileController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter Mobile Number";
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Please Enter Your Mobile No.",
                      label: const Text("Mobile No."),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                  ),
                ),

                Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    height: 60,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await FirebaseAuth.instance
                                .createUserWithEmailAndPassword(
                              email: emailController.text, password: passController.text,)
                                .then((value) {
                              FirebaseFirestore.instance.collection(
                                  "User").doc(value.user!.uid).set(

                                  {
                                    "Name": nameController.text,
                                    "Email": emailController.text,
                                    "Password": passController.text,
                                    "Mobile": mobileController.text,
                                    "UID": FirebaseAuth.instance.currentUser!.uid,
                                    "DocumentID": value.user!.uid,
                                  });
                            });
                            setState(() {
                              nameController.clear();
                              emailController.clear();
                              passController.clear();
                              mobileController.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar
                              (const SnackBar(
                                content: Text("Register Successfull")));
                          }
                          on FirebaseAuthException catch (e) {
                            if (e.code == 'weak-password') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Password is too weak"),
                                  ));
                            }
                            else if (e.code == 'email-already-in-use') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        "Email is already Registered"),
                                  ));
                            }
                          }
                        }
                        // Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(70),
                        ),
                      ),
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.black),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have Account ?"),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
                      },
                      child: const Text("Login!", style: TextStyle(color: Colors.lightGreen)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
