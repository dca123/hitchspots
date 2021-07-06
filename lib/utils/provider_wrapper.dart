import 'package:flutter/material.dart';
import 'package:hitchspots/models/location_card.dart';
import 'package:hitchspots/services/authentication.dart';
import 'package:provider/provider.dart';

class ProviderWrapper extends StatelessWidget {
  const ProviderWrapper({Key? key, required this.app}) : super(key: key);
  final Widget app;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LocationCardModel(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthenticationState(),
        ),
      ],
      child: app,
    );
  }
}
