import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/authentication/login.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/utils/firestore_database.dart';
import 'package:twitter/utils/image_constant.dart';
import 'package:twitter/utils/time_calulate.dart';

class HomePage extends StatefulWidget {
  final UserDetails userDetails;

  const HomePage({required this.userDetails});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isSigningOut = false;
  bool _isLoading = false;
  late UserDetails _currentUser;
  List<Map<String, dynamic>?> listOfTweets = [];

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
    setState(() {
      _isLoading = true;
    });
    await FireStoreDatabase.getDetails(_currentUser.email!).then((value) => {
          value!.docs.forEach((result) {
            print(result.id);
            setState(() {
              _currentUser.id = result.id;
              _isLoading = false;
            });
            getAllPosts();
          })
        });
  }

  Future<void> getAllPosts() async {
    listOfTweets.clear();
    await FireStoreDatabase.getAllPosts().then((value) => {
          value!.docs.forEach((result) {
            print(result.data());

            setState(() {
              _isLoading = false;
              listOfTweets.add(result.data());
            });
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image(
          image: AssetImage(ImageConstants.icTwitter),
          height: 25,
          width: 25,
        ),
        leadingWidth: 45,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: CircleAvatar(
            backgroundColor: Colors.pink,
            child: Text(
              _currentUser.name![0],
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(

            onRefresh: () {

              return getAllPosts(); },
            child: ListView.builder(
                itemCount: listOfTweets.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent,
                      child: Text(
                        (listOfTweets[index]!["userDetails"]["name"][0])
                            .toString()
                            .toUpperCase(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          listOfTweets[index]!["userDetails"]["name"],
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          TimeCalculate.timeCalculateSinceDate(
                              (listOfTweets[index]!["postedAt"])
                                  .toDate()
                                  .toString()),
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          listOfTweets[index]!["tweetText"],
                          style: TextStyle(color: Colors.green, fontSize: 15),
                        ),
                      ],
                    ),
                  );
                }),
          ),
      floatingActionButton: FloatingActionButton(
        // isExtended: true,
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
        onPressed: () {
          FireStoreDatabase.addNewPost(tweetText: "Hello", details: _currentUser);
        },
      ),
    );
  }
}
