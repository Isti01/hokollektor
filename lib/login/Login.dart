import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:hokollektor/HokollektorApp.dart';
import 'package:hokollektor/Loading.dart';
import 'package:hokollektor/Localization.dart' as loc;
import 'package:hokollektor/home/Home.dart';
import 'package:hokollektor/main.dart';
import 'package:hokollektor/util/Networking.dart';
import 'package:hokollektor/util/URLs.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    final ratio = s.width / s.height;
    final size = ratio * 225;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
              LoginForm(),
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
      return HokollektorApp(
        child: HomePage(),
      );
    }));
  }
}

class LoginForm extends StatefulWidget {
  @override
  LoginFormState createState() {
    return new LoginFormState();
  }
}

class LoginFormState extends State<LoginForm> {
  String error;
  bool loading = false;
  bool stayLoggedIn = false;
  final formKey = new GlobalKey<FormState>(debugLabel: "Login Form Label");
  final List<FocusNode> nodes = [
    FocusNode(),
    FocusNode(),
  ];

  TextEditingController _userController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();

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
            shape: RoundedRectangleBorder(borderRadius: appBorderRadius),
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
                    SizedBox(height: 8),
                    LoginInput(
                      controller: _userController,
                      labelText: loc.getText(loc.user),
                      icon: Icon(Icons.person),
                      node: nodes[0],
                      onSubmitted: (String text) {
                        FocusScope.of(context).requestFocus(nodes[1]);
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(
                        color: Colors.grey,
                      ),
                    ),
                    LoginInput(
                      controller: _passController,
                      labelText: loc.getText(loc.pass),
                      icon: Icon(Icons.lock),
                      obscureText: true,
                      node: nodes[1],
                      onSubmitted: (String text) => nodes[1].unfocus(),
                    ),
                    SizedBox(height: 2),
                    error != null
                        ? Text(
                            error,
                            textAlign: TextAlign.center,
                            style: theme.button.copyWith(color: Colors.red),
                          )
                        : loading
                            ? Wrap(children: [
                                const Center(
                                  child: CircularProgressIndicator(),
                                )
                              ])
                            : Container(),
                    SizedBox(height: 2),
                    CheckBoxTile(
                      value: stayLoggedIn,
                      onChanged: (bool value) =>
                          this.setState(() => stayLoggedIn = value),
                      title: Text(
                        loc.getText(loc.stayLoggedIn),
                        textAlign: TextAlign.end,
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
        LoginButton(
          text: loc.getText(loc.login),
          onPressed: _loginButtonPressed,
          gradientColors: [
            HomePanelColor,
            ChartPanelColor,
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();

    for (FocusNode node in nodes) node.dispose();

    _userController.dispose();
    _passController.dispose();
  }

  _loginButtonPressed() async {
    if (!formKey.currentState.validate()) return;
    this.setState(() => loading = true);
    String res = await _login(_userController.text, _passController.text);

    if (res == '') {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
        return HokollektorApp(
          child: HomePage(),
        );
      }));
      if (stayLoggedIn) {
        _saveStayLoggedIn();
      }
    } else {
      this.setState(() {
        this.error = res;
        this.loading = false;
      });
    }
  }
}

class LoginButton extends StatelessWidget {
  final onPressed;
  final gradientColors;
  final text;

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
              offset: Offset(0, 1.5),
              blurRadius: 1.5,
            ),
          ],
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: appBorderRadius,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: appBorderRadius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 42),
              child: Text(
                text,
                style: theme.title.copyWith(color: Colors.white),
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
    final border = UnderlineInputBorder(
      borderSide: BorderSide(
        style: BorderStyle.none,
        color: Colors.transparent,
      ),
    );

    return TextFormField(
      validator: (String text) {
        if (text == null) return null;
        if (text.length == 0) return loc.getText(loc.noTextAdded);
      },
      controller: controller,
      focusNode: this.node,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}

Future<String> _login(String user, String pass) async {
  if (!await isConnected()) return loc.getText(loc.noInternet);

  try {
    final chars = Utf8Encoder().convert(pass);

    final digest = md5.convert(chars);

    final password = hex.encode(digest.bytes);

    final http.Response res = await http.post(loginURL, body: {
      'username': user,
      'password': password,
    });

    final resJson = jsonDecode(res.body);

    if (resJson['success'])
      return '';
    else
      return loc.getText(loc.invalidUserInfo);
  } catch (e) {
    print(e);
    return loc.getText(loc.invalidUserInfo);
  }
}

void _saveStayLoggedIn() async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setBool(stayLoggedInKey, true);
  } catch (e) {
    print(e.toString());
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
    return Container(
      height: 35,
      child: Row(
        children: <Widget>[
          Spacer(),
          InkWell(
            borderRadius: appBorderRadius,
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
          Spacer(),
        ],
      ),
    );
  }
}

class LoginAsGuest extends StatelessWidget {
  final color;
  final onTap;

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
          gradientColors: [
            ChartPanelColor,
            HomePanelColor,
          ],
        ),
      ],
    );
  }
}

class OrLine extends StatelessWidget {
  final text;
  final color;

  const OrLine({Key key, this.text, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Spacer(flex: 6),
        Flexible(flex: 4, child: Container(height: 1, color: color)),
        Flexible(flex: 3, child: Container(height: 2, color: color)),
        SizedBox(width: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.subhead.copyWith(color: color),
        ),
        SizedBox(width: 8),
        Flexible(flex: 3, child: Container(height: 2, color: color)),
        Flexible(flex: 4, child: Container(height: 1, color: color)),
        Spacer(flex: 6),
      ],
    );
  }
}
