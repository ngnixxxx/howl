import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/main.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/blocked_page.dart';
import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/widgets/custom_dialog.dart';

class Settings extends StatefulWidget {
  final User user;

  const Settings({this.user});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  int selectedSetting = 0;
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  bool isOnline = false;

  bool private = false;
  @override
  void initState() {
    private = widget.user.private;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    switch (selectedSetting) {
      case 0:
        return settingsList();
      case 1:
        return accountList();
      case 2:
        return notificationsList();
      case 3:
        return privacyList();
      case 4:
        return helpList();
      case 5:
        return aboutList();
      default:
        return settingsList();
    }
  }

  Widget _listTileIcon(IconData icon) => Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(
          icon,
          color: Theme.of(context).primaryIconTheme.color,
        ),
      );
  Widget settingsList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Settings',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Icon(Feather.x_circle,
                        color: Theme.of(context).primaryIconTheme.color),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
            ListTile(
              leading: _listTileIcon(Feather.user),
              title: Text(
                'Account',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                setState(() {
                  selectedSetting = 1;
                });
              },
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.bell),
              title: Text(
                'Notifications',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                setState(() {
                  selectedSetting = 2;
                });
              },
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.lock),
              title: Text(
                'Privacy',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                setState(() {
                  selectedSetting = 3;
                });
              },
            ),
            ListTile(
              leading: _listTileIcon(Feather.help_circle),
              title: Text(
                'Help & Feedback',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                setState(() {
                  selectedSetting = 4;
                });
              },
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.info),
              title: Text(
                'About',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                setState(() {
                  selectedSetting = 5;
                });
              },
              enabled: true,
            ),
          ]),
    );
  }

  Widget accountList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Account',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                  padding: const EdgeInsets.all(20),
                  icon: Icon(Feather.arrow_left_circle,
                      color: Theme.of(context).primaryIconTheme.color),
                  onPressed: () {
                    setState(() {
                      selectedSetting = 0;
                    });
                  },
                ),
              ],
            ),
            ListTile(
              leading: _listTileIcon(Feather.slash),
              title: Text(
                'Blocked Users',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            BlockedPage(userProvider: widget.user)));
              },
            ),
            ListTile(
              leading: _listTileIcon(Feather.volume_x),
              title: Text(
                'Muted Users',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.lock),
              title: Text(
                'Change Password',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: _listTileIcon(Feather.smartphone),
              title: Text(
                'Devices',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.user_minus),
              title: Text(
                'Deactivate Account',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
            ),
            ListTile(
                leading: _listTileIcon(Feather.user_x),
                title: Text(
                  'Delete Account',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                onTap: () {}),
          ]),
    );
  }

  Widget notificationsList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Notifications',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Icon(Feather.arrow_left_circle,
                        color: Theme.of(context).primaryIconTheme.color),
                    onPressed: () {
                      setState(() {
                        selectedSetting = 0;
                      });
                    }),
              ],
            ),
            ListTile(
              leading: _listTileIcon(Feather.mail),
              title: Text(
                'Email',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
            ),
            ListTile(
              leading: _listTileIcon(Feather.smartphone),
              title: Text(
                'Phone',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
              enabled: true,
            ),
            ListTile(
              leading: _listTileIcon(Feather.bell),
              title: Text(
                'Push notifications',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              onTap: () {},
              enabled: true,
            ),
          ]),
    );
  }

  Widget privacyList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Privacy',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                  padding: const EdgeInsets.all(20),
                  icon: Icon(Feather.arrow_left_circle,
                      color: Theme.of(context).primaryIconTheme.color),
                  onPressed: () {
                    setState(() {
                      selectedSetting = 0;
                    });
                  },
                ),
              ],
            ),
            ListTile(
              title: Text(
                'Status',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              leading: Stack(
                children: <Widget>[
                  _listTileIcon(Feather.circle),
                  Positioned(
                    bottom: 11,
                    right: 11,
                    child: MyApp.onlineCircle,
                  ),
                ],
              ),
              subtitle: Text(
                'Online Status is : ON',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              trailing: Switch(
                value: isOnline,
                onChanged: (bool value) {
                  setState(() {
                    value = isOnline;
                  });
                },
              ),
            ),
            ListTile(
              title: Text(
                'Account Privacy',
                style: Theme.of(context).textTheme.bodyText1,
              ),
              leading: _listTileIcon(Feather.key),
              trailing: TextButton(
                child: Text(
                  private ? 'Private' : 'Public',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                onPressed: () {
                  if (private) {
                    return showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return CustomDialog(
                            title: 'Account Privacy',
                            content: Text(
                              'Anyone requesting to follow will follow you automatically, applies to Suncurse as well',
                              style: Theme.of(context).textTheme.bodyText1,
                            ),
                            function: () {
                              _firebaseMethods.updatePrivacy(
                                  widget.user, false);
                              setState(() {
                                widget.user.private = false;
                              });
                              Navigator.pop(context);
                            },
                            function1: () {
                              Navigator.pop(context);
                            },
                            mainActionText: 'Make Public',
                            secondaryActionText: 'Cancel',
                          );
                        });
                  } else {
                    _firebaseMethods.updatePrivacy(widget.user, true);
                    setState(() {
                      widget.user.private = true;
                    });
                  }
                },
              ),
            ),
          ]),
    );
  }

  Widget helpList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('Help & Feedback',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Icon(Feather.arrow_left_circle,
                        color: Theme.of(context).primaryIconTheme.color),
                    onPressed: () {
                      setState(() {
                        selectedSetting = 0;
                      });
                    }),
              ],
            ),
          ]),
    );
  }

  Widget aboutList() {
    return SingleChildScrollView(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text('About',
                        style: Theme.of(context).textTheme.headline5)),
                IconButton(
                    padding: const EdgeInsets.all(20),
                    icon: Icon(Feather.arrow_left_circle,
                        color: Theme.of(context).primaryIconTheme.color),
                    onPressed: () {
                      setState(() {
                        selectedSetting = 0;
                      });
                    }),
              ],
            ),
          ]),
    );
  }
}
