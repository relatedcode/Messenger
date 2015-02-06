//
//  PFFacebookUtils.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FacebookSDK/FacebookSDK.h>

#import <Parse/PFConstants.h>
#import <Parse/PFUser.h>

@class BFTask;

/*!
 The `PFFacebookUtils` class provides utility functions for working with Facebook in a Parse application.

 This class is currently for iOS only.
 */
@interface PFFacebookUtils : NSObject

///--------------------------------------
/// @name Interacting With Facebook
///--------------------------------------

/*!
 @abstract Gets the Facebook session for the current user.
 */
+ (FBSession *)session;

/*!
 @abstract Initializes the Facebook singleton.

 @warning You must invoke this in order to use the Facebook functionality in Parse.

 @param appId The Facebook application id that you are using with your Parse application.

 @deprecated Please use `[PFFacebookUtils initializeFacebook]` instead.
 */
+ (void)initializeWithApplicationId:(NSString *)appId PARSE_DEPRECATED("Use [PFFacebookUtils initializeFacebook] instead.");

/*!
 @abstract Initializes the Facebook singleton.

 @warning You must invoke this in order to use the Facebook functionality in Parse.

 @param appId The Facebook application id that you are using with your Parse application.
 @param urlSchemeSuffix The URL suffix for this application - used when multiple applications with the same

 @deprecated Please use `[PFFacebookUtils initializeFacebookWithUrlShemeSuffix:]` instead.
 */
+ (void)initializeWithApplicationId:(NSString *)appId
                    urlSchemeSuffix:(NSString *)urlSchemeSuffix PARSE_DEPRECATED("Use [PFFacebookUtils initializeFacebookWithUrlShemeSuffix:] instead.");

/*!
 @abstract Initializes the Facebook singleton.

 @discussion  You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file
 as described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

 @warning You must invoke this in order to use the Facebook functionality in Parse.
 */
+ (void)initializeFacebook;

/*!
 @abstract Initializes the Facebook singleton.

 @discussion  You must provide your Facebook application ID as the value for FacebookAppID in your bundle's plist file
 as described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/

 @warning You must invoke this in order to use the Facebook functionality in Parse.

 @param urlSchemeSuffix The URL suffix for this application - used when multiple applications with the same
 Facebook application ID may be on the same device.
 */
+ (void)initializeFacebookWithUrlShemeSuffix:(NSString *)urlSchemeSuffix;

/*!
 @abstract Whether the user has their account linked to Facebook.

 @param user User to check for a facebook link. The user must be logged in on this device.

 @returns `YES` if the user has their account linked to Facebook, otherwise `NO`.
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

///--------------------------------------
/// @name Logging In & Creating Facebook-Linked Users
///--------------------------------------

/*!
 @abstract Logs in a user using Facebook *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.

 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)logInWithPermissionsInBackground:(NSArray *)permissions;

/*!
 @abstract Logs in a user using Facebook.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.
 `user` is going to be non-nil if the authentication was succesful.
 `error` is set if there was an error.
 `user` and `error` are both nil - if the user cancelled authentication by switching back to the application.

 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param block The block to execute.
 It should have the following argument signature: `^(PFUser *user, NSError *error)`.
 */
+ (void)logInWithPermissions:(NSArray *)permissions block:(PFUserResultBlock)block;

/*
 @abstract Logs in a user using Facebook *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate the user,
 and then automatically logs in (or creates, in the case where it is a new user) a <PFUser>.
 `user` is going to be non-nil if the authentication was succesful.
 `error` is set if there was an error.
 `user` and `error` are both nil - if the user cancelled authentication by switching back to the application.

 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithUser:(PFUser *)user error:(NSError *)error`.
 */
+ (void)logInWithPermissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;

/*!
 @abstract Logs in a user using Facebook *asynchronously*.

 @discussion Allows you to handle user login to Facebook, then provide authentication
 data to log in (or create, in the case where it is a new user) the <PFUser>.

 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)logInWithFacebookIdInBackground:(NSString *)facebookId
                                accessToken:(NSString *)accessToken
                             expirationDate:(NSDate *)expirationDate;

/*!
 @abstract Logs in a user using Facebook *asynchronously*.

 @discussion Allows you to handle user login to Facebook, then provide authentication
 data to log in (or create, in the case where it is a new user) the <PFUser>.

 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param block The block to execute.
 It should have the following argument signature: `^(PFUser *user, NSError *error)`.
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                      block:(PFUserResultBlock)block;

/*
 @abstract Logs in a user using Facebook *asynchronously*.

 @discussion Allows you to handle user login to Facebook, then provide authentication
 data to log in (or create, in the case where it is a new user) the <PFUser>.

 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithUser:(PFUser *)user error:(NSError *)error`.
 */
+ (void)logInWithFacebookId:(NSString *)facebookId
                accessToken:(NSString *)accessToken
             expirationDate:(NSDate *)expirationDate
                     target:(id)target
                   selector:(SEL)selector;

///--------------------------------------
/// @name Linking Users with Facebook
///--------------------------------------

/*!
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.

 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in.
 This passed to the authorize method on the Facebook instance.

 @deprecated Please use `[PFFacebookUtils linkUserInBackground:permissions:]` instead.
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions PARSE_DEPRECATED("Please use `[PFFacebookUtils linkUserInBackground:permissions:]` instead.");

/*!
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.

 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in.
 This passed to the authorize method on the Facebook instance.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)linkUserInBackground:(PFUser *)user permissions:(NSArray *)permissions;

/*!
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.

 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in.
 This passed to the authorize method on the Facebook instance.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL *success, NSError *error)`.
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions block:(PFBooleanResultBlock)block;

/*
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion This method delegates to the Facebook SDK to authenticate
 the user, and then automatically links the account to the <PFUser>.

 @param user User to link to Facebook.
 @param permissions The permissions required for Facebook log in. This passed to the authorize method on
 the Facebook instance.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 */
