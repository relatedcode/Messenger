//
//  PFLogInView.h
//  Parse
//
//  Created by Qian Wang on 3/9/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 A bitmask specifying the sign up elements which are enabled in the view.
 @see PFSignUpViewController
 @see PFSignUpView
 */
typedef NS_OPTIONS(NSInteger, PFSignUpFields) {
    /*! Username and password fields. */
    PFSignUpFieldsUsernameAndPassword = 0,
    /*! Email field. */
    PFSignUpFieldsEmail = 1 << 0,
    /*! This field can be used for something else. */
    PFSignUpFieldsAdditional = 1 << 1,
    /*! Sign Up Button */
    PFSignUpFieldsSignUpButton = 1 << 2,
    /*! Dismiss Button */
    PFSignUpFieldsDismissButton = 1 << 3,
    /*! Default value. Combines Username, Password, Email, Sign Up and Dismiss Buttons. */
    PFSignUpFieldsDefault = (PFSignUpFieldsUsernameAndPassword |
                             PFSignUpFieldsEmail |
                             PFSignUpFieldsSignUpButton |
                             PFSignUpFieldsDismissButton)
};

/*!
 The class provides a standard sign up interface for authenticating a PFUser.
 */
@interface PFSignUpView : UIScrollView

/*! @name Creating Sign Up View */

/*!
 Initializes the view with the specified sign up elements.
 @param fields A bitmask specifying the sign up elements which are enabled in the view
 @see PFSignUpFields
 */
- (instancetype)initWithFields:(PFSignUpFields)fields;

/*!
 The view controller that will present this view.
 Used to lay out elements correctly when the presenting view controller has translucent elements.
 */
@property (nonatomic, strong) UIViewController *presentingViewController;

/*! @name Customizing the Logo */

/// The logo. By default, it is the Parse logo.
@property (nonatomic, strong) UIView *logo;

/*! @name Prompt for email as username. */

/// By default, this is set to NO.
@property (nonatomic, assign) BOOL emailAsUsername;

/*! @name Accessing Sign Up Elements */

/// The bitmask which specifies the enabled sign up elements in the view
@property (nonatomic, assign, readonly) PFSignUpFields fields;

/// The username text field.
@property (nonatomic, strong, readonly) UITextField *usernameField;

/// The password text field.
@property (nonatomic, strong, readonly) UITextField *passwordField;

/// The email text field. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UITextField *emailField;

/// The additional text field. It is nil if the element is not enabled.
/// This field is intended to be customized.
@property (nonatomic, strong, readonly) UITextField *additionalField;

/// The sign up button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *signUpButton;

/// The dismiss button. It is nil if the element is not enabled.
@property (nonatomic, strong, readonly) UIButton *dismissButton;

@end
