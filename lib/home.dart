import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:howl/enum/user_state.dart';
import 'package:howl/models/user.dart';
import 'package:howl/pages/calls_page.dart';
import 'package:howl/pages/chats_page.dart';
import 'package:howl/pages/messages_page.dart';
import 'package:howl/pages/profile_page.dart';
import 'package:howl/pages/search_page.dart';
import 'package:howl/providers/user_provider.dart';

import 'package:howl/resources/firebase_methods.dart';
import 'package:howl/resources/auth_methods.dart';
import 'package:howl/utils/constants.dart';
import 'package:howl/widgets/cached_image.dart';
import 'package:howl/widgets/custom_dialog.dart';
import 'package:howl/widgets/user_circle.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  PageController pageController;
  UserProvider userProvider;
  FirebaseMethods _firebaseMethods = FirebaseMethods();
  AuthMethods _authMethods = AuthMethods();
  int page = 0;

  bool googleEnteringUsername = false, entringUserDetails = false;

  String username;
  String name;
  String googleUsername;
  String email;

  bool desktopLayout = false;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((value) {
      _authMethods.userExists(value).then((isUserNew) {
        if (isUserNew) {
          return showModalBottomSheet(
              context: context,
              builder: (context) {
                return usernameSheet(value);
              });
        }
      });
    });

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.refreshUser();
      _authMethods.setUserState(
          userId: userProvider.getUser.id, userState: UserState.Online);
    });
    WidgetsBinding.instance.addObserver(this);

    pageController = PageController(initialPage: page);
  }

  googlUsernameEnterButton(auth.User user) async {
    if (!googleEnteringUsername) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            googleEnteringUsername = true;
          });
          _firebaseMethods.addDataToDb(user, googleUsername).then((result) {
            if (result != null && result is! String) {
              setState(() {
                googleEnteringUsername = false;
              });
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: Text('Enter', style: Theme.of(context).textTheme.bodyText2),
        ),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () {},
        icon: CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor, strokeWidth: 1),
        label: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
            child: Text('Finishing up..',
                style: Theme.of(context).textTheme.bodyText2),
          ),
        ),
      );
    }
  }

  Widget usernameSheet(auth.User user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 20),
          Text(
            'Provid Your Username',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          TextFormField(
            decoration: InputDecoration(
                isDense: true,
                hintText: 'Enter your username',
                prefixIcon: Icon(
                  Feather.user,
                  color: Theme.of(context).primaryIconTheme.color,
                )),
            validator: (input) {
              return input.toLowerCase().trim().isEmpty
                  ? 'Enter a valid username'
                  : input = input;
            },
            onChanged: (value) {
              googleUsername = value;
            },
          ),
          const SizedBox(height: 20),
          googlUsernameEnterButton(user),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        (userProvider != null && userProvider.getUser != null)
            ? userProvider.getUser.id
            : "";
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Online)
            : print('resumedState');
        break;
      case AppLifecycleState.inactive:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Offline)
            : print('offline');
        break;
      case AppLifecycleState.paused:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print('pausedState');
        break;
      case AppLifecycleState.detached:
        currentUserId != null
            ? _authMethods.setUserState(
                userId: currentUserId, userState: UserState.Waiting)
            : print('detatched');
        break;
    }
  }

  void jumToCamera() {
    pageController.animateToPage(0,
        duration: const Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  void jumpToChat() {
    pageController.animateToPage(1,
        duration: Duration(milliseconds: 400), curve: Curves.bounceInOut);
  }

  void onPageChanged(int selectedPage) {
    setState(() {
      page = selectedPage;
    });
  }

  List<User> userList = [];

  @override
  Widget build(BuildContext context) {
    final User homeUserProvider = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Text('Mooncurse',
                    style: Theme.of(context).textTheme.headline5),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: GestureDetector(
                  onTap: () {
                    userList.add(homeUserProvider);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfilePage(
                                contact: userList,
                                group: false,
                                userProvider: homeUserProvider)));
                  },
                  onLongPress: () => accountSheet(homeUserProvider),
                  child: UserCircle(
                      width: 40,
                      height: 40,
                      child: CachedImage(homeUserProvider?.profileUrl)),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        onTap: (index) {
          setState(() {
            page = index;
            pageController.jumpToPage(page);
          });
        },
        currentIndex: page,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Feather.message_circle,
            ),
            activeIcon: Icon(
              Feather.message_circle,
            ),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Feather.video,
              ),
              activeIcon: Icon(
                Feather.video,
              ),
              label: 'Calls'),
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        if (MediaQuery.of(context).size.width > 600) {
          desktopLayout = true;
        } else {
          desktopLayout = false;
        }
        if (desktopLayout) {
          return Row(
            children: [
              NavigationRail(
                destinations: [
                  NavigationRailDestination(
                      icon: Icon(
                        Feather.message_circle,
                      ),
                      selectedIcon: Icon(
                        Feather.message_circle,
                      ),
                      label: null),
                  NavigationRailDestination(
                    icon: Icon(
                      Feather.video,
                    ),
                    selectedIcon: Icon(
                      Feather.video,
                    ),
                    label: null,
                  ),
                ],
                onDestinationSelected: onPageChanged,
                selectedIndex: page,
              ),
              VerticalDivider(thickness: 1, width: 1),
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: ChatsPage(),
              )),
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: MessagesPage(),
              )),
              Expanded(
                  child: Container(
                width: MediaQuery.of(context).size.width * 0.1,
                child: ProfilePage(),
              )),
            ],
          );
        } else {
          return Column(
            children: [
              searchBox(homeUserProvider),
              Expanded(
                child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: onPageChanged,
                    controller: pageController,
                    children: [
                      ChatsPage(jumpToCamera: jumToCamera),
                      CallsPage(userProvider: userProvider)
                    ]),
              ),
            ],
          );
        }
      }),
    );
  }

  accountSheet(User userProvider) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    label: Text(
                      'Add Account',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                    icon: Icon(
                      Feather.plus,
                      color: Theme.of(context).primaryIconTheme.color,
                    ),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: userProvider.id == userProvider.id
                                ? Theme.of(context).accentColor
                                : Colors.transparent,
                            width: 1)),
                    child: CircleAvatar(
                        radius: 24,
                        backgroundImage: userProvider.profileUrl != null
                            ? CachedNetworkImageProvider(
                                userProvider?.profileUrl)
                            : CachedNetworkImageProvider(imageNotAvailable)),
                  ),
                  title: Text(userProvider.username,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          .apply(fontSizeFactor: 1.3)),
                  subtitle: Text(userProvider.name,
                      style: Theme.of(context).textTheme.bodyText1),
                ),
              ],
            ),
          );
        });
  }

  Widget searchBox(User userProvider) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: GestureDetector(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => SearchPage(userProvider: userProvider))),
        child: TextFormField(
          style: Theme.of(context).textTheme.bodyText1,
          textInputAction: TextInputAction.search,
          autofocus: false,
          enabled: false,
          decoration: InputDecoration(
            alignLabelWithHint: true,
            hintText: 'Search..',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            isDense: true,
            prefixIcon: Icon(Feather.search,
                color: Theme.of(context).primaryIconTheme.color),
          ),
        ),
      ),
    );
  }
}
