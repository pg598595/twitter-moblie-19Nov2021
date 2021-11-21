import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/utils/common_utils.dart';
import 'package:twitter/utils/firestore_database.dart';

import 'login.dart';

class UserProfilePage extends StatefulWidget {
  final UserDetails userDetails;

  const UserProfilePage({required this.userDetails});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isSigningOut = false;

  late UserDetails _currentUser;

  @override
  void initState() {
    _currentUser = widget.userDetails;

    super.initState();
  }

  Future<void> getId() async {
    await FireStoreDatabase.getDetails(_currentUser.email!).then((value) => {
          value!.docs.forEach((result) {
            print(result.id);
            setState(() {
              _currentUser.id = result.id;
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(25, 250, 25, 250),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.pink,
                child: Text(
                  _currentUser.name![0].toString().toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Text(
                'Name: ${capitalize(_currentUser.name!)}',
              ),
              SizedBox(height: 16.0),
              Text(
                'Email Id: ${_currentUser.email}',
              ),
              SizedBox(height: 16.0),
              _isSigningOut
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _isSigningOut = true;
                        });
                        await FirebaseAuth.instance.signOut();
                        setState(() {
                          _isSigningOut = false;
                        });
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      child: Text('Sign out',style: TextStyle(fontSize: 20),),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.red,

                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
