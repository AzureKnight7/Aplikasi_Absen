// ignore_for_file: public_member_api_docs, sort_constructors_first
// ignore_for_file: camel_case_types, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:new_attandance/src/presentation/auth/screen/register_screen.dart';
import 'package:new_attandance/src/presentation/auth/widget/q_button_access.dart';
import 'package:new_attandance/src/presentation/auth/widget/q_button_auth.dart';
import 'package:new_attandance/src/presentation/auth/widget/q_head_logo.dart';

import 'package:new_attandance/src/presentation/auth/widget/q_textfield_login.dart';
import 'package:new_attandance/src/presentation/home/screen/home_screen.dart';
import 'package:new_attandance/src/shared/bloc/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/function/q_function.dart';
import '../bloc/auth/auth_bloc.dart';
import '../widget/q_dialog_error.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool isRememberMeChecked = false;

  @override
  void initState() {
    super.initState();
    _loadRememberedCredentials();
  }

  Future<void> _loadRememberedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isRememberMeChecked = prefs.getBool('remember_me') ?? false;
      if (isRememberMeChecked) {
        email.text = prefs.getString('email') ?? '';
        password.text = prefs.getString('password') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (isRememberMeChecked) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('email', email.text);
      await prefs.setString('password', password.text);
    } else {
      await prefs.setBool('remember_me', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var auth = context.read<AuthBloc>();
    var theme = context.read<ThemeCubit>();

    return BlocListener<AuthBloc, AuthState>(
      bloc: auth,
      listener: (context, state) {
        state.maybeWhen(
          orElse: () {},
          authenticate: (name, email, profile) => Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => HomeScreen(
                      username: name,
                      email: email,
                      profile: profile,
                    )),
          ),
          failed: (errorMessage) async {
            await showDialog<void>(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return QDialogError(
                  errorMessage: errorMessage,
                );
              },
            );
          },
        );
      },
      child: Scaffold(
        backgroundColor: Color(0xff537FE7),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    ClipPath(
                      clipper: HalfImageClipper(),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage("assets/icon/photo_2.png"),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: 270, bottom: 40),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      left: 20,
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: Color(0xff537FE7),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            "assets/icon/Back.svg",
                            colorFilter: const ColorFilter.mode(
                                Colors.white, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    child: QHeadLogo(h: h, title: "Welcome Back")),
                const SizedBox(
                  height: 30.0,
                ),
                Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      SizedBox(height: 40),
                      QTextfieldAuth(
                        controller: email,
                        hint: "",
                        title: "Email Office",
                        isUseIcon: false,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      QTextfieldAuth(
                        controller: password,
                        hint: "",
                        title: "Password",
                        isUseIcon: true,
                        icon: Icons.remove_red_eye,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isRememberMeChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isRememberMeChecked = value!;
                                    });
                                  },
                                ),
                                const Text("Remember me"),
                              ],
                            ),
                            const Text(
                              "Forget Password?",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  color: Color(0xff5D5D65),
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 15.0,
                      ),
                      BlocBuilder<AuthBloc, AuthState>(
                        bloc: auth,
                        builder: (context, state) {
                          return state.maybeWhen(
                            orElse: () {
                              return QButtonAuth(
                                h: h,
                                title: "Login",
                                onPress: () async {
                                  if (email.text.isEmpty &&
                                      password.text.isEmpty) {
                                    dialogError(context,
                                        "Email and password must not be empty");
                                  } else {
                                    await _saveCredentials();
                                    auth.add(AuthEvent.login(
                                        email: email.text,
                                        password: password.text));
                                  }
                                },
                              );
                            },
                            loading: () {
                              return circularLoadingAuth(context);
                            },
                          );
                        },
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      QButtonAcccess(
                        title: "Dont have account? Please contact HR?",
                        head: "",
                        onPress: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterScreens()),
                          );
                        },
                      ),
                      const SizedBox(
                        height: 40.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HalfImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(40.0, 10),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
