import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// AuthService handles all functions associated with user authentication
// and user profile management
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Class-based storage for user information
  User? currentUser;

  // Load user details from a UserCredential into the class storage as a User
  void loadUserDetailsFromCred(UserCredential cred) {
    clearUserDetails(); // clear user details first to avoid sync issues
    currentUser = cred.user;
  }

  // Load user details from the current login into the class storage as a User
  // Returns true if successful and false on failure
  bool loadUserDetailsFromCurrent() {
    User? thisUser = FirebaseAuth.instance.currentUser;
    if (thisUser == null) {
      return false;
    } else {
      clearUserDetails(); // clear user details first to avoid sync issues
      currentUser = thisUser;
      return true;
    }
  }

  // Clear the UserCredential and User currently stored in the class
  void clearUserDetails() {
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
      loadUserDetailsFromCred(cred);

      // Save the new user's display name
      bool updateDisplayNameSuccess = await updateDisplayName(displayName);
      if (!updateDisplayNameSuccess) {
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
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );

      // Load the user's details into the class storage
      loadUserDetailsFromCred(cred);
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
    // Fall back to Firebase Auth if currentUser is not set
    return currentUser?.uid ?? _auth.currentUser?.uid;
  }

  // Get the currently logged in user's display name
  // Returns null if the user is not logged in or the data is not available
  String? getDisplayName() {
    // Fall back to Firebase Auth if currentUser is not set
    return currentUser?.displayName ?? _auth.currentUser?.displayName;
  }

  // Get the currently logged in user's email address
  // Returns null if the user is not logged in or the data is not available
  String? getEmail() {
    // Fall back to Firebase Auth if currentUser is not set
    return currentUser?.email ?? _auth.currentUser?.email;
  }

  // Get the currently logged in user's creation time as a DateTime
  // Returns null if the user is not logged in or the data is not available
  DateTime? getUserCreationTime() {
    // Fall back to Firebase Auth if currentUser is not set
    return currentUser?.metadata.creationTime ?? _auth.currentUser?.metadata.creationTime;
  }

  // Get the currently logged in user's last sign in as a DateTime
  // Returns null if the user is not logged in or the data is not available
  DateTime? getUserLastSignInTime() {
    // Fall back to Firebase Auth if currentUser is not set
    return currentUser?.metadata.lastSignInTime ?? _auth.currentUser?.metadata.lastSignInTime;
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

      // Return true on success
      return true;
    } catch (e) {
      // TODO: pass exceptions up to a snackbar
      debugPrint(e.toString());

      // Return false on failure
      return false;
    }
  }

  // Updates the display name for the currently logged in user
  // Returns a Future that resolves to true if successful and false on failure
  Future<bool> updateDisplayName(String newName) async {
    try {
      // Update the stored user's display name
      //
      // This is done instead of generating a fresh User instance like how
      // updatePassword() does it because we want to set the display name
      // in the createAccount() method before logging in for the first time
      //
      // This avoids any instance where the user is logged in while we're still
      // waiting for a display name update to sync
      await currentUser?.updateDisplayName(newName);

      // Reload the user information
      await currentUser?.reload();

      // Update the stored user information
      bool updateSuccess = loadUserDetailsFromCurrent();
      if (!updateSuccess) {
        throw Exception('Failed to update cached user information');
      }

      // Return true on success
      return true;
    } catch (e) {
      // TODO: pass exceptions up to a snackbar
      debugPrint(e.toString());

      // Return false on failure
      return false;
    }
  }
}
