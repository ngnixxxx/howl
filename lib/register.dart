import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:howl/email_register.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username, name, email, googleUsername;
  var phoneNo, code, verificationId;
  bool googleIsLoading = false,
      verifying = false,
      googleEnteringUsername = false,
      entringUserDetails = false,
      sending = false,
      confirming = false,
      sent = false;

  final formKey = new GlobalKey<FormState>();
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();

  bool desktopLayout = false;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (context, orientation) {
      if (MediaQuery.of(context).size.width > 600) {
        desktopLayout = true;
      } else {
        desktopLayout = false;
      }
      return Scaffold(
        appBar: desktopLayout
            ? AppBar(actions: [
                Container(
                    alignment: Alignment.center,
                    child: Text('already a user?',
                        style: Theme.of(context).textTheme.bodyText1)),
                const SizedBox(width: 68),
                TextButton(
                    onPressed: () {},
                    child: Text("Login",
                        style: Theme.of(context).textTheme.headline6)),
                const SizedBox(width: 68),
              ])
            : null,
        body: Form(
          key: formKey,
          child: Row(
            children: [
              if (desktopLayout)
                Padding(
                  padding: const EdgeInsets.only(left: 72),
                  child: Text('Welcome To Mooncurse',
                      softWrap: true,
                      style: Theme.of(context).textTheme.headline2),
                )
              else
                const SizedBox(width: 0, height: 0),
              if (desktopLayout)
                SizedBox(width: MediaQuery.of(context).size.width * 0.1)
              else
                const SizedBox(width: 0, height: 0),
              Expanded(
                child: Container(
                  width: desktopLayout
                      ? MediaQuery.of(context).size.width * 0.25
                      : MediaQuery.of(context).size.width,
                  height: desktopLayout
                      ? MediaQuery.of(context).size.width * 0.5
                      : MediaQuery.of(context).size.height,
                  alignment: desktopLayout
                      ? Alignment.centerRight
                      : Alignment.bottomLeft,
                  margin: desktopLayout
                      ? EdgeInsets.symmetric(vertical: 40, horizontal: 64)
                      : EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                  child: SingleChildScrollView(
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: desktopLayout
                            ? MainAxisAlignment.center
                            : MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize:
                            desktopLayout ? MainAxisSize.min : MainAxisSize.max,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              desktopLayout
                                  ? 'Register'
                                  : 'Welcome To Mooncurse',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .headline6
                                      .color,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800),
                            ),
                          ),
                          SizedBox(height: desktopLayout ? 42 : 20),
                          phoneTextField(),
                          SizedBox(height: desktopLayout ? 42 : 20),
                          verifyButton(),
                          SizedBox(
                              height: desktopLayout
                                  ? 42
                                  : MediaQuery.of(context).size.height * 0.05),
                          Container(
                            alignment: Alignment.center,
                            child: Text('Or',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .headline6
                                        .color)),
                          ),
                          SizedBox(
                              height: desktopLayout
                                  ? 42
                                  : MediaQuery.of(context).size.height * 0.05),
                          googleButton(),
                          SizedBox(height: desktopLayout ? 42 : 20),
                          emailButton(),
                          SizedBox(
                              height: desktopLayout
                                  ? MediaQuery.of(context).size.height * 0.05
                                  : 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void verifyPhone(
      String phoneNo, String verificationId, bool sent, String code) {
    _authMethods
        .verifyPhone(phoneNo, verificationId, sent, code)
        .then((isUserNew) {
      setState(() {
        verifying = false;
        sending = true;
      });
      preformPhoneRegister();
    }).catchError((e) {
      setState(() {
        verifying = false;
      });
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext builder) {
            return errorDialog(e.message);
          });
    });
  }

  void preformPhoneRegister() {
    _authMethods.getCurrentUser().then((user) {
      if (user != null) {
        setState(() {
          confirming = true;
          sent = true;
        });

        authenticatePhoneUser(user);
      } else {
        print('there was an error');
        setState(() {
          confirming = false;
          sending = false;
        });
      }
    }).catchError((authErr) async {
      setState(() {
        confirming = false;
        sending = false;
      });
      showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext builder) {
            return errorDialog(authErr);
          });
    });
  }

  void preformRegister() {
    _authMethods.signIn().then((user) {
      if (user != null) {
        _authMethods.authanticateUser(user, googleUsername).then((isUserNew) {
          if (isUserNew) {
            print('THIS IS NEW USER $isUserNew');
            return showModalBottomSheet(
                context: context,
                isDismissible: false,
                builder: (BuildContext builder) {
                  return usernameSheet(user);
                });
          } else {
            setState(() {
              googleIsLoading = false;
            });
            // return Navigator.pushReplacementNamed(context, '/home');
          }
        });
      } else {
        print('there was an error');
        setState(() {
          googleIsLoading = false;
        });
        return showDialog(
            context: context,
            builder: (BuildContext builder) {
              return CustomDialog(
                title: 'Error..',
                content: Text(
                    user.toString() ?? 'There was an error due to cancellation',
                    style: Theme.of(context).textTheme.bodyText1),
                mainActionText: 'Try Again',
                function: () {},
                secondaryActionText: null,
                function1: null,
              );
            });
      }
    }).catchError((e) {
      print('Error was caught');
      setState(() {
        googleIsLoading = false;
      });
      return showModalBottomSheet(
          context: context,
          builder: (BuildContext builder) {
            return CustomDialog(
              title: 'Error..',
              content: Text(e.toString(),
                  style: Theme.of(context).textTheme.bodyText1),
              mainActionText: 'Try Again',
              function: () {},
              secondaryActionText: 'Create Account',
              function1: () {},
            );
          });
    });
  }

  errorDialog(authErr) async {
    return AlertDialog(
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Okay'),
        )
      ],
      content: Text(authErr.message.toString()),
      title: Text(
        'Oopps..',
        style: Theme.of(context).textTheme.headline6,
      ),
    );
  }

  Widget phoneTextField() {
    if (!sending) {
      return IntlPhoneField(
        showDropdownIcon: false,
        style: TextStyle(color: Theme.of(context).textTheme.bodyText1.color),
        countryCodeTextColor: Theme.of(context).textTheme.bodyText1.color,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          labelText: 'Enter phone number',
        ),
        onChanged: (value) {
          phoneNo = value.completeNumber.toString();
        },
        keyboardType: TextInputType.phone,
        validator: (valid) {
          if (valid.length == 10 && valid.contains(RegExp(r'[0-9]'))) {
            formKey.currentState.save();
            formKey.currentState.validate();
          }
        },
      );
    } else {
      return TextFormField(
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
          labelText: 'Enter verification code',
        ),
        onChanged: (value) {
          setState(() {
            code = value;
          });
        },
        initialValue: code,
      );
    }
  }

  Widget verifyButton() {
    if (!verifying) {
      return ElevatedButton(
        onPressed: () {
          if (!sending) {
            setState(() {
              verifying = true;
            });
            verifyPhone(phoneNo, verificationId, sent, code);
          } else {
            setState(() {
              verifying = false;
            });
          }
        },
        child: Text(
          !sending ? 'Verify' : 'Enter Code',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
      );
    } else {
      return ElevatedButton.icon(
        icon: const CircularProgressIndicator(
          backgroundColor: Colors.white,
          strokeWidth: 1,
        ),
        style: ElevatedButton.styleFrom(
          disabledBackgroundColor: Theme.of(context).buttonColor,
        ),
        label: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Text(
            !confirming ? 'Verifying...' : 'Confirmation...',
            style: const TextStyle(
                letterSpacing: 1.2, fontWeight: FontWeight.w800),
          ),
        ),
        onPressed: () => null,
      );
    }
  }

  Widget googleButton() {
    if (!googleIsLoading) {
      return ElevatedButton.icon(
        icon: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 10),
          child: Icon(
            FontAwesome5Brands.google,
            size: 20,
            color: Theme.of(context).accentIconTheme.color,
          ),
        ),
        label: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Text(
            'Google',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        onPressed: () {
          setState(() {
            googleIsLoading = true;
          });
          preformRegister();
        },
      );
    } else {
      return ElevatedButton.icon(
        icon: CircularProgressIndicator(
          backgroundColor: Theme.of(context).primaryColor,
          strokeWidth: 1,
        ),
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).buttonColor),
        label: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Text(
            'Google..',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        onPressed: null,
      );
    }
  }

  // Widget appleButton() {
  //   return RaisedButton.icon(
  //     icon: Padding(
  //       padding: const EdgeInsets.only(top: 16, bottom: 16, left: 10),
  //       child: Icon(FontAwesome5Brands.apple, size: 20),
  //     ),
  //     label: Padding(
  //       padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
  //       child: Text(
  //         'Apple',
  //         style: TextStyle(letterSpacing: 1.2, fontWeight: FontWeight.w800),
  //       ),
  //     ),
  //     onPressed: () => {},
  //   );
  // }

  Widget emailButton() {
    return ElevatedButton.icon(
        icon: Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 16, left: 10),
          child: Icon(
            Feather.mail,
            size: 20,
            color: Theme.of(context).accentIconTheme.color,
          ),
        ),
        label: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Text(
            'Email',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EmailSignUp(
                        desktopLayout: desktopLayout,
                      )));
        });
  }

  Widget googlUsernameEnterButton(auth.User user) {
    if (!googleEnteringUsername) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            googleEnteringUsername = true;
          });
          _firebaseMethods.addDataToDb(user, username).then((result) {
            if (result != null && result is! String) {
              setState(() {
                googleEnteringUsername = false;
              });
              return Navigator.pushReplacementNamed(context, '/home');
            } else {
              setState(() {
                googleEnteringUsername = false;
              });
              return showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialog(
                      title: 'Error..',
                      content: Text(result.toString(),
                          style: Theme.of(context).textTheme.bodyText2),
                      mainActionText: 'Try Again',
                      function: () {
                        //TODO: delete account and try sign up again
                      },
                      secondaryActionText: null,
                      function1: null,
                    );
                  });
            }
          });
        },
        child: Text('Enter', style: Theme.of(context).textTheme.bodyText2),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
      );
    } else {
      return ElevatedButton.icon(
          onPressed: () {},
          icon: const CircularProgressIndicator(
              backgroundColor: Colors.white, strokeWidth: 1),
          label: Text('Finishing up..',
              style: Theme.of(context).textTheme.bodyText2),
          style: ElevatedButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 32)));
    }
  }

  Widget userDetailsEnterButton(auth.User user) {
    if (!entringUserDetails) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            entringUserDetails = true;
          });
          _firebaseMethods.addDataToDb(user, username).then((value) {
            if (value != null && value is! String) {
              setState(() {
                entringUserDetails = false;
              });
              return Navigator.pushReplacementNamed(context, '/home');
            } else {
              setState(() {
                googleEnteringUsername = false;
              });
              return showDialog(
                  context: context,
                  builder: (context) {
                    return CustomDialog(
                      title: 'Error..',
                      content: Text(value.toString(),
                          style: Theme.of(context).textTheme.bodyText1),
                      mainActionText: 'Try Again',
                      function: () {
                        //TODO: delete account and try sign up again
                      },
                      secondaryActionText: null,
                      function1: null,
                    );
                  });
            }
          });
        },
        child: Text(
          'Enter',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32)),
      );
    } else {
      return ElevatedButton.icon(
        icon: const CircularProgressIndicator(
          backgroundColor: Colors.white,
          strokeWidth: 1,
        ),
        style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Theme.of(context).buttonColor),
        label: Padding(
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          child: Text(
            'Finishing up..',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ),
        onPressed: null,
      );
    }
  }

  Widget usernameSheet(auth.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 40),
          Text(
            'Provid Your Username',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            decoration: const InputDecoration(
              isDense: true,
              labelText: 'Enter your username',
            ),
            validator: (input) {
              return input.toLowerCase().trim().isEmpty
                  ? 'Enter a valid username'
                  : input = input;
            },
            onChanged: (value) => {
              googleUsername = value,
            },
          ),
          SizedBox(height: 20),
          googlUsernameEnterButton(user),
        ],
      ),
    );
  }

  Widget phoneSheet(auth.User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(height: 20),
        Text(
          'Provid Your User Details',
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40),
        TextFormField(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            labelText: 'Enter your username',
          ),
          validator: (input) {
            return input.toLowerCase().trim().isEmpty
                ? 'Enter a valid username'
                : input = input;
          },
          onChanged: (value) => {
            username = value,
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            labelText: 'Enter your name',
          ),
          validator: (input) {
            return input.toLowerCase().trim().isEmpty
                ? 'Enter a valid name'
                : input = input;
          },
          onChanged: (value) => {
            name = value,
          },
        ),
        TextFormField(
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 15),
            labelText: 'Enter your email',
          ),
          validator: (input) {
            return input.toLowerCase().trim().isEmpty && !input.contains('@')
                ? 'Enter a valid email'
                : input = input;
          },
          onChanged: (value) => {
            email = value,
          },
        ),
        SizedBox(height: 20),
        userDetailsEnterButton(user),
      ],
    );
  }

  /*void usernameExists(FirebaseUser user) {
    _firebaseRepository.usernameExists(user).then((exists) {
      if (exists) {
        
      } else {
        return 
      }
    });
  }*/
  void authenticatePhoneUser(auth.User user) {
    _authMethods.authanticatePhoneUser(user, username).then((isUserNew) {
      if (isUserNew) {
        setState(() {
          verifying = false;
        });
        showModalBottomSheet(
            context: context,
            isDismissible: false,
            builder: (BuildContext builder) {
              return phoneSheet(user);
            });
      } else {
        setState(() {
          verifying = false;
        });
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void authenticateUser(auth.User user) {}
}
