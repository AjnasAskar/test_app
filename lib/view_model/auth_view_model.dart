import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auths/common/consts.dart';
import 'package:firebase_auths/services/firebase_auth_services.dart';
import 'package:flutter/material.dart';

class AuthViewModel extends ChangeNotifier {
  LoadState googleLoader = LoadState.loaded;
  LoadState mobileLoader = LoadState.loaded;
  User? user;

  Future<User?> googleSignIn(BuildContext context) async {
    User? userData;
    updateGoogleLoadState(LoadState.loading);
    userData =
        await FirebaseAuthServices.instance.signInWithGoogle(context: context);
    user = userData;
    updateGoogleLoadState(LoadState.loaded);
    return userData;
  }

  Future<User?> validateUserLoginStat() async {
    User? userData;
    userData = await FirebaseAuthServices.instance.initializeFirebase();
    user = userData;
    notifyListeners();
    return userData;
  }

  Future<User?> mobileSignIn(
      {required String mobile,
      required BuildContext context,
      required Function(String) onCodeSent}) async {
    User? userData;
    updateMobileLoadState(LoadState.loading);
    userData = await FirebaseAuthServices.instance
        .mobileSignIn(mobile: mobile, context: context, onCodeSent: onCodeSent);
    user = userData;
    updateMobileLoadState(LoadState.loaded);
    return userData;
  }

  Future<User?> verifyMobileSignIn(
      {required String verificationId,
      required String smsCode,
      required BuildContext context}) async {
    User? userData;
    updateMobileLoadState(LoadState.loading);
    userData = await FirebaseAuthServices.instance.verifyMobileOtp(
        verificationId: verificationId, smsCode: smsCode, context: context);
    user = userData;
    updateMobileLoadState(LoadState.loaded);
    return userData;
  }

  void updateGoogleLoadState(LoadState state) {
    googleLoader = state;
    notifyListeners();
  }

  void updateMobileLoadState(LoadState state) {
    mobileLoader = state;
    notifyListeners();
  }

  Future<void> logoutUser(
      {required BuildContext context, required Function onSuccess}) async {
    bool res = await FirebaseAuthServices.instance.signOut(context: context);
    if (res) {
      onSuccess();
      return;
    }
    user = null;
    notifyListeners();
  }

  void authInit() {
    user = null;
    googleLoader = LoadState.loaded;
    mobileLoader = LoadState.loaded;
    notifyListeners();
  }
}
