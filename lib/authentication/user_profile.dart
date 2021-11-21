import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/utils/firestore_database.dart';

import 'login.dart';

class UserProfilePage extends StatefulWidget {
  final UserDetails userDetails;

  const UserProfilePage({required this.userDetails});

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  bool _isSendingVerification = false;
  bool _isSigningOut = false;

  late UserDetails _currentUser;

  @override
  void initState() {
    _currentUser = widget.userDetails;
    if (_currentUser.id == "") {
      print("Checking id");
      getId();
    }
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
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'NAME: ${_currentUser.name}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            SizedBox(height: 16.0),
            Text(
              'EMAIL: ${_currentUser.email}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            Text(
              _currentUser.id ?? "",
              style: Theme.of(context)
                  .textTheme
                  .bodyText1!
                  .copyWith(color: Colors.green),
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
                    child: Text('Sign out'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
