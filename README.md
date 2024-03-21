## OVERVIEW

RelatedChat is an open-source alternative communication platform. Both iOS (Swift), Android (React Native), and Web (React) version source codes are available.

<img src="https://rel.codes/messenger/web1.png" width="880">

<img src="https://rel.codes/messenger/android1.png" width="880">

## NEW FEATURES

- Updated iOS (Swift) codebase
- New Android (React Native) version
- New Desktop browser (React) version
- Single backend server (using [GraphQLite](https://graphqlite.com))

<img src="https://rel.codes/messenger/ios11.png" width="880">

## FEATURES

- Direct chat functionality
- Channel chat functionality
- Sending text messages
- Sending emoji messages
- Sending photo messages
- Sending video messages
- Sending audio messages
- Sending stickers
- Sending GIF messages
- Media file local cache
- Media message re-download option
- Media download network settings (Wi-Fi, Cellular or Manual)
- Cache settings for media messages (automatic/manual cleanup)
- Typing indicator
- Load earlier messages
- Message delivery receipt
- Message read receipt
- Arbitrary message sizes
- Send/Receive sound effects
- Copy and paste text messages
- Video length limit possibility
- Save photo messages to device
- Save video messages to device
- Realtime conversation view for ongoing chats
- All media view for chat media files
- Picture view for multiple pictures
- Basic Settings view included
- Basic Profile view for users
- Edit Profile view for changing user details
- Sign in with Email
- Privacy Policy view
- Terms of Service view
- Full source code is available
- No backend programming is needed
- Native and easy to customize user interface
- Supports native iOS Dark Mode
- Supported devices: iPhone SE - iPhone 13 Pro Max

<img src="https://rel.codes/messenger/ios12.png" width="880">
<img src="https://rel.codes/messenger/ios13.png" width="880">

## INSTALLATION (iOS)

**1.,** Create some test users by using a demo server.

**2.,** Open the `app.xcodeproj` from Xcode and select Product/Run (⌘ R).

## INSTALLATION (Android)

**1.,** Setup Gradle variables by following the [official docs](https://reactnative.dev/docs/signed-apk-android#setting-up-gradle-variables).

**2.,** Open a terminal and run `npm start`.

**3.,** Open another terminal and run `npx react-native run-android --variant=release`.

> For a complete guide on how to publish and run your React Native app, please refer to the [official docs](https://reactnative.dev/docs/signed-apk-android).

## INSTALLATION (Web)

You can install RelatedChat on any servers (Windows, Linux or macOS), by using Docker. Just download the Docker Compose file to your computer and initiate the process.

```
curl -o docker-compose.yml https://rel.codes/messenger/docker-compose.yml

docker compose up -d
```

Make sure to change all the sensitive values in your YAML file before building your server.

```yaml
environment:
  DB_HOST: pg
  DB_PORT: 5432
  DB_DATABASE: gqlserver
  DB_USER: gqlserver
  DB_PASSWORD: gqlserver

  CACHE_HOST: rd
  CACHE_PORT: 6379
  CACHE_PASSWORD: gqlserver

  MINIO_ROOT_USER: gqlserver
  MINIO_ROOT_PASSWORD: gqlserver

  ADMIN_EMAIL: admin@example.com
  ADMIN_PASSWORD: gqlserver

  SECRET_KEY: f2e85774-9a3b-46a5-8170-b40a05ead6ef
```

## LICENSE

MIT License

Copyright (c) 2024 Related Code

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
