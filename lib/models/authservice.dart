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
  void getUserInfoOld() {
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

  // START new user info functions
  void getUserInfoNew() {
    if (_auth.currentUser != null) {
      print('User info:');
      print(getAllUserInfo());
      print('');
      print('UID:');
      print(getUserID());
      print('Display name:');
      print(getDisplayName());
      print('Email:');
      print(getEmailNew());
      print('Email verified:');
      print(isEmailVerified());
      print('Is user anonymous?:');
      print(isUserAnonymous());
      print('User metadata:');
      print(getAllUserMetadata());
      print('User creation time:');
      print(getUserCreationTime());
      print('User last sign in time:');
      print(getUserLastSignInTime());
      print('User multifactor:');
      print(getUserMultifactor());
      print('User phone number:');
      print(getUserPhoneNumber());
      print('User photo URL:');
      print(getUserPhotoURL());
      print('Provider data:');
      print(getUserProviderData());
      print('Refresh token:');
      print(getUserRefreshToken());
      print('Tenant ID:');
      print(getUserTenantID());
      print('UID:');
      print(getUserID());
      print('Hash code:');
      print(getUserHashcode());
      print('Runtime type:');
      print(getUserRuntimeType());
    }
  }

  // Continue new user info getters

  String? getAllUserInfo() {
    return currentUser?.toString();
  }

  String? getUserID() {
    return currentUser?.uid;
  }

  String? getDisplayName() {
    return currentUser?.displayName;
  }

  String? getEmailNew() {
    return currentUser?.email;
  }

  bool isEmailVerified() {
    if (currentUser != null) {
      if (currentUser!.emailVerified) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool isUserAnonymous() {
    if (currentUser != null) {
      if (currentUser!.isAnonymous) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  String? getAllUserMetadata() {
    return currentUser?.metadata.toString();
  }

  DateTime? getUserCreationTime() {
    return currentUser?.metadata.creationTime;
  }

  DateTime? getUserLastSignInTime() {
    return currentUser?.metadata.lastSignInTime;
  }

  String? getUserMultifactor() {
    return currentUser?.multiFactor.toString();
  }

  String? getUserPhoneNumber() {
    return currentUser?.phoneNumber;
  }

  String? getUserPhotoURL() {
    return currentUser?.photoURL;
  }

  String? getUserProviderData() {
    return currentUser?.providerData.toString();
  }

  String? getUserRefreshToken() {
    return currentUser?.refreshToken;
  }

  String? getUserTenantID() {
    return currentUser?.tenantId;
  }

  String? getUserHashcode() {
    return currentUser?.hashCode.toString();
  }

  String? getUserRuntimeType() {
    return currentUser?.runtimeType.toString();
  }

  void validateGetters() {
    print(_auth.currentUser?.toString() == getAllUserInfo());

    print(_auth.currentUser?.uid == getUserID());

    print(_auth.currentUser?.displayName == getDisplayName());

    print(_auth.currentUser?.email == getEmailNew());

    print(_auth.currentUser?.emailVerified == isEmailVerified());

    print(_auth.currentUser?.isAnonymous == isUserAnonymous());

    print(_auth.currentUser?.metadata.toString() == getAllUserMetadata());

    print(_auth.currentUser?.metadata.creationTime == getUserCreationTime());

    print(
      _auth.currentUser?.metadata.lastSignInTime == getUserLastSignInTime(),
    );

    print(_auth.currentUser?.multiFactor.toString() == getUserMultifactor());

    print(_auth.currentUser?.phoneNumber == getUserPhoneNumber());

    print(_auth.currentUser?.photoURL == getUserPhotoURL());

    print(_auth.currentUser?.providerData.toString() == getUserProviderData());

    print(_auth.currentUser?.refreshToken == getUserRefreshToken());

    print(_auth.currentUser?.tenantId == getUserTenantID());

    print(_auth.currentUser?.uid == getUserID());

    print(_auth.currentUser?.hashCode.toString() == getUserHashcode());

    print(_auth.currentUser?.runtimeType.toString() == getUserRuntimeType());
  }
}
