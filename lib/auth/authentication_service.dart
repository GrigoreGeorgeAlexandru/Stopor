import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:stopor/database/database_service.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth) {
    authStateChanges.listen((user) {
      DatabaseService databaseService = DatabaseService();
      databaseService.initialize(user.uid);
    });
  }

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  User getUser() => _firebaseAuth.currentUser;

  Future<String> changePassword(String password) async {
    String message = "Password changed";
    await _firebaseAuth.currentUser
        .updatePassword(password)
        .catchError((error) {
      message = error.message;
    });
    return message;
  }

  Future<void> changeImage(String image) async {
    _firebaseAuth.currentUser.updatePhotoURL(image);
    FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .update({"profilePic": image});
  }

  Future<void> changeUsername(String username) async {
    await _firebaseAuth.currentUser
        .updateDisplayName(username)
        .catchError((error) {
      print(error.toString());
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .update({"name": username});
  }

  Future<void> deleteAccount() async {
    _firebaseAuth.currentUser.delete().catchError((error) {
      print(error.toString());
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(_firebaseAuth.currentUser.uid)
        .delete();
    signOut();
  }

  Future<String> facebookSignIn() async {
    try {
      final FacebookLogin facebookSignIn = new FacebookLogin();
      final FacebookLoginResult result =
          await facebookSignIn.logIn(['email', 'public_profile']);
      final facebookAuthCred =
          FacebookAuthProvider.credential(result.accessToken.token);
      await _firebaseAuth.signInWithCredential(facebookAuthCred);
      DocumentReference userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_firebaseAuth.currentUser.uid);
      var importFacebookEvents = FirebaseFunctions.instance
          .httpsCallable('importFacebookEventsInstant');
      final graphResponse = await http.get(Uri.parse(
          "https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${result.accessToken.token}"));

      final profile = jsonDecode(graphResponse.body);
      print(profile);
      importFacebookEvents({"authToken": result.accessToken.token})
          .whenComplete(() => print("gata"));
      userRef.get().then((user) {
        if (!user.exists) {
          _firebaseAuth.currentUser.updateDisplayName(profile["name"]);
          userRef.set({
            "authToken": result.accessToken.token,
            "email": profile["email"],
            "name": profile["name"],
          });
        } else {
          userRef.update({"authToken": result.accessToken.token});
        }
      });

      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<String> signIn({String email, String password}) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return "Signed in";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  Future<void> passwordReset({String email}) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<String> signUp(
      {String email, String password, String username}) async {
    try {
      await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((newUser) => {
                newUser.user.updateDisplayName(username),
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(newUser.user.uid)
                    .set({"email": email, "name": username}),
                newUser.user.sendEmailVerification()
              });
      return "Signed up";
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}
