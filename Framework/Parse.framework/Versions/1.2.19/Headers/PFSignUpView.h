//
//  PFLogInView.h
//  Parse
//
//  Created by Qian Wang on 3/9/12.
//  Copyright (c) 2012. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    PFSignUpFieldsUsernameAndPassword = 0,
    PFSignUpFieldsEmail = 1 << 0,
    PFSignUpFieldsAdditional = 1 << 1, // this field can be used for something else
    PFSignUpFieldsSignUpButton = 1 << 2,
    PFSignUpFieldsDismissButton = 1 << 3,
    PFSignUpFieldsDefault = PFSignUpFieldsUsernameAndPassword | PFSignUpFieldsEmail | PFSignUpFieldsSignUpButton | PFSignUpFieldsDismissButton
} PFSignUpFields;

/*!
 The class provides a standard sign up interface for authenticating a PFUser.
 */
@interface PFSignUpView : UIScrollView

/*! @name Creating Sign Up View */
/*!
 Initializes the view with the specified sign up elements.
 @param fields A bitmask specifying the sign up elements which are enabled in the view
 */
- (id)initWithFields:(PFSignUpFields) fields;

/// The view controller that will present this view.
/// Used to lay out elements correctly when the presenting view controller has translucent elements.
@property (nonatomic, retain) UIViewController *presentingViewController;

/*! @name Customizing the Logo */

/// The logo. By default, it is the Parse logo.
@property (nonatomic, retain) UIView *logo;

/*! @name Accessing Sign Up Elements */

/// The bitmask which specifies the enabled sign up elements in the view
@property (nonatomic, readonly, assign) PFSignUpFields fields;

/// The username text field.
@property (nonatomic, readonly, retain) UITextField *usernameField;

/// The password text field.
@property (nonatomic, readonly, retain) UITextField *passwordField;

/// The email text field. It is nil if the element is not enabled.
@property (nonatomic, readonly, retain) UITextField *emailField;

/// The additional text field. It is nil if the element is not enabled.
/// This field is intended to be customized.
@property (nonatomic, readonly, retain) UITextField *additionalField;

/// The sign up button. It is nil if the element is not enabled.
@property (nonatomic, readonly, retain) UIButton *signUpButton;

/// The dismiss button. It is nil if the element is not enabled.
@property (nonatomic, readonly, retain) UIButton *dismissButton;
@end


