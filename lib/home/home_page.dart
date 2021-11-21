import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:twitter/authentication/user_profile.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/home/add_post.dart';
import 'package:twitter/utils/firestore_database.dart';
import 'package:twitter/utils/image_constant.dart';
import 'package:twitter/utils/common_utils.dart';

class HomePage extends StatefulWidget {
  final UserDetails userDetails;

  const HomePage({required this.userDetails});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoading = false;
  late UserDetails _currentUser;
  List<Map<String, dynamic>?> listOfTweets = [];
  List<String> tweetIds = [];

  @override
  void initState() {
    _currentUser = widget.userDetails;
    //Get user from fireStore
    if (_currentUser.id == "") {
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
    tweetIds.clear();
    await FireStoreDatabase.getAllPosts().then((value) => {
          value!.docs.forEach((result) {
            setState(() {
              _isLoading = false;
              listOfTweets.add(result.data());
              tweetIds.add(result.id);
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
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  userDetails: _currentUser,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: CircleAvatar(
              backgroundColor: Colors.pink,
              child: Text(
                _currentUser.name![0].toUpperCase(),
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: buildBottomNavigationBar(),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : buildStreamBuilder(),
      floatingActionButton: buildFABButtonToAddNewPost(context),
    );
  }

  FloatingActionButton buildFABButtonToAddNewPost(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.add),
      backgroundColor: Colors.blue,
      onPressed: () {
        Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => AddPostPage(userDetails: _currentUser),
              ),
            )
            .then((value) => {getAllPosts()});
      },
    );
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilder() {
    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('tweets').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          print(snapshot.data!.docs.length);
          if (snapshot.data!.docs.length != tweetIds.length) {
            getAllPosts();
          }
          return RefreshIndicator(
            onRefresh: () {
              return getAllPosts();
            },
            child: ListView.builder(
                itemCount: listOfTweets.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildItem(index, context);
                }),
          );
        });
  }

  Column buildItem(int index, BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueAccent,
            child: Text(
              (listOfTweets[index]!["userDetails"]["name"][0])
                  .toString()
                  .toUpperCase(),
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          title: buildTitleRow(index),
          subtitle: buildSubTitle(index),
          trailing:
              listOfTweets[index]!["userDetails"]["email"] == _currentUser.email
                  ? buildPopupMenuButton(context, index)
                  : null,
        ),
        Divider(),
      ],
    );
  }

  Column buildSubTitle(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        Text(
          listOfTweets[index]!["tweetText"],
          style: TextStyle(color: Colors.black87, fontSize: 14),
        ),
      ],
    );
  }

  Row buildTitleRow(int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          capitalize(listOfTweets[index]!["userDetails"]["name"].toString()),
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          timeCalculateSinceDate(
              (listOfTweets[index]!["postedAt"]).toDate().toString()),
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  PopupMenuButton<int> buildPopupMenuButton(BuildContext context, int index) {
    return PopupMenuButton(
      color: Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Edit",
          ),
        ),
        PopupMenuItem<int>(
          value: 0,
          child: Text(
            "Delete",
          ),
        ),
      ],
      onSelected: (item) => {
        if (item == 0)
          {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (context) => AddPostPage(
                      userDetails: _currentUser,
                      isEdit: true,
                      tweetedText: listOfTweets[index]!["tweetText"],
                      tweetID: tweetIds[index],
                    ),
                  ),
                )
                .then((value) => {getAllPosts()})
          }
        else
          {
            FireStoreDatabase.deletePost(tweetId: tweetIds[index])
                .then((value) => {getAllPosts()})
          }
      },
    );
  }

  BottomNavigationBar buildBottomNavigationBar() {
    return BottomNavigationBar(
      iconSize: 30,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.notifications_none),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.email_outlined),
          label: '',
        ),
      ],
    );
  }
}
