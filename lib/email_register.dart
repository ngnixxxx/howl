import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/login.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/widgets/custom_dialog.dart';

class EmailSignUp extends StatefulWidget {
  final bool desktopLayout;

  const EmailSignUp({Key key, this.desktopLayout}) : super(key: key);
  @override
  _EmailSignUpState createState() => _EmailSignUpState();
}

class _EmailSignUpState extends State<EmailSignUp> {
  bool _passwordHidden = true;
  bool submitting = false;
  static String _email, _password, _username;

  AuthMethods _authMethods = AuthMethods();
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  final _formKey = GlobalKey<FormState>();

  void _showPassword() {
    setState(() {
      _passwordHidden = !_passwordHidden;
    });
  }

  _submit() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();
      setState(() {
        submitting = true;
      });
      var result = await _authMethods.emailRegister(
          email: _email,
          password: _password,
          username: _username.trim().toLowerCase());
      if (result is bool) {
        if (result) {
          await authenticateEmailUser(result, _username.trim().toLowerCase());
        } else {
          await showDialog(
              context: context,
              builder: (context) {
                return CustomDialog(
                  title: 'Error..',
                  content: Text('General sign up failure try again ',
                      style: Theme.of(context).textTheme.bodyText1),
                  mainActionText: 'Okay',
                  function: () => Navigator.pop(context),
                );
              });
          setState(() {
            submitting = true;
          });
        }
      } else {
        await showDialog(
            context: context,
            builder: (context) {
              return CustomDialog(
                title: 'Error..',
                content: Text(result.toString(),
                    style: Theme.of(context).textTheme.bodyText1),
                mainActionText: 'Okay',
                function: () => Navigator.pop(context),
              );
            });
        setState(() {
          submitting = true;
        });
      }
    }
  }

  authenticateEmailUser(result, String username) async {
    var newUser = await _authMethods.authanticateEmailUser(
      result,
      username,
    );
    if (newUser) {
      await _firebaseMethods.addEmailDataToDb(result, username);

      setState(() {
        submitting = false;
      });
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      await showDialog(
          context: context,
          builder: (context) {
            return CustomDialog(
              title: 'Error..',
              content: Text(result.toString(),
                  style: Theme.of(context).textTheme.bodyText1),
              mainActionText: 'Okay',
              function: () => Navigator.pop(context),
            );
          });
      setState(() {
        submitting = false;
      });
    }
  }

  Container showError() {
    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: !widget.desktopLayout
          ? AppBar(
              leading: IconButton(
                  icon: Icon(Feather.x),
                  onPressed: () => Navigator.pop(context)),
            )
          : null,
      body: Form(
        key: _formKey,
        child: Container(
          width: widget.desktopLayout
              ? MediaQuery.of(context).size.width * 0.25
              : MediaQuery.of(context).size.width,
          height: widget.desktopLayout
              ? MediaQuery.of(context).size.width * 0.5
              : MediaQuery.of(context).size.height,
          alignment: !widget.desktopLayout
              ? Alignment.bottomLeft
              : Alignment.centerRight,
          margin: widget.desktopLayout
              ? EdgeInsets.symmetric(vertical: 40, horizontal: 64)
              : EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: widget.desktopLayout
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Text(
                  'Create Account',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.headline6.color,
                      fontSize: 30,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(
                    height: widget.desktopLayout
                        ? 42
                        : MediaQuery.of(context).size.height * 0.1),
                TextFormField(
                  onSaved: (value) => _username = value,
                  maxLines: 1,
                  style: Theme.of(context).textTheme.bodyText1,
                  validator: (value) => value.trim().isEmpty
                      ? 'Please type in a username!'
                      : null,
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  onChanged: (value) {
                    _authMethods.usernameExists(_username).then((value) {
                      showError();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    isDense: true,
                    prefixIcon: Icon(
                      Feather.user,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  onSaved: (value) => _email = value,
                  validator: (value) => value.isEmpty
                      ? 'Please type in your email!'
                      : !value.contains('@')
                          ? 'Enter a valid email'
                          : null,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    isDense: true,
                    prefixIcon: Icon(
                      Feather.mail,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                TextFormField(
                  onSaved: (value) => _password = value,
                  validator: (value) => value.length < 6
                      ? 'Make it at least more than 6 letters'
                      : null,
                  obscureText: _passwordHidden,
                  style: Theme.of(context).textTheme.bodyText1,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(
                          _passwordHidden ? Feather.eye : Feather.eye_off,
                          color: Theme.of(context).primaryIconTheme.color),
                      onPressed: _showPassword,
                    ),
                    prefixIcon: Icon(
                      Feather.lock,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                    isDense: true,
                    labelText: 'Password',
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                submitting
                    ? ElevatedButton.icon(
                        icon: const CircularProgressIndicator(
                          strokeWidth: 1,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 32),
                          child: Text(
                            'CREATING ACCOUNT..',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                        onPressed: () {},
                      )
                    : ElevatedButton(
                        onPressed: () => _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 32),
                          child: Text(
                            'CREATE ACCOUNT',
                            style: Theme.of(context).textTheme.bodyText2,
                          ),
                        ),
                      ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                widget.desktopLayout
                    ? Container()
                    : Wrap(
                        alignment: WrapAlignment.start,
                        children: <Widget>[
                          Text(
                            'Already Have an Account? ',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => Login(
                                        desktopLayout: widget.desktopLayout))),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color:
                                    Theme.of(context).textTheme.bodyText1.color,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
