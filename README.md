# HitchSpots
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-yellow.svg)](https://conventionalcommits.org)
[![codecov](https://codecov.io/gh/dca123/hitchspots/branch/master/graph/badge.svg?token=kQp2CZw71w)](https://codecov.io/gh/dca123/hitchspots)
[Download on Google Play](https://play.google.com/store/apps/details?id=com.hitchspots&hl=en_US&gl=US)

# Problem

When I started hitchhiking, I learnt everything through reading up on [hitchwiki.org](https://hitchwiki.org/en/Main_Page). It used to have a really cool function, a map that users all around the world could contribute to. When I started out, this was an amazing resource but at the time, I wasn't able to submit locations. Fast forward to today, it seems that the map itself is not functional. The page is broken and you cannot see any links. However, I was able to retrieve a datadump of the entire hitchwiki maps project containing over 20 000 locations.

# Solution

I've been looking for a reason to get into mobile development and also to checkout flutter. This is that. Here I'll try to give back to the hitchhiking community in name of the countless travellers, vagabonds I've met & most importantly the amazing folks that gave a stranger a lift along the road. Using Firebase as a backend service, this app shows all hitchhiking spots in the visible radius of your device. Due to server limits, I've hard limited the amount of queries as you zoom out. If you sign up with this app, you can also contribute by adding new locations and reviews. The reviews rate locations on a scale of 1 to 5 and the average of these ratings determine the color of the marker on the map.

# Notes

I'm not looking to monetize this project but if I run into extreme server costs, I might just have to throw some ads in. Let's hope we don't get to that

# Technologies

- [Flutter](flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Figma for wireframing](https://www.figma.com/file/hNgH2qIOakEKw8kp2Z8uur/HitchApp?node-id=2%3A5814) - [Demo](https://www.figma.com/file/hNgH2qIOakEKw8kp2Z8uur/HitchApp?node-id=2%3A5814)

Remake of the now broken hitchwiki.com/maps as a mobile app. Designed with Figma and developed with Flutter. 

## Post Clone
- android/google-services.json (Firebase Configuration)
- android/local.properties (MAPS_API_KEY after building)

## Features
- Add hitching spots
- Review and rate hitching spots
- View nearby hitchiking spots

## Dependencies 
- [animations](https://pub.dev/packages/animations)
- [auto_size_text](https://pub.dev/packages/auto_size_text)
- [cloud_firestore](https://pub.dev/packages/cloud_firestore)
- [cupertino_icons](https://pub.dev/packages/cupertino_icons)
- [dio](https://pub.dev/packages/dio)
- [firebase_analytics](https://pub.dev/packages/firebase_analytics)
- [firebase_auth](https://pub.dev/packages/firebase_auth)
- [firebase_crashlytics](https://pub.dev/packages/firebase_crashlytics)
- [firebase_storage](https://pub.dev/packages/firebase_storage)
- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv)
- [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- [flutter_rating_bar](https://pub.dev/packages/flutter_rating_bar)
- [flutter_spinkit](https://pub.dev/packages/flutter_spinkit)
- [geocoding](https://pub.dev/packages/geocoding)
- [geoflutterfire2](https://pub.dev/packages/geoflutterfire2)
- [google_maps_cluster_manager](https://pub.dev/packages/google_maps_cluster_manager)
- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
- [google_sign_in](https://pub.dev/packages/google_sign_in)
- [http](https://pub.dev/packages/http)
- [introduction_screen](https://pub.dev/packages/introduction_screen)
- [location](https://pub.dev/packages/location)
- [material_floating_search_bar](https://pub.dev/packages/material_floating_search_bar)
- [path_provider](https://pub.dev/packages/path_provider)
- [permission_handler](https://pub.dev/packages/permission_handler)
- [provider](https://pub.dev/packages/provider)
- [shared_preferences](https://pub.dev/packages/shared_preferences)
- [sliding_up_panel](https://pub.dev/packages/sliding_up_panel)
- [timeago](https://pub.dev/packages/timeago)
- [flutter_markdown](https://pub.dev/packages/flutter_markdown)
- [url_launcher](https://pub.dev/packages/url_launcher)

## Dev Dependencies
- [flutter_driver](https://pub.dev/flutter_driver)
- [flutter_test](https://pub.dev/flutter_test)
- [integration_test](https://pub.dev/integration_test)
- [build_runner](https://pub.dev/build_runner)
- [device_preview](https://pub.dev/device_preview)
- [fake_cloud_firestore](https://pub.dev/fake_cloud_firestore)
- [firebase_auth_mocks](https://pub.dev/firebase_auth_mocks)
- [flutter_launcher_icons](https://pub.dev/flutter_launcher_icons)
- [flutter_lints](https://pub.dev/flutter_lints)
- [google_sign_in_mocks](https://pub.dev/google_sign_in_mocks)
- [lint](https://pub.dev/lint)
- [mockito](https://pub.dev/mockito)

## Contributing

- Please use the [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) specification make commits.  There is a vscode extension called conventional commits that makes this super easy

## Screencaps

<img src="https://user-images.githubusercontent.com/3579142/124671676-76f27900-ded3-11eb-811d-0e50492a4acc.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671689-7ce85a00-ded3-11eb-9b07-de56c2ffaf2b.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671780-a0130980-ded3-11eb-9bf8-d6dd7c87f361.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671653-6e01a780-ded3-11eb-98f1-8608f6322e62.png" width="250" >

### Made with my Keyboard

