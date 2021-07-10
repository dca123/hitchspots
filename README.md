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


## Contributing

- Please use the [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/) specification make commits.  There is a vscode extension called conventional commits that makes this super easy

## Screencaps

<img src="https://user-images.githubusercontent.com/3579142/124671676-76f27900-ded3-11eb-811d-0e50492a4acc.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671689-7ce85a00-ded3-11eb-9b07-de56c2ffaf2b.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671780-a0130980-ded3-11eb-9bf8-d6dd7c87f361.png" width="250" >
<img src="https://user-images.githubusercontent.com/3579142/124671653-6e01a780-ded3-11eb-98f1-8608f6322e62.png" width="250" >

### Made with my Keyboard

