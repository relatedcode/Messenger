//
// PFTwitterUtils.h
// Copyright (c) 2012 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PF_Twitter.h"
#import "PFUser.h"
#import "PFConstants.h"

/*!
 Provides utility functions for working with Twitter in a Parse application.

 This class is currently for iOS only.
 */
@interface PFTwitterUtils : NSObject

/** @name Interacting With Twitter */

/*!
 Gets the instance of the Twitter object that Parse uses.
 @result The Twitter instance.
 */
+ (PF_Twitter *)twitter;

/*!
 Initializes the Twitter singleton. You must invoke this in order to use the Twitter functionality in Parse.
 @param consumerKey Your Twitter application's consumer key.
 @param consumerSecret Your Twitter application's consumer secret.
 */
+ (void)initializeWithConsumerKey:(NSString *)consumerKey
                   consumerSecret:(NSString *)consumerSecret;

/*!
 Whether the user has their account linked to Twitter.
 @param user User to check for a Twitter link. The user must be logged in on this device.
 @result True if the user has their account linked to Twitter.
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

/** @name Logging In & Creating Twitter-Linked Users */

/*!
 Logs in a user using Twitter. This method delegates to Twitter to authenticate
 the user, and then automatically logs in (or creates, in the case where it is a new user)
 a PFUser.
 @param block The block to execute. The block should have the following argument signature:
 (PFUser *user, NSError *error) 
 */
+ (void)logInWithBlock:(PFUserResultBlock)block;

/*!
 Logs in a user using Twitter. This method delegates to Twitter to authenticate
 the user, and then automatically logs in (or creates, in the case where it is a new user)
 a PFUser. The selector for the callback should look like: (PFUser *)user error:(NSError **)error
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchrounous request is complete.
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector;

/*!
 Logs in a user using Twitter. Allows you to handle user login to Twitter, then provide authentication
 data to log in (or create, in the case where it is a new user) the PFUser.
 @param twitterId The id of the Twitter user being linked
 @param screenName The screen name of the Twitter user being linked
 @param authToken The auth token for the user's session
 @param authTokenSecret The auth token secret for the user's session
 @param block The block to execute. The block should have the following argument signature:
 (PFUser *user, NSError *error) 
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                     block:(PFUserResultBlock)block;

/*!
 Logs in a user using Twitter. Allows you to handle user login to Twitter, then provide authentication
 data to log in (or create, in the case where it is a new user) the PFUser.
 The selector for the callback should look like: (PFUser *)user error:(NSError *)error
 @param twitterId The id of the Twitter user being linked
 @param screenName The screen name of the Twitter user being linked
 @param authToken The auth token for the user's session
 @param authTokenSecret The auth token secret for the user's session
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete
 */
+ (void)logInWithTwitterId:(NSString *)twitterId
                screenName:(NSString *)screenName
                 authToken:(NSString *)authToken
           authTokenSecret:(NSString *)authTokenSecret
                    target:(id)target
                  selector:(SEL)selector;

/** @name Linking Users with Twitter */

/*!
 Links Twitter to an existing PFUser. This method delegates to Twitter to authenticate
 the user, and then automatically links the account to the PFUser.
 @param user User to link to Twitter.
 */
+ (void)linkUser:(PFUser *)user;

/*!
 Links Twitter to an existing PFUser. This method delegates to Twitter to authenticate
 the user, and then automatically links the account to the PFUser.
 @param user User to link to Twitter.
 @param block The block to execute. The block should have the following argument signature:
 (BOOL *success, NSError *error) 
 */
+ (void)linkUser:(PFUser *)user block:(PFBooleanResultBlock)block;

/*!
 Links Twitter to an existing PFUser. This method delegates to Twitter to authenticate
 the user, and then automatically links the account to the PFUser.
 The selector for the callback should look like: (NSNumber *)result error:(NSError *)error
 @param user User to link to Twitter.
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchrounous request is complete.
 */
+ (void)linkUser:(PFUser *)user
          target:(id)target
        selector:(SEL)selector;

/*!
 Links Twitter to an existing PFUser. Allows you to handle user login to Twitter, then provide authentication
 data to link the account to the PFUser.
 @param user User to link to Twitter.
 @param twitterId The id of the Twitter user being linked
 @param screenName The screen name of the Twitter user being linked
 @param authToken The auth token for the user's session
 @param authTokenSecret The auth token secret for the user's session
 @param block The block to execute. The block should have the following argument signature:
 (BOOL *success, NSError *error) 
 */
+ (void)linkUser:(PFUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
           block:(PFBooleanResultBlock)block;

/*!
 Links Twitter to an existing PFUser. Allows you to handle user login to Twitter, then provide authentication
 data to link the account to the PFUser.
 The selector for the callback should look like: (NSNumber *)result error:(NSError *)error
 @param user User to link to Twitter.
 @param twitterId The id of the Twitter user being linked
 @param screenName The screen name of the Twitter user being linked
 @param authToken The auth token for the user's session
 @param authTokenSecret The auth token secret for the user's session
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchronous request is complete
 */
+ (void)linkUser:(PFUser *)user
       twitterId:(NSString *)twitterId
      screenName:(NSString *)screenName
       authToken:(NSString *)authToken
 authTokenSecret:(NSString *)authTokenSecret
          target:(id)target
        selector:(SEL)selector;

/** @name Unlinking Users from Twitter */

/*!
 Unlinks the PFUser from a Twitter account. 
 @param user User to unlink from Twitter.
 @result Returns true if the unlink was successful.
 */
+ (BOOL)unlinkUser:(PFUser *)user;

/*!
 Unlinks the PFUser from a Twitter account. 
 @param user User to unlink from Twitter.
 @param error Error object to set on error.
 @result Returns true if the unlink was successful.
 */
+ (BOOL)unlinkUser:(PFUser *)user error:(NSError **)error;

/*!
 Makes an asynchronous request to unlink a user from a Twitter account. 
 @param user User to unlink from Twitter.
 */
+ (void)unlinkUserInBackground:(PFUser *)user;

/*!
 Makes an asynchronous request to unlink a user from a Twitter account. 
 @param user User to unlink from Twitter.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error) 
 */
+ (void)unlinkUserInBackground:(PFUser *)user
                         block:(PFBooleanResultBlock)block;

/*!
 Makes an asynchronous request to unlink a user from a Twitter account. 
 @param user User to unlink from Twitter
 @param target Target object for the selector
 @param selector The selector that will be called when the asynchrounous request is complete.
 */
+ (void)unlinkUserInBackground:(PFUser *)user
                        target:(id)target selector:(SEL)selector;

@end
