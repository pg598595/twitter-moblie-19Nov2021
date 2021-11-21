import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:twitter/data/user_details.dart';

import 'data_constants.dart';

class FireStoreDatabase {
  //store new users data
  static Future<DocumentReference?> insertNewUser({
    required String name,
    required String email,
  }) async {
    final fireStoreInstance = FirebaseFirestore.instance;
    return fireStoreInstance.collection(users).add({
      "name": name,
      "email": email,
    });
  }

  //add new post of user
  static Future<DocumentReference?> addNewPost({
    required String? tweetText,
    required UserDetails? details,
  }) async {
    final fireStoreInstance = FirebaseFirestore.instance;
    fireStoreInstance.collection(tweets).add({
      "tweetText": tweetText,
      "userDetails": {
        "name":details!.name,
        "email":details.email,

      },
      "postedAt":DateTime.now(),
    }).then((value) => {print(value)});
  }

  //get details from user email id
  static Future<QuerySnapshot?> getDetails(String email) async {
    final fireStoreInstance = FirebaseFirestore.instance;
    return fireStoreInstance
        .collection("users")
        .where("email", isEqualTo: email)
        .get();
  }

  //get all post from database
  static Future<QuerySnapshot?> getAllPosts() async {
    final fireStoreInstance = FirebaseFirestore.instance;
    return fireStoreInstance
        .collection(tweets)
        .get();
  }


}
