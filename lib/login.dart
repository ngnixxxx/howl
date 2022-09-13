import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/email_register.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/widgets/custom_dialog.dart';

class Login extends StatefulWidget {
  final bool desktopLayout;

  const Login({Key key, this.desktopLayout}) : super(key: key);
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _passwordHidden = true;
  bool submitting = false;
  String _email, _password;

  AuthMethods _authMethods = AuthMethods();

  final formKey = GlobalKey<FormState>();

  void _showPassword() {
    setState(() {
      _passwordHidden = !_passwordHidden;
    });
  }

  _submit() async {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      setState(() {
        submitting = true;
      });
      dynamic result = await _authMethods.emailSignIn(
        email: _email,
        password: _password,
      );

      if (result is bool) {
        if (result) {
          setState(() {
            submitting = true;
          });
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            submitting = false;
          });
          return showModalBottomSheet(
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
        }
      } else {
        setState(() {
          submitting = false;
        });
        await showModalBottomSheet(
            context: context,
            builder: (context) {
              return CustomDialog(
                title: 'Error..',
                content: Text(
                  result.toString().isNotEmpty
                      ? result.toString()
                      : 'Something went wrong',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                mainActionText: 'Try Again',
                function: () => Navigator.pop(context),
                secondaryActionText: 'Forgot Password',
                function1: () =>
                    Navigator.pushReplacementNamed(context, '/signup'),
              );
            });
      }
    }
  }

  FocusNode emailNode;
  FocusNode passwordNode;
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    emailController?.dispose();
    passwordController?.dispose();
    super.dispose();
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
        key: formKey,
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: widget.desktopLayout
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontFamily: 'Noto-Sans-HK',
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Theme.of(context).textTheme.bodyText1.color,
                    ),
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                TextFormField(
                  controller: emailController,
                  focusNode: emailNode,
                  style: Theme.of(context).textTheme.bodyText1,
                  onSaved: (value) => _email = value,
                  validator: (value) => value.isEmpty && !value.contains('@')
                      ? 'Please type in your email!'
                      : null,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, emailNode, passwordNode);
                  },
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'Email',
                    prefixIcon: Icon(Feather.mail,
                        color: Theme.of(context).primaryIconTheme.color),
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                TextFormField(
                  style: Theme.of(context).textTheme.bodyText1,
                  focusNode: passwordNode,
                  controller: passwordController,
                  onSaved: (value) => _password = value,
                  validator: (value) => value.length < 6
                      ? 'Make it at least more than 6 letters'
                      : null,
                  obscureText: _passwordHidden,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (term) {
                    _fieldFocusChange(context, passwordNode, _submit());
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordHidden ? Feather.eye : Feather.eye_off,
                        color: Theme.of(context).primaryIconTheme.color,
                      ),
                      onPressed: _showPassword,
                    ),
                    labelText: 'Password',
                    prefixIcon: Icon(
                      Feather.lock,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyText1
                              .apply(color: Theme.of(context).accentColor))),
                ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                if (submitting)
                  ElevatedButton.icon(
                    icon: CircularProgressIndicator(
                      strokeWidth: 1,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {},
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 32),
                      child: Text(
                        'LOGING IN..',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  )
                else
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32)),
                    onPressed: _submit,
                    child: Center(
                      child: Text(
                        'LOGIN',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ),
                SizedBox(height: widget.desktopLayout ? 42 : 20),
                !widget.desktopLayout
                    ? Wrap(
                        alignment: WrapAlignment.start,
                        children: <Widget>[
                          Text(
                            'Don\'t Have an Account? ',
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          InkWell(
                            onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => EmailSignUp(
                                        desktopLayout: widget.desktopLayout))),
                            child: Text(
                              'REGISTER',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .color,
                                  fontFamily: 'Noto-Sans-HK',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
