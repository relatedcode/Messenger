//
//  PFLogInViewController.h
//  Parse
//
//  Created by Andrew Wang on 3/8/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFLogInView.h"
#import "PFSignUpViewController.h"
#import "PFUser.h"

@protocol PFLogInViewControllerDelegate;

/*!
 The class that presents and manages a standard authentication interface for logging in a PFUser.
 */
@interface PFLogInViewController : UIViewController <UITextFieldDelegate>

/*! @name Configuring Log In Elements */

/*!
 A bitmask specifying the log in elements which are enabled in the view.
    enum {
        PFLogInFieldsNone = 0,
        PFLogInFieldsUsernameAndPassword = 1 << 0,
        PFLogInFieldsPasswordForgotten = 1 << 1,
        PFLogInFieldsLogInButton = 1 << 2,
        PFLogInFieldsFacebook = 1 << 3,
        PFLogInFieldsTwitter = 1 << 4,
        PFLogInFieldsSignUpButton = 1 << 5,
        PFLogInFieldsDismissButton = 1 << 6,
        PFLogInFieldsDefault = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton
    };
 */
@property (nonatomic) PFLogInFields fields;

/// The log in view. It contains all the enabled log in elements.
@property (nonatomic, readonly, retain) PFLogInView *logInView;

/*! @name Configuring Log In Behaviors */
/// The delegate that responds to the control events of PFLogInViewController.
@property (nonatomic, assign) id<PFLogInViewControllerDelegate> delegate;

/// The facebook permissions that Facebook log in requests for.
/// If unspecified, the default is basic facebook permissions.
@property (nonatomic, retain) NSArray *facebookPermissions;

/// The sign up controller if sign up is enabled.
/// Use this to configure the sign up view, and the transition animation to the sign up view.
/// The default is a sign up view with a username, a password, a dismiss button and a sign up button.
@property (nonatomic, retain) PFSignUpViewController *signUpController; 

@end

/*! @name Notifications */
/// The notification is posted immediately after the log in succeeds.
extern NSString *const PFLogInSuccessNotification;

/// The notification is posted immediately after the log in fails.
/// If the delegate prevents the log in from starting, the notification is not sent.
extern NSString *const PFLogInFailureNotification;

/// The notification is posted immediately after the log in is cancelled.
extern NSString *const PFLogInCancelNotification;

/*!
 The protocol defines methods a delegate of a PFLogInViewController should implement.
 All methods of the protocol are optional.
 */
@protocol PFLogInViewControllerDelegate <NSObject>
@optional

/*! @name Customizing Behavior */

/*!
 Sent to the delegate to determine whether the log in request should be submitted to the server.
 @param username the username the user tries to log in with.
 @param password the password the user tries to log in with.
 @result a boolean indicating whether the log in should proceed.
 */
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password;

/*! @name Responding to Actions */
/// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user;

/// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error;

/// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController;
@end

