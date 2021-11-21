import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:twitter/data/user_details.dart';
import 'package:twitter/utils/firestore_database.dart';

class AddPostPage extends StatefulWidget {
  final UserDetails userDetails;
  final bool isEdit;
  final String tweetedText;
  final String tweetID;

  const AddPostPage(
      {required this.userDetails,
      this.isEdit: false,
      this.tweetedText: "",
      this.tweetID: ""});

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final _postTextController = TextEditingController();

  late UserDetails _currentUser;
  bool isTweetButtonEnabled = false;

  @override
  void initState() {
    _currentUser = widget.userDetails;
    if (widget.isEdit) {
      _postTextController.text = widget.tweetedText;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.clear,
              color: Colors.black,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: buildPostButton(context),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              buildTextFieldView(),
            ],
          ),
        ));
  }

  Row buildTextFieldView() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: Colors.pink,
          child: Text(
            _currentUser.name![0].toUpperCase(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        Expanded(
          child: TextFormField(
            controller: _postTextController,
            maxLength: 280,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "What's Happening",
              hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            onChanged: (v) {
              setState(() {
                if (_postTextController.text.isNotEmpty) {
                  isTweetButtonEnabled = true;
                } else {
                  isTweetButtonEnabled = false;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  ElevatedButton buildPostButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (widget.isEdit) {
          FireStoreDatabase.editPost(
                  tweetText: _postTextController.text.trim(),
                  tweetId: widget.tweetID)
              .then((value) => {Navigator.pop(context)});
        } else {
          FireStoreDatabase.addNewPost(
                  tweetText: _postTextController.text.trim(),
                  details: _currentUser)
              .then((value) => {Navigator.pop(context)});
        }
      },
      child: Text(
        widget.isEdit ? "Update" : 'Post',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ButtonStyle(
        backgroundColor: isTweetButtonEnabled
            ? MaterialStateProperty.all(Colors.blue)
            : MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
      ),
    );
  }
}
