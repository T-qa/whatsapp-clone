# Flutter Whatsapp Clone

Create a comprehensive Whatsapp clone using Flutter, Firebase, and Riverpod 2.0.

## Feature

- [X] Phone Number Authentication
- [X] 1-1 Chatting with Contacts Only
- [X] Group Chatting
- [X] Text, Image, GIF, Audio(Recording), Video & Emoji Sending Messages
- [X] Status Visible to Contacts Only and Disappears after 24 hours
- [X] Online/Offline Status
- [X] Seen Message
- [X] Replying to Messages
- [X] Auto Scroll on New Messages


## Technology
1. Firebase Firestore<br />
- Used for real-time data storage and synchronization
2. Firebase Authentication<br />
- Handles user authentication and phone number verification
3. Firebase Storage<br />
- Stores media files such as images, videos, and audio recordings.
4. Flutter Riverpod<br />
- A Flutter library used for dependency injection and state management.


## Folder Structure
- lib
  - common
    - enums
    - providers
    - repositories
    - utils
    - widgets
  - features
    - auth
      - controllers
      - repositories
      - screens
    - chat
      - controllers
      - repositories
      - screens
      - widgets
    - contacts
      - controllers
      - repositories
      - screens
    - group
      - controllers
      - repositories
      - screens
      - widgets
    - status
      - controllers
      - repositories
      - screens
  - models
  - screens
  - routes

## Screenshots

## Dependencies
  - country_picker
  - file_picker
  - image_picker
  - flutter_contacts
  - uuid
  - intl
  - cached_network_image
  - video_player
  - emoji_picker_flutter
  - enough_giphy_flutter
  - flutter_sound
  - permission_handler
  - path_provider
  - audioplayers
  - swipe_to
  - story_view

## Getting Started
Follow the steps below to get started with the Flutter Whatsapp Clone project:

1. Clone the repository:
```bash
git clone https://github.com/T-qa/whatsapp-clone
```
2. Navigate to the project directory:
```bash
cd flutter-whatsapp-clone
```
3. Install the dependencies:
```bash
flutter pub get
```
4. Run the app:
```bash
flutter run
```
Make sure you have Flutter SDK installed and set up on your machine before running the app.








