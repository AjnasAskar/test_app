import 'package:firebase_auths/common/consts.dart';
import 'package:firebase_auths/common/extensions.dart';
import 'package:firebase_auths/generated/assets.dart';
import 'package:firebase_auths/services/firebase_auth_services.dart';
import 'package:firebase_auths/view/home_screen.dart';
import 'package:firebase_auths/view_model/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              Assets.iconsFirebaseIcon,
              height: context.sw(size: 0.35),
              width: context.sw(size: 0.35),
            ),
            SizedBox(
              height: context.sw(size: 0.15),
            ),
            const _GoogleBtn(),
            const SizedBox(
              height: 10,
            ),
            _PhoneBtn(
              context: context,
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<AuthViewModel>().authInit();
    });
    super.initState();
  }
}

class _GoogleBtn extends StatelessWidget {
  const _GoogleBtn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Selector<AuthViewModel, LoadState>(
      selector: (context, provider) => provider.googleLoader,
      builder: (context, value, child) {
        return _BtnOutline(
          enableLoader: value == LoadState.loading,
          leading: Container(
              height: 35,
              width: 35,
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: SvgPicture.asset(Assets.iconsGoogleIcon)),
          title: 'Google',
          onTap: () {
            context.read<AuthViewModel>().googleSignIn(context).then((value) {
              if (value != null) {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false);
              }
            });
          },
        );
      },
    );
  }
}

class _PhoneBtn extends StatefulWidget {
  final BuildContext context;

  const _PhoneBtn({Key? key, required this.context}) : super(key: key);

  @override
  State<_PhoneBtn> createState() => _PhoneBtnState();
}

class _PhoneBtnState extends State<_PhoneBtn> {
  late final TextEditingController _phoneController;
  late final TextEditingController _codeController;
  final formGlobalKey = GlobalKey<FormState>();

  void showMobileFieldSheet() {
    showBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            child: Form(
              key: formGlobalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  const Text(
                    'Enter the mobile number',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                    ],
                    decoration: const InputDecoration(
                      hintText: "Phone number",
                      prefixText: "+91 ",
                    ),
                    validator: (val) {
                      String value = (val ?? '').trim();
                      String pattern = r'^-?(([0-9]*)|(([0-9]*)\.([0-9]*)))$';
                      RegExp regExp = RegExp(pattern);
                      if (!regExp.hasMatch(value) || value.length != 10) {
                        return 'Enter a valid number';
                      }
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          maximumSize: const Size.fromHeight(50),
                          minimumSize: const Size.fromHeight(50),
                          backgroundColor: Colors.lightGreen),
                      onPressed: onVerify,
                      child: const Text(
                        'Register',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 20),
                      ))
                ],
              ),
            ),
          );
        });
  }

  void showOtpSheet(String verificationId) {
    showDialog(
        context: widget.context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text("Give the code?"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _codeController,
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text("Confirm"),
                onPressed: () async {
                  final code = _codeController.text.trim();
                  FocusScope.of(context).unfocus();
                  Navigator.of(context).pop();
                  widget.context
                      .read<AuthViewModel>()
                      .verifyMobileSignIn(
                          verificationId: verificationId,
                          smsCode: code,
                          context: widget.context)
                      .then((value) {
                    if (value != null) {
                      Navigator.pushAndRemoveUntil(
                          widget.context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false);
                    }
                  });
                },
              )
            ],
          );
        });
  }

  void onVerify() {
    if (formGlobalKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pop();
      FirebaseAuthServices.instance.mobileSignIn(
          mobile: _phoneController.text,
          context: context,
          onCodeSent: (String verificationId) {
            showOtpSheet(verificationId);
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Selector<AuthViewModel, LoadState>(
      selector: (context, provider) => provider.mobileLoader,
      builder: (context, value, child) {
        return _BtnOutline(
          enableLoader: value == LoadState.loading,
          leading: Container(
              height: 35,
              width: 35,
              padding: const EdgeInsets.all(5),
              child: const Icon(
                Icons.call,
                color: Colors.white,
              )),
          color: Colors.lightGreen,
          title: 'Phone',
          onTap: showMobileFieldSheet,
        );
      },
    );
  }

  @override
  void initState() {
    _phoneController = TextEditingController();
    _codeController = TextEditingController();
    super.initState();
  }
}

class _BtnOutline extends StatelessWidget {
  final Widget leading;
  final String title;
  final Color? color;
  final bool enableLoader;
  final VoidCallback onTap;

  const _BtnOutline(
      {Key? key,
      required this.leading,
      required this.onTap,
      required this.title,
      this.enableLoader = false,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.sw(size: 0.08)),
      child: InkWell(
        onTap: enableLoader ? null : onTap,
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.maxFinite,
          decoration: BoxDecoration(
              color: color ?? const Color(0xFF4285F4),
              borderRadius: BorderRadius.circular(30)),
          child: enableLoader
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ))
              : Row(
                  children: [
                    leading,
                    Expanded(
                        child: Transform.translate(
                      offset: const Offset(-10, 0),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700),
                      ),
                    ))
                  ],
                ),
        ),
      ),
    );
  }
}