+ (void)linkUser:(PFUser *)user permissions:(NSArray *)permissions target:(id)target selector:(SEL)selector;

/*!
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion Allows you to handle user login to Facebook,
 then provide authentication data to link the account to the <PFUser>.

 @param user User to link to Facebook.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)linkUserInBackground:(PFUser *)user
                      facebookId:(NSString *)facebookId
                     accessToken:(NSString *)accessToken
                  expirationDate:(NSDate *)expirationDate;

/*!
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion Allows you to handle user login to Facebook,
 then provide authentication data to link the account to the <PFUser>.

 @param user User to link to Facebook.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL success, NSError *error)`.
 */
+ (void)linkUser:(PFUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
           block:(PFBooleanResultBlock)block;

/*
 @abstract Links Facebook to an existing <PFUser> *asynchronously*.

 @discussion Allows you to handle user login to Facebook,
 then provide authentication data to link the account to the <PFUser>.

 @param user User to link to Facebook.
 @param facebookId The id of the Facebook user being linked
 @param accessToken The access token for the user's session
 @param expirationDate The expiration date for the access token
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 */
+ (void)linkUser:(PFUser *)user
      facebookId:(NSString *)facebookId
     accessToken:(NSString *)accessToken
  expirationDate:(NSDate *)expirationDate
          target:(id)target
        selector:(SEL)selector;

///--------------------------------------
/// @name Unlinking Users from Facebook
///--------------------------------------

/*!
 @abstract Unlinks the <PFUser> from a Facebook account *synchronously*.

 @param user User to unlink from Facebook.

 @returns Returns `YES` if the unlink was successful, otherwise `NO`.
 */
+ (BOOL)unlinkUser:(PFUser *)user;

/*!
 @abstract Unlinks the <PFUser> from a Facebook account *synchronously*.

 @param user User to unlink from Facebook.
 @param error Error object to set on error.

 @returns Returns `YES` if the unlink was successful, otherwise `NO`.
 */
+ (BOOL)unlinkUser:(PFUser *)user error:(NSError **)error;

/*!
 @abstract Unlinks the <PFUser> from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)unlinkUserInBackground:(PFUser *)user;

/*!
 @abstract Unlinks the <PFUser> from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)unlinkUserInBackground:(PFUser *)user block:(PFBooleanResultBlock)block;

/*
 @abstract Unlinks the <PFUser> from a Facebook account *asynchronously*.

 @param user User to unlink from Facebook
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 */
+ (void)unlinkUserInBackground:(PFUser *)user target:(id)target selector:(SEL)selector;

///--------------------------------------
/// @name Obtaining New Permissions
///--------------------------------------

/*!
 @abstract Requests new Facebook publish permissions for the given user *asynchronously*.

 @discussion The user will be saved as part of this operation.

 @warning This may prompt the user to reauthorize the application.

 @param user User to request new permissions for.  The user must be linked to Facebook.
 @param permissions The new publishing permissions to request.
 @param audience The default audience for publishing permissions to request.

 @returns The task, that encapsulates the work being done.
 */
+ (BFTask *)reauthorizeUserInBackground:(PFUser *)user
                 withPublishPermissions:(NSArray *)permissions
                               audience:(FBSessionDefaultAudience)audience;

/*!
 @abstract Requests new Facebook publish permissions for the given user *asynchronously*.

 @discussion The user will be saved as part of this operation.

 @warning This may prompt the user to reauthorize the application.

 @param user User to request new permissions for.  The user must be linked to Facebook.
 @param permissions The new publishing permissions to request.
 @param audience The default audience for publishing permissions to request.
 @param block The block to execute.
 It should have the following argument signature: `^(BOOL succeeded, NSError *error)`.
 */
+ (void)reauthorizeUser:(PFUser *)user
 withPublishPermissions:(NSArray *)permissions
               audience:(FBSessionDefaultAudience)audience
                  block:(PFBooleanResultBlock)block;

/*
 @abstract Requests new Facebook publish permissions for the given user *asynchronously*.

 @discussion The user will be saved as part of this operation.

 @warning This may prompt the user to reauthorize the application.

 @param user User to request new permissions for.  The user must be linked to Facebook.
 @param permissions The new publishing permissions to request.
 @param audience The default audience for publishing permissions to request.
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchronous request is complete.
 It should have the following signature: `(void)callbackWithResult:(NSNumber *)result error:(NSError *)error`.
 */
+ (void)reauthorizeUser:(PFUser *)user
 withPublishPermissions:(NSArray *)permissions
               audience:(FBSessionDefaultAudience)audience
                 target:(id)target
               selector:(SEL)selector;

///--------------------------------------
/// @name Delegating URL Actions
///--------------------------------------

/*!
 @abstract Handles URLs being opened by your AppDelegate. Invoke and return this from application:handleOpenURL:
 or application:openURL:sourceApplication:annotation in your AppDelegate.

 @param url URL being opened by your application.
 @returns `YES` if Facebook will handle this URL, otherwise `NO`.

 @deprecated Please use
 `[FBAppCall handleOpenURL:url
 sourceApplication:sourceApplication
 withSession:[PFFacebookUtils session]];` instead.
 */
+ (BOOL)handleOpenURL:(NSURL *)url PARSE_DEPRECATED("Use [FBAppCall handleOpenURL:sourceApplication:withSession:] instead.");

@end
