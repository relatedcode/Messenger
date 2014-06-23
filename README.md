[![RelatedCode](http://relatedcode.com/github/header3.png)](http://relatedcode.com)

## OVERVIEW

ParseChat is a full native iPhone app to create realtime, text based chatrooms with Parse.

![ParseChat](http://relatedcode.com/github/parsechat1.png)
.
![ParseChat](http://relatedcode.com/github/parsechat2.png)
.
![ParseChat](http://relatedcode.com/github/parsechat3.png)

ParseChat is using Parse as backend which is basically free. (Free plan: 20 GB File Storage, 20 GB Database Storage, 2 TB Data Transfer, 30 req/s).

Really easy to setup, just copy/paste the code and use your own chatrooms.

## FEATURES

- Live chat between multiple devices
- Multiple chatrooms
- Dynamically add new chatrooms
- Register/Login views
- Basic Profile view is also included
- Change profile picture possibility
- No backend programming needed
- Automatic online/offline detection and handle
- Copy and paste messages
- Dynamically resizes input text while typing
- Native and easy to customize user interface
- Send button is enabled/disabled automatically
- Arbitrary message sizes
- Data detectors (recognizes phone numbers, links and dates)
- Timestamps possibilities
- Automatic avatar images from Facebook/Twitter
- Hide keyboard with swipe down
- Smooth animations
- Send/Receive sound effects

## REQUIREMENTS

- Xcode 5
- iOS 7
- ARC

## INSTALLATION

**1.,** All ParseChat files located in *Classes* directory. Vendor files located in *Vendor* directory and external Frameworks in *Framework* directory. Some resource files can be found in *Resources* directory. Simply add *Classes*, *Resources*, *Vendor* and *Framework* directories to your project.

**2.,** You need the following iOS (built in) libraries: UIKit.framework, CoreGraphics.framework, Foundation.framework, SystemConfiguration.framework, StoreKit.framework, Security.framework, QuartzCore.framework, MobileCoreServices.framework, CoreLocation.framework, CFNetwork.framework, AudioToolbox.framework, libz.dylib.

To add libraries follow these steps: Click on the Targets → Your app name → and then the 'Build Phases' tab and then expand 'Link Binary With Libraries'. Click the plus button in the bottom left of the 'Link Binary With Libraries' section and choose library items from the list.

**3.,** You also need the latest Parse.framework (already included). But if you need, you can download from here:

https://www.parse.com/docs/downloads<br>

To add Parse.framework just unzip the downloaded file and drag the .framework folders into your Xcode project under 'Frameworks'.

**4.,** You can find more info about how to install Parse SDK here:

https://www.parse.com/apps/quickstart#parse_data/mobile/ios/native/existing

**5.,** The *Prefix.pch* should contain:

```
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
```

**6.,** You also need several external libraries which are included. But if you need, you can download them from here:

https://github.com/jessesquires/JSQMessagesViewController<br>
https://github.com/jessesquires/JSQSystemSoundPlayer<br>
https://github.com/relatedcode/ProgressHUD<br>

To use these libraries, just add JSQMessagesViewController, JSQSystemSoundPlayer and ProgressHUD directories to your project.

**7.,** You need to use your own Parse account. To get your Parse account click here:

https://www.parse.com/#signup

**8.,** Please replace existing Parse account details in *AppDelegate.m*:

```
[Parse setApplicationId:@"d4Gxb4wEFk92AvjeFMzg1lTbVfctpeSh4MWTbKQE" clientKey:@"9JBA6xFKY7eWtrnM1mj9qVevZqBOXI4hkRdjUpBw"];
```

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
