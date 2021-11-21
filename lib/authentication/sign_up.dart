import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/home/home_page.dart';
import 'package:twitter/utils/firebase_authenication.dart';
import 'package:twitter/utils/firestore_database.dart';
import 'package:twitter/utils/image_constant.dart';
import 'package:twitter/utils/validator.dart';

class SignUpPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<SignUpPage> {
  final _registerFormKey = GlobalKey<FormState>();

  final _nameTextController = TextEditingController();
  final _emailTextController = TextEditingController();
  final _passwordTextController = TextEditingController();

  final _focusName = FocusNode();
  final _focusEmail = FocusNode();
  final _focusPassword = FocusNode();

  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusName.unfocus();
        _focusEmail.unfocus();
        _focusPassword.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Image(
            image: AssetImage(ImageConstants.icTwitter),
            height: 25,
            width: 25,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                buildTextSignUp(),
                buildFormForSignUp(),
                Row(
                  children: [
                    _isProcessing
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: () async {
                              if (_registerFormKey.currentState!.validate()) {
                                setState(() {
                                  _isProcessing = true;
                                });
                                User? user =
                                    await FireAuth.registerUsingEmailPassword(
                                  name: _nameTextController.text,
                                  email: _emailTextController.text,
                                  password: _passwordTextController.text,
                                );

                                if (user != null) {
                                  await FireStoreDatabase.insertNewUser(
                                          name: user.displayName!,
                                          email: user.email!)
                                      .then((value) => {
                                            Navigator.of(context)
                                                .pushAndRemoveUntil(
                                              MaterialPageRoute(
                                                builder: (context) => HomePage(
                                                  userDetails: UserDetails(
                                                    name: user.displayName,
                                                    email: user.email,
                                                    id: "",
                                                  ),
                                                ),
                                              ),
                                              ModalRoute.withName('/'),
                                            )
                                          });
                                }
                              }
                            },
                            child: Text(
                              'SIGN UP',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Form buildFormForSignUp() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _nameTextController,
            focusNode: _focusName,
            validator: (value) => Validator.validateName(
              name: value!,
            ),
            decoration: InputDecoration(
              hintText: "Name",
              errorBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _emailTextController,
            focusNode: _focusEmail,
            validator: (value) => Validator.validateEmail(
              email: value!,
            ),
            decoration: InputDecoration(
              hintText: "Email Address",
              errorBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.0),
          TextFormField(
            controller: _passwordTextController,
            focusNode: _focusPassword,
            obscureText: true,
            validator: (value) => Validator.validatePassword(
              password: value!,
            ),
            decoration: InputDecoration(
              hintText: "Password",
              errorBorder: UnderlineInputBorder(
                borderRadius: BorderRadius.circular(6.0),
                borderSide: BorderSide(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Text buildTextSignUp() {
    return Text(
      "Create your account",
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
    );
  }
}
