//
//  PFLogInViewController.h
//  Parse
//
//  Created by Andrew Wang on 3/8/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFSignUpView.h"
#import "PFUser.h"

@protocol PFSignUpViewControllerDelegate;

/*!
 The class that presents and manages a standard authentication interface for signing up a PFUser.
 */
@interface PFSignUpViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate>

/*! @name Configuring Sign Up Elements */

/// 
/*!
 A bitmask specifying the log in elements which are enabled in the view.
    enum {
        PFSignUpFieldsUsernameAndPassword = 0,
        PFSignUpFieldsEmail = 1 << 0,
        PFSignUpFieldsAdditional = 1 << 1, // this field can be used for something else
        PFSignUpFieldsSignUpButton = 1 << 2,
        PFSignUpFieldsDismissButton = 1 << 3,
        PFSignUpFieldsDefault = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton
    };
 */
@property (nonatomic) PFSignUpFields fields;

/// The sign up view. It contains all the enabled log in elements.
@property (nonatomic, readonly, retain) PFSignUpView *signUpView;

/*! @name Configuring Sign Up Behaviors */
/// The delegate that responds to the control events of PFSignUpViewController.
@property (nonatomic, assign) id<PFSignUpViewControllerDelegate> delegate;

@end

/*! @name Notifications */
/// The notification is posted immediately after the sign up succeeds.
extern NSString *const PFSignUpSuccessNotification;

/// The notification is posted immediately after the sign up fails.
/// If the delegate prevents the sign up to start, the notification is not sent.
extern NSString *const PFSignUpFailureNotification;

/// The notification is posted immediately after the user cancels sign up.
extern NSString *const PFSignUpCancelNotification;

/*!
 The protocol defines methods a delegate of a PFSignUpViewController should implement.
 All methods of the protocol are optional.
 */
@protocol PFSignUpViewControllerDelegate <NSObject>
@optional

/*! @name Customizing Behavior */

/*!
 Sent to the delegate to determine whether the sign up request should be submitted to the server.
 @param info a dictionary which contains all sign up information that the user entered. 
 @result a boolean indicating whether the sign up should proceed.
 */
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info;

/// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user;

/// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error;

/// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController;
@end

