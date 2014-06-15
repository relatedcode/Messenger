//
// PFFacebookUtils.h
// Copyright (c) 2012 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FacebookSDK/FBSession.h>

#import "PFUser.h"
#import "PFConstants.h"

/*!
 Provides utility functions for working with Facebook in a Parse application.
 
 This class is currently for iOS only.
 */
@interface PFFacebookUtils : NSObject

/** @name Interacting With Facebook */

/*!
 Gets the Facebook session for the current user.
 */
+ (FBSession *)session;

/*!
 Deprecated. Please call [PFFacebookUtils initializeFacebook] instead.
 */
+ (void)initializeWithApplicationId:(NSString *)appId __attribute__ ((deprecated));

/*!
 Deprecated. Please call [PFFacebookUtils initializeFacebookWithUrlSchemeSuffix:] instead.
 */
+ (void)initializeWithApplicationId:(NSString *)appId
                    urlSchemeSuffix:(NSString *)urlSchemeSuffix __attribute__ ((deprecated));

/*!
 Initializes the Facebook singleton. You must invoke this in order to use the Facebook functionality in Parse.
 You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file as
 described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
 */
+ (void)initializeFacebook;

/*!
 Initializes the Facebook singleton. You must invoke this in order to use the Facebook functionality in Parse.
 You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file as
 described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
 @param urlSchemeSuffix The URL suffix for this application - used when multiple applications with the same
 Facebook application ID may be on the same device.
 */
+ (void)initializeFacebookWithUrlShemeSuffix:(NSString *)urlSchemeSuffix;

/*!
 Whether the user has their account linked to Facebook.
 @param user User to check for a facebook link. The user must be logged in on this device.
 @result True if the user has their account linked to Facebook.
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

/** @name Logging In & Creating Facebook-Linked Users */

/*!
 Logs in a user using Facebook. This method delegates to the Facebook SDK to authenticate
 the user, and then automatically logs in (or creates, in the case where it is a new user)
 a PFUser.
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param block The block to execute. The block should have the following argument signature:
 (PFUser *user, NSError *error)
 */
+ (void)logInWithPermissions:(NSArray *)permissions block:(PFUserResultBlock)block;

/*!
 Logs in a user using Facebook. This method delegates to the Facebook SDK to authenticate
 the user, and then automatically logs in (or creates, in the case where it is a new user)
 a PFUser. The selector for the callback should look like: (PFUser *)user error:(NSError **)error
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 */
+ (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;

/*!
 Logs in a user using Facebook. Allows you to handle user login to Facebook, then provide authentication
 data to log in (or create, in the case where it is a new user) the PFUser.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param block The block to execute. The block should have the following argument signature:
 (PFUser *user, NSError *error)
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                      block:(PFUserResultBlock)block;

/*!
 Logs in a user using Facebook. Allows you to handle user login to Facebook, then provide authentication
 data to log in (or create, in the case where it is a new user) the PFUser.
 The selector for the callback should look like: (PFUser *)user error:(NSError *)error
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                     target:(id)target
                   selector:(SEL)selector;

/** @name Linking Users with Facebook */

/*!
 Links Facebook to an existing PFUser. This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the PFUser.
 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions;

/*!
 Links Facebook to an existing PFUser. This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the PFUser.
 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param block The block to execute. The block should have the following argument signature:
 (BOOL *success, NSError *error)
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions block:(PFBooleanResultBlock)block;

/*!
 Links Facebook to an existing PFUser. This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the PFUser.
 The selector for the callback should look like: (NSNumber *)result error:(NSError *)error
 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;

/*!
 Links Facebook to an existing PFUser. Allows you to handle user login to Facebook, then provide authentication
 data to link the account to the PFUser.
 @param user User to link to Facebook.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param block The block to execute. The block should have the following argument signature:
 (BOOL *success, NSError *error)
 */
+ (void)linkUser:(PFUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
           block:(PFBooleanResultBlock)block;

/*!
 Links Facebook to an existing PFUser. Allows you to handle user login to Facebook, then provide authentication
 data to link the account to the PFUser.
 The selector for the callback should look like: (NSNumber *)result error:(NSError *)error
 @param user User to link to Facebook.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete
 */
+ (void)linkUser:(PFUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
          target:(id)target
        selector:(SEL)selector;

/** @name Unlinking Users from Facebook */

/*!
 Unlinks the PFUser from a Facebook account.
 @param user User to unlink from Facebook.
 @result Returns true if the unlink was successful.
 */
+ (BOOL)unlinkUser:(PFUser *)user;

/*!
 Unlinks the PFUser from a Facebook account.
 @param user User to unlink from Facebook.
 @param error Error object to set on error.
 @result Returns true if the unlink was successful.
 */
+ (BOOL)unlinkUser:(PFUser *)user error:(NSError **)error;

/*!
 Makes an asynchronous request to unlink a user from a Facebook account.
 @param user User to unlink from Facebook.
 */
+ (void)unlinkUserInBackground:(PFUser *)user;

/*!
 Makes an asynchronous request to unlink a user from a Facebook account.
 @param user User to unlink from Facebook.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)unlinkUserInBackground:(PFUser *)user block:(PFBooleanResultBlock)block;

/*!
 Makes an asynchronous request to unlink a user from a Facebook account.
 @param user User to unlink from Facebook
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 */
+ (void)unlinkUserInBackground:(PFUser *)user target:(id)target selector:(SEL)selector;

/** @name Obtaining new permissions */

/*!
 Requests new Facebook publish permissions for the given user.  This may prompt the user to
 reauthorize the application. The user will be saved as part of this operation.
 @param user User to request new permissions for.  The user must be linked to Facebook.
 @param permissions The new publishing permissions to request.
 @param audience The default audience for publishing permissions to request.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)reauthorizeUser:(PFUser *)user
 withPublishPermissions:(NSArray *)permissions
               audience:(FBSessionDefaultAudience)audience
                  block:(PFBooleanResultBlock)block;

/*!
 Requests new Facebook publish permissions for the given user.  This may prompt the user to
 reauthorize the application. The user will be saved as part of this operation.
 @param user User to request new permissions for.  The user must be linked to Facebook.
 @param permissions The new publishing permissions to request.
 @param audience The default audience for publishing permissions to request.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 */
+ (void)reauthorizeUser:(PFUser *)user
 withPublishPermissions:(NSArray *)permissions
               audience:(FBSessionDefaultAudience)audience
                 target:(id)target
               selector:(SEL)selector;

/** @name Delegating URL Actions */

/*!
 Deprecated.  Instead, please use:
   [FBAppCall handleOpenURL:url
          sourceApplication:sourceApplication
                withSession:[PFFacebookUtils session]];
 */
+ (BOOL)handleOpenURL:(NSURL *)url __attribute__ ((deprecated));

@end
