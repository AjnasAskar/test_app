import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auths/view/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthServices {
  static final FirebaseAuthServices instance = FirebaseAuthServices._internal();

  factory FirebaseAuthServices() => instance;

  FirebaseAuthServices._internal();

  late final FirebaseAuth auth = FirebaseAuth.instance;
  late final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<User?> initializeFirebase() async {
    await Firebase.initializeApp();
    User? user = auth.currentUser;
    return user;
  }

  Future<User?> signInWithGoogle({required BuildContext context}) async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    User? user;
    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken);

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          if (context.mounted) {
            showFirebaseError(context,
                'The account already exists with a different credential');
          }
        } else if (e.code == 'invalid-credential') {
          if (context.mounted) {
            showFirebaseError(context,
                'Error occurred while accessing credentials. Try again.');
          }
        }
      } catch (e) {
        if (context.mounted) {
          showFirebaseError(context,
              'Error occurred while accessing credentials. Try again.');
        }
      }
    }

    return user;
  }

  Future<bool> signOut({required BuildContext context}) async {
    try {
      await googleSignIn.signOut();
      await auth.signOut();
      return true;
    } catch (e) {
      showFirebaseError(context, 'Error signing out. Try again.');
      return false;
    }
  }

  Future<User?> mobileSignIn(
      {required String mobile,
      required BuildContext context,
      required Function(String) onCodeSent}) async {
    User? user;
    await auth.verifyPhoneNumber(
        phoneNumber: "+91$mobile",
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) async {
          final UserCredential userCredential =
              await auth.signInWithCredential(authCredential);
          user = userCredential.user;
        },
        verificationFailed: (FirebaseAuthException authException) {
          showFirebaseError(context, authException.message.toString());
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print(verificationId);
          print("Timout");
        });
    return user;
  }

  Future<User?> verifyMobileOtp({
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) async {
    User? user;
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    try {
      final UserCredential userCredential =
          await auth.signInWithCredential(credential);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        if (context.mounted) {
          showFirebaseError(context,
              'The account already exists with a different credential');
        }
      } else if (e.code == 'invalid-credential') {
        if (context.mounted) {
          showFirebaseError(context,
              'Error occurred while accessing credentials. Try again.');
        }
      }
    } catch (e) {
      if (context.mounted) {
        showFirebaseError(
            context, 'Error occurred while accessing credentials. Try again.');
      }
    }
    return user;
  }
}

void showFirebaseError(BuildContext context, String msg) {
  ScaffoldMessenger.of(context).showSnackBar(
    customSnackBar(
      content: 'Error occurred while accessing credentials. Try again.',
    ),
  );
}

SnackBar customSnackBar({required String content}) {
  return SnackBar(
    backgroundColor: Colors.black,
    content: Text(
      content,
      style: const TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
    ),
  );
}
