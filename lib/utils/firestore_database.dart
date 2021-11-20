import 'package:cloud_firestore/cloud_firestore.dart';

import 'data_constants.dart';

class FireStoreDatabase {
  //store new users data
  static Future<DocumentReference?> insertNewUser({
    required String name,
    required String email,
  }) async {
    final firestoreInstance = FirebaseFirestore.instance;
    return firestoreInstance.collection(users).add({
      "name": name,
      "email": email,
    });
  }

  static Future<DocumentReference?> addNewPost({
    required String? tweetText,
    required String? userId,
  }) async {
    final firestoreInstance = FirebaseFirestore.instance;
    firestoreInstance.collection(users).doc(userId).collection(tweets).add({
      "tweetText": tweetText,
    }).then((value) => {print(value)});
  }
}
