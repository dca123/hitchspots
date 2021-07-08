import 'package:flutter/material.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class SettingsCard extends StatelessWidget {
  const SettingsCard({
    Key? key,
  }) : super(key: key);

  Widget titleWidget(context) => Flexible(
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
                "Devinda Senanayake",
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
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
                  titleWidget(context),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text("Edit Profile"),
                          leading: Icon(Icons.manage_accounts),
                          onTap: () => {},
                        ),
                        ListTile(
                          title: Text("Offline Mode"),
                          leading: Icon(Icons.download_for_offline),
                          onTap: () => {},
                        ),
                        ListTile(
                          title: Text("About"),
                          leading: Icon(Icons.info),
                          onTap: () => {},
                        ),
                        ListTile(
                          title: Text("Logout"),
                          leading: Icon(Icons.logout),
                          enabled: false,
                          onTap: () {
                            Provider.of<AuthenticationState>(context,
                                    listen: false)
                                .logout();
                          },
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
