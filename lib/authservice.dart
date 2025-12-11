import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentalzen/models/firestore_helper.dart';
import 'package:mentalzen/models/user_entry.dart';

// AuthService handles all functions associated with user authentication
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreHelper userDatabase;

  AuthService(this.userDatabase);

  UserCredential? currentUserCredential;
  User? currentUser;

  // Creates an account and an associated profile and then logs in
  Future<void> createAccount(
    String emailAddress,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    try {
      UserEntry newUser = UserEntry(
        email: emailAddress,
        username: username,
        firstName: firstName,
        lastName: lastName,
        role: 'user',
        registeredOn: DateTime.now(),
      );

      /*
      Future<UserCredential> awaitingCredential = _auth
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      awaitingCredential.then((value) {
      
      });
      */

      /*
      UserCredential awaitingCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      */

      /*
      Future<UserCredential> awaitingCredential = _auth
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );
      awaitingCredential.then((value) {
        loadUserDetails(value);
      });
      */

      UserCredential awaitingCredential = await _auth
          .createUserWithEmailAndPassword(
            email: emailAddress,
            password: password,
          );

      loadUserDetails(awaitingCredential);

      userDatabase.addUserEntry(newUser);
    } on FirebaseAuthException catch (e) {
      // TODO: pass exceptions up to a snackbar
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void loadUserDetails(UserCredential cred) {
    currentUserCredential = cred;
    currentUser = cred.user;
  }

  void clearUserDetails() {
    currentUserCredential = null;
    currentUser = null;
  }

  // Log in to the app with an email address and password
  Future<void> login(String emailAddress, String password) async {
    try {
      /*
      _auth.signInWithEmailAndPassword(email: emailAddress, password: password);
      */

      /*
      Future<UserCredential> awaitingCredential = _auth
          .signInWithEmailAndPassword(email: emailAddress, password: password);
      awaitingCredential.then((value) {
        loadUserDetails(value);
      });
      */

      UserCredential awaitingCredential = await _auth
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      loadUserDetails(awaitingCredential);
    } on FirebaseAuthException catch (e) {
      // TODO: pass exceptions up to a snackbar
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Updates the password for the currently logged in user
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    try {
      // Get the info for the current user
      User currentUser = FirebaseAuth.instance.currentUser!;

      // Get a new AuthCredential with the old password
      AuthCredential cred = EmailAuthProvider.credential(
        email: currentUser.email!,
        password: oldPassword,
      );

      // Reauthenticate the user
      await currentUser.reauthenticateWithCredential(cred);

      // Update the password
      await currentUser.updatePassword(newPassword);

      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  // This would be where I implemented a mechanism to update email
  // addresses. However, Google has updated the Firebase library without
  // updating their documentaton, and apparently no longer allows updating
  // email addresses without also handling verification emails at the same time,
  // which is beyond the scope of this homework.
  /*
  void updateEmail(String newEmail, String password) async {
    try {
      // Get the info for the current user
      User currentUser = FirebaseAuth.instance.currentUser!;
      String oldEmail = currentUser.email!;

      // Get a new AuthCredential
      AuthCredential cred = EmailAuthProvider.credential(
        email: oldEmail,
        password: password,
      );

      // Reauthenticate the user
      await currentUser.reauthenticateWithCredential(cred);

      // Update the email address
      await currentUser.verifyBeforeUpdateEmail(newEmail);
    } catch (e) {
      print(e);
    }
  }
  */

  // Log out of the app
  void logout() {
    try {
      Future<void> awaitingLogout = _auth.signOut();
      awaitingLogout.then((value) {
        clearUserDetails();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Get a Stream of the app's authentication state
  Stream<User?>? getStream() {
    return _auth.authStateChanges();
  }

  // Get the currently logged in user's email address
  // Returns an empty string if the user is not logged in
  String getEmail() {
    if (_auth.currentUser != null) {
      for (final providerProfile in _auth.currentUser!.providerData) {
        final emailAddress = providerProfile.email!;
        return emailAddress;
      }
    }
    return '';
  }

  // START new user info functions
  void getUserInfo() {
    if (_auth.currentUser != null) {
      print('User info:');
      print(_auth.currentUser?.toString());
      print('');
      print('UID:');
      print(_auth.currentUser?.uid);
      print('Display name:');
      print(_auth.currentUser?.displayName);
      print('Email:');
      print(_auth.currentUser?.email);
      print('Email verified:');
      print(_auth.currentUser?.emailVerified.toString());
      print('Is user anonymous?:');
      print(_auth.currentUser?.isAnonymous.toString());
      print('User metadata:');
      print(_auth.currentUser?.metadata.toString());
      print('User creation time:');
      print(_auth.currentUser?.metadata.creationTime.toString());
      print('User last sign in time:');
      print(_auth.currentUser?.metadata.lastSignInTime.toString());
      print('User multifactor:');
      print(_auth.currentUser?.multiFactor.toString());
      print('User phone number:');
      print(_auth.currentUser?.phoneNumber);
      print('User photo URL:');
      print(_auth.currentUser?.photoURL);
      print('Provider data:');
      print(_auth.currentUser?.providerData.toString());
      print('Refresh token:');
      print(_auth.currentUser?.refreshToken);
      print('Tenant ID:');
      print(_auth.currentUser?.tenantId);
      print('UID:');
      print(_auth.currentUser?.uid);
      print('Hash code:');
      print(_auth.currentUser?.hashCode.toString());
      print('Runtime type:');
      print(_auth.currentUser?.runtimeType.toString());
    }
  }
}
