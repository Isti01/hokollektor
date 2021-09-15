import 'dart:convert';
import "dart:developer" as developer;

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hokollektor/collector_app.dart';
import 'package:hokollektor/home/home.dart';
import 'package:hokollektor/localization.dart' as loc;
import 'package:hokollektor/main.dart';
import 'package:hokollektor/util/loading.dart';
import 'package:hokollektor/util/networking.dart';
import 'package:hokollektor/util/urls.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final ratio = s.width / s.height;
    final size = ratio * 225;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(children: [
          Transform.translate(
            offset: Offset(size / s.width * 100, -size / s.height * 200),
            child: Align(
              alignment: Alignment.topRight,
              child: CollectorProgressIndicator(
                size: size,
              ),
            ),
          ),
          Center(
              child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LoginForm(),
              LoginAsGuest(
                onTap: () => _loginAsGuest(context),
              ),
            ],
          )),
        ]),
      ),
    );
  }

  _loginAsGuest(context) {
    inGuestMode = true;
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
      return const CollectorApp(child: HomePage());
    }));
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key key}) : super(key: key);

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  String error;
  bool loading = false;
  bool stayLoggedIn = false;
  final formKey = GlobalKey<FormState>(debugLabel: "Login Form Label");
  final List<FocusNode> nodes = [
    FocusNode(),
    FocusNode(),
  ];

  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _userController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Material(
            shape: const RoundedRectangleBorder(borderRadius: kAppBorderRadius),
            elevation: 4,
            color: Colors.white,
            child: Form(
              key: formKey,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    LoginInput(
                      controller: _userController,
                      labelText: loc.getText(loc.user),
                      icon: const Icon(Icons.person),
                      node: nodes[0],
                      onSubmitted: (String text) {
                        FocusScope.of(context).requestFocus(nodes[1]);
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    LoginInput(
                      controller: _passController,
                      labelText: loc.getText(loc.pass),
                      icon: const Icon(Icons.lock),
                      obscureText: true,
                      node: nodes[1],
                      onSubmitted: (String text) => nodes[1].unfocus(),
                    ),
                    const SizedBox(height: 2),
                    error != null
                        ? Text(
                            error,
                            textAlign: TextAlign.center,
                            style: theme.button.copyWith(color: Colors.red),
                          )
                        : loading
                            ? Wrap(children: const [
                                Center(
                                  child: CircularProgressIndicator(),
                                )
                              ])
                            : Container(),
                    const SizedBox(height: 2),
                    CheckBoxTile(
                      value: stayLoggedIn,
                      onChanged: (bool value) =>
                          setState(() => stayLoggedIn = value),
                      title: Text(
                        loc.getText(loc.stayLoggedIn),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        LoginButton(
          text: loc.getText(loc.login),
          onPressed: _loginButtonPressed,
          gradientColors: const [
            kHomePanelColor,
            kChartPanelColor,
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    for (FocusNode node in nodes) {
      node.dispose();
    }

    _userController.dispose();
    _passController.dispose();
  }

  _loginButtonPressed() async {
    if (!formKey.currentState.validate()) return;
    setState(() => loading = true);
    String res = await _login(_userController.text, _passController.text);

    if (res == '') {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return const CollectorApp(
          child: HomePage(),
        );
      }));
      if (stayLoggedIn) {
        _saveStayLoggedIn();
      }
    } else {
      setState(() {
        error = res;
        loading = false;
      });
    }
  }
}

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final List<Color> gradientColors;
  final String text;

  const LoginButton({Key key, this.onPressed, this.gradientColors, this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey[800],
              offset: const Offset(0, 1.5),
              blurRadius: 1.5,
            ),
          ],
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: kAppBorderRadius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: kAppBorderRadius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 42),
              child: Text(
                text,
                style: theme.headline6.copyWith(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }
}

class LoginInput extends StatelessWidget {
  final bool obscureText;
  final Function(String content) onSubmitted;
  final Widget icon;
  final String labelText;
  final FocusNode node;
  final TextEditingController controller;

  const LoginInput({
    Key key,
    this.onSubmitted,
    this.obscureText = false,
    this.icon,
    this.labelText,
    this.node,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const border = UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.none,
        color: Colors.transparent,
      ),
    );

    return TextFormField(
      validator: (String text) {
        if (text == null) {
          return null;
        }
        if (text.isEmpty) {
          return loc.getText(loc.noTextAdded);
        }
        return null;
      },
      controller: controller,
      focusNode: node,
      obscureText: obscureText,
      onFieldSubmitted: onSubmitted,
      decoration: InputDecoration(
        fillColor: Colors.transparent,
        prefixIcon: icon,
        labelText: labelText,
        border: border,
        disabledBorder: border,
        enabledBorder: border,
        errorBorder: border,
        focusedBorder: border,
        focusedErrorBorder: border,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

Future<String> _login(String user, String pass) async {
  if (!await isConnected()) return loc.getText(loc.noInternet);

  try {
    final chars = const Utf8Encoder().convert(pass);

    final digest = md5.convert(chars);

    final password = hex.encode(digest.bytes);

    final http.Response res = await http.post(Uri.parse(kLoginURL), body: {
      'username': user,
      'password': password,
    });

    final resJson = jsonDecode(res.body);

    if (resJson['success']) {
      return '';
    } else {
      return loc.getText(loc.invalidUserInfo);
    }
  } catch (e) {
    developer.log(e);
    return loc.getText(loc.invalidUserInfo);
  }
}

void _saveStayLoggedIn() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool(stayLoggedInKey, true);
  } catch (e) {
    developer.log(e.toString());
  }
}

class CheckBoxTile extends StatelessWidget {
  final bool value;
  final Function(bool value) onChanged;
  final Widget title;

  const CheckBoxTile({
    Key key,
    this.value,
    this.onChanged,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Row(
        children: <Widget>[
          const Spacer(),
          InkWell(
            borderRadius: kAppBorderRadius,
            onTap: () => onChanged(!value),
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  title,
                  Checkbox(value: value, onChanged: onChanged),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class LoginAsGuest extends StatelessWidget {
  final Color color;
  final VoidCallback onTap;

  const LoginAsGuest({Key key, this.color = Colors.white, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: OrLine(text: loc.getText(loc.or), color: color),
        ),
        LoginButton(
          text: loc.getText(loc.signInAsGuest),
          onPressed: onTap,
          gradientColors: const [
            kChartPanelColor,
            kHomePanelColor,
          ],
        ),
      ],
    );
  }
}

class OrLine extends StatelessWidget {
  final String text;
  final Color color;

  const OrLine({Key key, this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Spacer(flex: 6),
        Flexible(flex: 4, child: Container(height: 1, color: color)),
        Flexible(flex: 3, child: Container(height: 2, color: color)),
        const SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.subtitle1.copyWith(color: color),
        ),
        const SizedBox(width: 8),
        Flexible(flex: 3, child: Container(height: 2, color: color)),
        Flexible(flex: 4, child: Container(height: 1, color: color)),
        const Spacer(flex: 6),
      ],
    );
  }
}
