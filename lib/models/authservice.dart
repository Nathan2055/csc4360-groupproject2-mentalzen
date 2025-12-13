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
  Future<void> createAccount(
    String emailAddress,
    String password,
    String displayName,
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

      // Save the new user's display name
      bool displayNameSuccess = await updateDisplayName(displayName);
      if (!displayNameSuccess) {
        throw Exception('Failed to set display name');
      }

      // Log into the newly created user account
      await login(emailAddress, password);
    } on FirebaseAuthException catch (e) {
      // TODO: pass exceptions up to a snackbar
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
      } else {
        debugPrint(e.toString());
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
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Log out of the app
  Future<void> logout() async {
    try {
      // Log out of the current user account
      await _auth.signOut();

      // Clear user details from the class storage
      clearUserDetails();
    } catch (e) {
      // TODO: pass exceptions up to a snackbar
      debugPrint(e.toString());
    }
  }

  // Get a Stream of the app's authentication state
  Stream<User?>? getStream() {
    return _auth.authStateChanges();
  }

  // Get the currently logged in user's user ID
  // Returns null if the user is not logged in or the data is not available
  String? getUserID() {
    return currentUser?.uid;
  }

  // Get the currently logged in user's display name
  // Returns null if the user is not logged in or the data is not available
  String? getDisplayName() {
    return currentUser?.displayName;
  }

  // Get the currently logged in user's email address
  // Returns null if the user is not logged in or the data is not available
  String? getEmail() {
    return currentUser?.email;
  }

  // Get the currently logged in user's creation time as a DateTime
  // Returns null if the user is not logged in or the data is not available
  DateTime? getUserCreationTime() {
    return currentUser?.metadata.creationTime;
  }

  // Get the currently logged in user's last sign in as a DateTime
  // Returns null if the user is not logged in or the data is not available
  DateTime? getUserLastSignInTime() {
    return currentUser?.metadata.lastSignInTime;
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
      // TODO: pass exceptions up to a snackbar
      debugPrint(e.toString());
      return false;
    }
  }

  // Updates the display name for the currently logged in user
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> updateDisplayName(String newName) async {
    try {
      // Get the info for the current user
      User currentUser = FirebaseAuth.instance.currentUser!;

      // Update the current user's display name
      await currentUser.updateDisplayName(newName);

      return true;
    } catch (e) {
      // TODO: pass exceptions up to a snackbar
      debugPrint(e.toString());
      return false;
    }
  }
}
