//
//  PFLogInView.h
//  Parse
//
//  Created by Qian Wang on 3/9/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PFLogInFieldsNone = 0,
    PFLogInFieldsUsernameAndPassword = 1 << 0,
    PFLogInFieldsPasswordForgotten = 1 << 1,
    PFLogInFieldsLogInButton = 1 << 2,
    PFLogInFieldsFacebook = 1 << 3,
    PFLogInFieldsTwitter = 1 << 4,
    PFLogInFieldsSignUpButton = 1 << 5,
    PFLogInFieldsDismissButton = 1 << 6,
    
    PFLogInFieldsDefault = PFLogInFieldsUsernameAndPassword | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsPasswordForgotten | PFLogInFieldsDismissButton
} PFLogInFields;

/*!
 The class provides a standard log in interface for authenticating a PFUser.
 */
@interface PFLogInView : UIView

/*! @name Creating Log In View */
/*!
 Initializes the view with the specified log in elements.
 @param fields A bitmask specifying the log in elements which are enabled in the view
 */
- (instancetype)initWithFields:(PFLogInFields) fields;

/// The view controller that will present this view.
/// Used to lay out elements correctly when the presenting view controller has translucent elements.
@property (nonatomic, strong) UIViewController *presentingViewController;

/*! @name Customizing the Logo */

/// The logo. By default, it is the Parse logo.
@property (nonatomic, strong) UIView *logo;

/*! @name Prompt for email as username. */

/// By default, this is set to NO.
@property (nonatomic, assign) BOOL emailAsUsername;

/*! @name Accessing Log In Elements */

/// The bitmask which specifies the enabled log in elements in the view
@property (nonatomic, readonly, assign) PFLogInFields fields;

/// The username text field. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UITextField *usernameField;

/// The password text field. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UITextField *passwordField;

/// The password forgotten button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *passwordForgottenButton;

/// The log in button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *logInButton;

/// The Facebook button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *facebookButton;

/// The Twitter button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *twitterButton;

/// The sign up button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *signUpButton;

/// The dismiss button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *dismissButton;

/// The facebook/twitter login label. It is only shown if the external login is enabled.
@property (nonatomic, strong, readonly) UILabel *externalLogInLabel;

/// The sign up label. It is only shown if sign up button is enabled.
@property (nonatomic, strong, readonly) UILabel *signUpLabel;

@end


