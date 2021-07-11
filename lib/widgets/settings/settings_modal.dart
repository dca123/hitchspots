import 'package:flutter/material.dart';
import 'package:hitchspots/pages/edit_profile_page.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatefulWidget {
  const SettingsCard({
    Key? key,
  }) : super(key: key);

  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  Widget titleWidget(context, displayName) => Flexible(
        flex: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                "Settings",
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Flexible(
              fit: FlexFit.tight,
              child: Text(
                displayName,
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      );

  Widget loginToolipIfLoggedOut(
      {required Widget child, required bool isLoggedIn}) {
    if (isLoggedIn) {
      return child;
    } else {
      return Tooltip(
        message: "You have to be logged in",
        child: child,
      );
    }
  }

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
          height: MediaQuery.of(context).size.height * 0.50,
          width: MediaQuery.of(context).size.width * 0.75,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  titleWidget(context, displayName),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        loginToolipIfLoggedOut(
                          isLoggedIn: isLoggedIn,
                          child: ListTile(
                            title: Text("Edit Profile"),
                            leading: Icon(Icons.manage_accounts),
                            enabled: isLoggedIn,
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (BuildContext buildContext) {
                                return EditProfilePage();
                              }));
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("Offline Mode"),
                          leading: Icon(Icons.download_for_offline),
                          enabled: false,
                          onTap: () => {},
                        ),
                        ListTile(
                          title: Text("About"),
                          leading: Icon(Icons.info),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (BuildContext buildContext) {
                              return AboutPage();
                            }));
                          },
                        ),
                        loginToolipIfLoggedOut(
                          isLoggedIn: isLoggedIn,
                          child: ListTile(
                            title: Text("Logout"),
                            leading: Icon(Icons.logout),
                            enabled: isLoggedIn,
                            onTap: () {
                              setState(() {
                                Provider.of<AuthenticationState>(context,
                                        listen: false)
                                    .logout();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
          ),
        ),
      ),
    );
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
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
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
                Text(
                  "Credits & Attributions",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w100,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: 8),
                //TODO : Add relevant text here
                Text("""
                Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Dui id ornare arcu odio. Pharetra diam sit amet nisl suscipit adipiscing bibendum est. Leo duis ut diam quam nulla. Tincidunt lobortis feugiat vivamus at augue eget. Faucibus vitae aliquet nec ullamcorper. Donec ac odio tempor orci dapibus ultrices. Faucibus a pellentesque sit amet porttitor eget dolor morbi non. Nunc sed blandit libero volutpat sed cras ornare arcu. Cursus risus at ultrices mi tempus imperdiet. Feugiat nisl pretium fusce id velit ut. Habitasse platea dictumst vestibulum rhoncus est pellentesque elit ullamcorper. Ipsum dolor sit amet consectetur adipiscing elit pellentesque habitant. Orci phasellus egestas tellus rutrum.
                """),
                Text("From the Developer",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w100,
                    )),
                Text("""
                Lectus nulla at volutpat diam ut venenatis tellus. Pulvinar mattis nunc sed blandit libero volutpat sed cras. At varius vel pharetra vel turpis nunc eget. Mauris a diam maecenas sed enim ut sem viverra. Maecenas accumsan lacus vel facilisis volutpat est velit egestas dui. Volutpat est velit egestas dui id. Elementum sagittis vitae et leo duis ut diam. Vel turpis nunc eget lorem dolor. Donec pretium vulputate sapien nec sagittis aliquam malesuada. Augue eget arcu dictum varius duis at. Arcu bibendum at varius vel pharetra vel turpis nunc eget. Ac turpis egestas integer eget aliquet nibh praesent tristique. Urna porttitor rhoncus dolor purus non enim. Rhoncus aenean vel elit scelerisque mauris pellentesque pulvinar pellentesque. At lectus urna duis convallis convallis tellus id interdum.
                """),
              ],
            ),
          ),
        ),
      );
    });
  }
}
