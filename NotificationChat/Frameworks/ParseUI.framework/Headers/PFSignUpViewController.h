/*
 *  Copyright (c) 2014, Facebook, Inc. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Facebook.
 *
 *  As with any software that integrates with the Facebook platform, your use of
 *  this software is subject to the Facebook Developer Principles and Policies
 *  [http://developers.facebook.com/policy/]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>

#import <ParseUI/PFSignUpView.h>

@class PFUser;
@protocol PFSignUpViewControllerDelegate;

/*!
 The `PFSignUpViewController` class that presents and manages
 a standard authentication interface for signing up a <PFUser>.
 */
@interface PFSignUpViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

///--------------------------------------
/// @name Configuring Sign Up Elements
///--------------------------------------

/*!
 @abstract A bitmask specifying the log in elements which are enabled in the view.

 @see PFSignUpFields
 */
@property (nonatomic, assign) PFSignUpFields fields;

/*!
 @abstract The sign up view. It contains all the enabled log in elements.

 @see PFSignUpView
 */
@property (nonatomic, strong, readonly) PFSignUpView *signUpView;

///--------------------------------------
/// @name Configuring Sign Up Behaviors
///--------------------------------------

/*!
 @abstract The delegate that responds to the control events of `PFSignUpViewController`.

 @see PFSignUpViewControllerDelegate
 */
@property (nonatomic, weak) id<PFSignUpViewControllerDelegate> delegate;

/*!
 @abstract Minimum required password length for user signups, defaults to `0`.
 */
@property (nonatomic, assign) NSUInteger minPasswordLength;

/*!
 @abstract Whether to use the email as username on the attached <signUpView>.

 @discussion If set to `YES`, we'll hide the email field, prompt for the email in
 the username field, and save the email into both username and email
 fields on the new <PFUser> object. By default, this is set to `NO`.
 */
@property (nonatomic, assign) BOOL emailAsUsername;

@end

///--------------------------------------
/// @name Notifications
///--------------------------------------

/*!
 @abstract The notification is posted immediately after the sign up succeeds.
 */
extern NSString *const PFSignUpSuccessNotification;

/*!
 @abstract The notification is posted immediately after the sign up fails.

 @discussion If the delegate prevents the sign up to start, the notification is not sent.
 */
extern NSString *const PFSignUpFailureNotification;

/*!
 @abstract The notification is posted immediately after the user cancels sign up.
 */
extern NSString *const PFSignUpCancelNotification;

///--------------------------------------
/// @name PFSignUpViewControllerDelegate
///--------------------------------------

/*!
 The `PFLogInViewControllerDelegate` protocol defines methods a delegate of a <PFSignUpViewController> should implement.
 All methods of this protocol are optional.
 */
@protocol PFSignUpViewControllerDelegate <NSObject>

@optional

///--------------------------------------
/// @name Customizing Behavior
///--------------------------------------

/*!
 @abstract Sent to the delegate to determine whether the sign up request should be submitted to the server.

 @param signUpController The signup view controller that is requesting the data.
 @param info An `NSDictionary` instance which contains all sign up information that the user entered.

 @returns A `BOOL` indicating whether the sign up should proceed.
 */
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info;

///--------------------------------------
/// @name Responding to Actions
///--------------------------------------

/*!
 @abstract Sent to the delegate when a <PFUser> is signed up.

 @param signUpController The signup view controller where signup finished.
 @param user <PFUser> object that is a result of the sign up.
 */
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user;

/*!
 @abstract Sent to the delegate when the sign up attempt fails.

 @param signUpController The signup view controller where signup failed.
 @param error `NSError` object representing the error that occured.
 */
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error;

/*!
 @abstract Sent to the delegate when the sign up screen is cancelled.

 @param signUpController The signup view controller where signup was cancelled.
 */
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController;

@end
