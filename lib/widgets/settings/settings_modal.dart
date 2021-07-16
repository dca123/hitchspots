import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:hitchspots/pages/edit_profile_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:hitchspots/utils/show_dialog.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsCard extends StatefulWidget {
  const SettingsCard({
    Key? key,
  }) : super(key: key);

  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  @override
  Widget build(BuildContext context) {
    String displayName =
        Provider.of<AuthenticationState>(context, listen: false).displayName ??
            "";
    bool isLoggedIn =
        Provider.of<AuthenticationState>(context, listen: false).loginState ==
            LoginState.loggedIn;
    return Center(
      child: Card(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                UserDisplayTitle(
                  displayName: displayName,
                  isLoggedIn: isLoggedIn,
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Row(children: [
                        Flexible(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "User Settings",
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                        Expanded(child: Divider()),
                      ]),
                      OpenContainerListTile(
                        title: "Edit Profile",
                        icon: Icon(Icons.manage_accounts),
                        openPage: EditProfilePage(),
                        isLoggedIn: isLoggedIn,
                      ),
                      LoginTile(),
                      Divider(),
                      // ListTile(
                      //   title: Text("Offline Mode"),
                      //   leading: Icon(Icons.download_for_offline),
                      //   enabled: false,
                      //   onTap: () => {},
                      // ),
                      OpenContainerListTile(
                        title: "About",
                        icon: Icon(Icons.info),
                        openPage: AboutPage(),
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

class LoginTile extends StatefulWidget {
  const LoginTile({Key? key}) : super(key: key);

  @override
  _LoginTileState createState() => _LoginTileState();
}

class _LoginTileState extends State<LoginTile> {
  static late double iconSize;

  void logout() async {
    setState(() {
      Provider.of<AuthenticationState>(context, listen: false).logout();
    });
    await showAlertDialog(
      title: "Logout",
      body: "You've been succesfully logged out",
      context: context,
    );
    Navigator.of(context).pop();
  }

  void login() async {
    await Provider.of<AuthenticationState>(context, listen: false)
        .loginFlowWithAction(
      postLogin: () async {
        await showAlertDialog(
          title: "Login",
          body: "You've been succesfully logged in",
          context: context,
        );
        Navigator.pop(context);
      },
      buildContext: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    iconSize = IconTheme.of(context).size! - 5;
    return Consumer<AuthenticationState>(
      builder: (context, authState, child) {
        if (authState.loginState == LoginState.loggedIn) {
          return ListTile(
            title: Text("Logout"),
            leading: Icon(Icons.logout),
            onTap: logout,
          );
        }
        if (authState.isAuthenticating) {
          return ListTile(
            title: Text("Logging In"),
            leading: SizedBox(
              height: iconSize,
              width: iconSize,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          );
        }
        return ListTile(
          title: Text("Login"),
          leading: Icon(Icons.login),
          onTap: login,
        );
      },
    );
  }
}

class UserDisplayTitle extends StatelessWidget {
  const UserDisplayTitle({
    Key? key,
    required this.displayName,
    required this.isLoggedIn,
  }) : super(key: key);

  final String displayName;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) => Flexible(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                "Settings",
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            if (isLoggedIn)
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  displayName,
                  style: Theme.of(context).textTheme.subtitle1,
                ),
              ),
          ],
        ),
      );
}

class OpenContainerListTile extends StatelessWidget {
  const OpenContainerListTile({
    Key? key,
    this.isLoggedIn = true,
    required this.title,
    required this.openPage,
    required this.icon,
  }) : super(key: key);

  final bool isLoggedIn;
  final String title;
  final Widget openPage;
  final Icon icon;
  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      middleColor: Theme.of(context).cardColor,
      tappable: false,
      closedBuilder: (context, openContainer) {
        return LoginToolTipOnLogout(
            isLoggedIn: isLoggedIn,
            child: ListTile(
              title: Text(title),
              leading: icon,
              enabled: isLoggedIn,
              onTap: () {
                openContainer();
              },
            ));
      },
      openBuilder: (context, closeContainer) {
        return openPage;
      },
    );
  }
}

class LoginToolTipOnLogout extends StatelessWidget {
  const LoginToolTipOnLogout({
    Key? key,
    required this.child,
    required this.isLoggedIn,
  }) : super(key: key);

  final Widget child;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn) {
      return child;
    } else {
      return Tooltip(
        message: "You have to be logged in",
        child: child,
      );
    }
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).canvasColor,
          elevation: 0,
          toolbarHeight: 84,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
            color: Colors.black,
          ),
          title: Text(
            "About",
            style: Theme.of(context).textTheme.headline6,
          ),
          centerTitle: true,
          actions: [],
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Credits",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w100,
                  ),
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: FutureBuilder<String>(
                      future: DefaultAssetBundle.of(context)
                          .loadString("assets/credits/attribution.md"),
                      initialData: "",
                      builder: (BuildContext context, snapshot) {
                        return MarkdownBody(
                          data: snapshot.data!,
                          onTapLink: (
                            _,
                            String? url,
                            __,
                          ) async {
                            await canLaunch(url!)
                                ? await launch(url)
                                : throw 'Could not launch $url';
                          },
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                Text("From the Developer",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w100,
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: FutureBuilder<String>(
                    future: DefaultAssetBundle.of(context)
                        .loadString("assets/credits/from_the_developer.md"),
                    initialData: "",
                    builder: (BuildContext context, snapshot) {
                      return MarkdownBody(data: snapshot.data!);
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
