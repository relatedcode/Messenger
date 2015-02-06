[![RelatedCode](http://relatedcode.com/github/header8.png)](http://relatedcode.com)

## OVERVIEW

This is a full native iPhone app to create realtime, text based group or private chat with Parse.

![Chat](http://relatedcode.com/github/chat01.png)
.
![Chat](http://relatedcode.com/github/chat04.png)
.
![Chat](http://relatedcode.com/github/chat03.png)

The app is using Parse as backend which is basically free. (Free plan: 20 GB File Storage, 20 GB Database Storage, 2 TB Data Transfer, 30 req/s).

Really easy to setup, just copy/paste the code and use your own chatrooms.

## WHAT'S NEW IN 3.5

- Address Book access + invite function

## FEATURES

- Live chat between multiple devices
- Group and Private chat functionality
- Push Notification support
- Picture media support
- Messages view for ongoing chats
- Multiple chatrooms
- Dynamically add new chatrooms
- Register/Login views
- Facebook login
- Facebook profile picture is grabbed automatically
- Basic Profile view is also included
- Change profile picture possibility
- No backend programming needed
- Copy and paste messages
- Native and easy to customize user interface
- Send button is enabled/disabled automatically
- Arbitrary message sizes
- Data detectors (recognizes phone numbers, links and dates)
- Timestamps possibilities
- Hide keyboard with swipe down
- Smooth animations
- Send/Receive sound effects

## REQUIREMENTS

- Xcode 6
- iOS 8
- ARC

## INSTALLATION

**1.,** All files located in *Classes* directory. Vendor files located in *Vendor* directory and external Frameworks in *Framework* directory. Some resource files can be found in *Resources* directory. Simply add *Classes*, *Resources*, *Vendor* and *Framework* directories to your project.

**2.,** You also need the latest Parse SDK. (Already included, but you can download from [here](https://www.parse.com/docs/downloads)).

To add Parse.framework just unzip the downloaded file and drag the Parse.framework folder into your Xcode project under 'Frameworks'.

More info about how to [install](https://www.parse.com/apps/quickstart#parse_data/mobile/ios/native/existing) Parse SDK.

**3.,** You also need the latest Facebook SDK. (Already included, but you can download from [here](https://developers.facebook.com/docs/ios)).

To add FacebookSDK.framework just drag the FacebookSDK.framework folder into your Xcode project under 'Frameworks'.

More info about how to [install](https://developers.facebook.com/docs/ios/getting-started) Facebook SDK.

**4.,** You also need several external libraries which are included. But if you need, you can download them from here:

https://github.com/AFNetworking/AFNetworking<br>
https://github.com/jessesquires/JSQMessagesViewController<br>
https://github.com/jessesquires/JSQSystemSoundPlayer<br>
https://github.com/relatedcode/ProgressHUD<br>

To use these libraries, just add AFNetworking, JSQMessagesViewController, JSQSystemSoundPlayer and ProgressHUD directories to your project.

**5.,** You need to [register](https://developers.facebook.com/apps) your app at Facebook. More info about how to [configure](https://developers.facebook.com/docs/ios/getting-started) Facebook.

**6.,** You need to use your own [Parse account](https://www.parse.com/#signup).

**7.,** You need to [configure](https://www.parse.com/tutorials/ios-push-notifications) Push Notification.

**8.,** Please replace the existing Parse account details in *AppDelegate.m*.

**9.,** Please replace the existing Facebook account details in *Info.plist*.


## CONTACT

Do you have any questions or idea? My email is: info@relatedcode.com or you can find some more info at [relatedcode.com](http://relatedcode.com)

## LICENSE

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
