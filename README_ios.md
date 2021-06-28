# Documentation for HitchSpots iOS development

Ideally, when developing for iOS, like with Android, simply using the run command (F5 on vscode) should get the app up and started. However, since I had no way of developing for iOS, I never bothered with the specific setups required for iOS. This document will hopefully explain all that is required to get the app working on iOS.

## General Requirements

To get this project started running two items are required. One is a firebase configuration file and the second is a google maps API key. 
- [This](https://developers.google.com/maps/documentation/embed/get-api-key) should explain how to create an API key. This will be later used with the google maps plugin.
- The Firebase configuration file is specific to the project. This is used in storing data and the authentication flow. You can create your firebase project [here](https://firebase.google.com/) that provides you with your configuration file.
- Firebase and its sub-features such as authentication & storage is managed by the package [FlutterFire](https://firebase.flutter.dev/)
- Note: When it comes to releasing, I can provide the Firebase configuration file such that both iOS and Android apps use the same database.

Remember - **DO NOT COMMIT YOUR GOOGLE MAPS API KEY OR THE CONFIGURATION FILE TO THE REPO**
Pro tip - If you're asked to setup a billing account for the google console, remember [to add a budget](https://cloud.google.com/billing/docs/how-to/budgets) of $0 to the project so that you won't be charged in any edge case, whatsoever. 


## Language and Framework

Flutter is the core framework used in this project. The Flutter SDK is a UI toolkit by Google that allows for cross-platform apps and it shines in developing native android and ios apps. The language used by Flutter is Dart. It's a simple language and if you know JavaScript you should feel at home using it. 

I recommend looking at the [Dart language tour](https://dart.dev/guides/language/language-tour) which provides a shallow dive into the tools provided in dart. What I like about Flutter is that Google has put in a lot of work for really good documentation. Almost everything I learned about flutter has been direct via [flutter.dev](https://flutter.dev/) which I recoPc
### Extra Flutter Notes

If you too learn by doing like me, here are the resources I used from flutter.dev to create this project. I recommend checking these out since these two projects will also show how add your API key and firebase configuration to the project. 

- [Firebase + Flutter](https://firebase.google.com/codelabs/firebase-get-to-know-flutter)
- [Google Maps + Flutter](https://codelabs.developers.google.com/codelabs/google-maps-in-flutter#0)


## Per Dependency Requirements

While this project also has multiple dependencies, most will automatically integrate with ios and android app. However, some such as firebase and google maps as we just saw need to be manually configured by being added specific lines of code in the ios folder. These packages are those which have per platform changes. 

- [FlutterFire](https://firebase.flutter.dev/docs/installation/ios)
- [Google Maps](https://pub.dev/packages/google_maps_flutter)
- [Firebase crashlytics](https://firebase.flutter.dev/docs/crashlytics/overview/)
- [Google Sign in](https://pub.dev/packages/google_sign_in)
- [Location](https://pub.dev/packages/location)
- [Permission Handler](https://pub.dev/packages/permission_handler)