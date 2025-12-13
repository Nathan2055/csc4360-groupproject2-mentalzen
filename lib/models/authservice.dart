import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// AuthService handles all functions associated with user authentication
// and user profile management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Class-based storage for user information
  UserCredential? currentUserCredential;
  User? currentUser;

  // Load user details from a UserCredential into the class storage as a User
  void loadUserDetails(UserCredential cred) {
    clearUserDetails(); // clear user details first to avoid sync issues
    currentUserCredential = cred;
    currentUser = cred.user;
  }

  // Clear the UserCredential and User currently stored in the class
  void clearUserDetails() {
    currentUserCredential = null;
    currentUser = null;
  }

  // Creates an account and an associated profile and then logs in
  // TODO: handle usernames
  Future<void> createAccount(
    String emailAddress,
    String password,
    String username,
    String firstName,
    String lastName,
  ) async {
    try {
      // Create an account with the given email and password
      // Returns a UserCredential
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Load the new user's details into the class storage
      loadUserDetails(cred);

      // Log into the newly created user account
      await login(emailAddress, password);
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

  // Log in to the app with an email address and password
  Future<void> login(String emailAddress, String password) async {
    try {
      // Log into an account with the given email and password
      // Returns a UserCredential
      UserCredential awaitingCredential = await _auth
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      // Load the user's details into the class storage
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

  // Log out of the app
  // TODO: rewrite to be async for consistency with the other rewritten functions
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

  // TODO: update with new structure
  // Get the currently logged in user's email address
  // Returns an empty string if the user is not logged in

  // START new user info functions

  // Continue new user info getters

  // TODO: implement new setters

  String? getUserID() {
    return currentUser?.uid;
  }

  String? getDisplayName() {
    return currentUser?.displayName;
  }

  String? getEmail() {
    return currentUser?.email;
  }

  DateTime? getUserCreationTime() {
    return currentUser?.metadata.creationTime;
  }

  DateTime? getUserLastSignInTime() {
    return currentUser?.metadata.lastSignInTime;
  }
}
