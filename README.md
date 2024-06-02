# DiscoverNUS
Orbital Project for mobile AR app

## Introduction
Navigating a large campus like NUS can be daunting for visitors. Our Augmented Reality (AR) app will provide seamless navigation assistance, guiding users to key points of interest, facilities, amenities, and nearby attractions through intuitive AR markers and directional cues. Furthermore, by gamifying the campus exploration experience, we aim to make it more enjoyable and engaging for visitors. Users will embark on quests and challenges that encourage them to explore different parts of the campus while discovering interesting landmarks and hidden gems.

## Features
1. User login/authentication page (with email/Apple Id login)<br>
<br>
2. Single Player mode: <br>
Map (segment NUS into multiple segments) -> choose where you want to start <br>
Level system -> level up, you can unlock new segments <br>
Quests up to certain level (level 30) -> main quests <br>
Repetitive quests that show up (take photo of chicken) -> daily tasks <br>
Main UI: interactive map around NUS (mini profile at the top right corner + a circle emoji thingy to show where you at on the map) <br>
Profile can be expanded (click on it) -> show completed quests, exp/levels -> completed quests, exp, levels <br>
Settings to log out and to change profile (near the profile page) <br>
Seasonal quests <br>
Community quests (admin + user account) <br>
<br>
3. Multiplayer mode: (a button to enter from singleplayer map) <br>
Gain exp for completion <br>
Create/join party <br>
Games (Customisable quests and customisable games for people who are extremely hardcore): <br>
Adventure race (challenges -> start off with segments of NUS that are all uncaptured,  your team captures segments of NUS from those challenges, winner based on points) <br>
Mini quiz (matchmaking) - kahoot -> (e.g name the location based on the picture) <br>
Hide and seek (take turns to hide and seek, 10 minutes to choose hiding spot, afterwards hider cannot move within 50 metres radius, seeker can ask for hints to find where the hider is, however each hint reducesduces time from the seeker (2 minutes), 20 minutes time limit) <br>

## Tech Stack
Swift - Swift is the official language for macOS and iOS development. Due to the prevalence of iPhones among the NUS student population, we would like to develop our app to cater to the iOS community, which would benefit a large number of the student population, which is our target audience <br>
Firebase - Firebase is a real-time NoSQL database, which provides email/password authentication solutions, and is highly compatible with Swift. <br>
ARKit - ARKit is Apple's official augmented reality framework. By offerring motion tracking, object detection, and scene understanding features, and being highly compatible with swift, ARKit serves as our go-to augmented reality framework. <br>

## Documented Progress
Stage 1 (02/06/2024) - Finished account signup and login features on frontend, backend and in database.

## Installation
1. Open XCode
2. Click the run button on top left
