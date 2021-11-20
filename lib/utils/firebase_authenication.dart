import 'package:firebase_auth/firebase_auth.dart';
import 'package:twitter/utils/display_toast.dart';

class FireAuth {
  // For registering a new user on app
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      user = userCredential.user;
      await user!.updateProfile(displayName: name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        DisplayToast.displayToast("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        DisplayToast.displayToast("The account already exists for this email.");
      }
    } catch (e) {
      print(e);
    }

    return user;
  }

  // For signing in an user (have already registered) in the app
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        DisplayToast.displayToast("No user found for this email.");
      } else if (e.code == 'wrong-password') {
        DisplayToast.displayToast("Wrong password");
      }
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
