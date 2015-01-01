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

/*!
 `PFSignUpFields` bitmask specifies the sign up elements which are enabled in the view.

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
 The `PFSignUpView` class provides a standard sign up interface for authenticating a <PFUser>.
 */
@interface PFSignUpView : UIScrollView

///--------------------------------------
/// @name Creating SignUp View
///--------------------------------------

/*!
 @abstract Initializes the view with the specified sign up elements.

 @param fields A bitmask specifying the sign up elements which are enabled in the view

 @returns An initialized `PFSignUpView` object or `nil` if the object couldn't be created.

 @see PFSignUpFields
 */
- (instancetype)initWithFields:(PFSignUpFields)fields;

/*!
 @abstract The view controller that will present this view.

 @discussion Used to lay out elements correctly when the presenting view controller has translucent elements.
 */
@property (nonatomic, weak) UIViewController *presentingViewController;

///--------------------------------------
/// @name Customizing the Logo
///--------------------------------------

/*!
 @abstract The logo. By default, it is the Parse logo.
 */
@property (nonatomic, strong) UIView *logo;

///--------------------------------------
/// @name Configure Username Behaviour
///--------------------------------------

/*!
 @abstract If email should be used to log in, instead of username

 @discussion By default, this is set to `NO`.
 */
@property (nonatomic, assign) BOOL emailAsUsername;

///--------------------------------------
/// @name Sign Up Elements
///--------------------------------------

/*!
 @abstract The bitmask which specifies the enabled sign up elements in the view
 */
@property (nonatomic, assign, readonly) PFSignUpFields fields;

/*!
 @abstract The username text field.
 */
@property (nonatomic, strong, readonly) UITextField *usernameField;

/*!
 @abstract The password text field.
 */
@property (nonatomic, strong, readonly) UITextField *passwordField;

/*!
 @abstract The email text field. It is `nil` if the element is not enabled.
 */
@property (nonatomic, strong, readonly) UITextField *emailField;

/*!
 @abstract The additional text field. It is `nil` if the element is not enabled.

 @discussion This field is intended to be customized.
 */
@property (nonatomic, strong, readonly) UITextField *additionalField;

/*!
 @abstract The sign up button. It is `nil` if the element is not enabled.
 */
@property (nonatomic, strong, readonly) UIButton *signUpButton;

/*!
 @abstract The dismiss button. It is `nil` if the element is not enabled.
 */
@property (nonatomic, strong, readonly) UIButton *dismissButton;

@end
