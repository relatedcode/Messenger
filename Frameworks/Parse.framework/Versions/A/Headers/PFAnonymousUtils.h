//
//  PFAnonymousUtils.h
//  Parse
//
//  Created by David Poll on 3/20/12.
//  Copyright (c) 2012 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFUser.h"
#import "PFConstants.h"

/*!
 Provides utility functions for working with Anonymously logged-in users.
 Anonymous users have some unique characteristics:

 - Anonymous users don't need a user name or password.
 - Once logged out, an anonymous user cannot be recovered.
 - When the current user is anonymous,
   the following methods can be used to switch to a different user or convert the anonymous user into a regular one:
   - signUp converts an anonymous user to a standard user with the given username and password.<br/>
     Data associated with the anonymous user is retained.
   - logIn switches users without converting the anonymous user.<br/>
     Data associated with the anonymous user will be lost.
   - Service logIn (e.g. Facebook, Twitter) will attempt to convert the anonymous user into a standard user by linking it to the service.<br/>
     If a user already exists that is linked to the service, it will instead switch to the existing user.
   - Service linking (e.g. Facebook, Twitter) will convert the anonymous user into a standard user by linking it to the service.
 */
@interface PFAnonymousUtils : NSObject

/*! @name Creating an Anonymous User */

/*!
 Creates an anonymous user.
 @param block The block to execute when anonymous user creation is complete. The block should have the following argument signature:
 (PFUser *user, NSError *error) 
 */
+ (void)logInWithBlock:(PFUserResultBlock)block;

/*!
 Creates an anonymous user.  The selector for the callback should look like: (PFUser *)user error:(NSError *)error
 @param target Target object for the selector.
 @param selector The selector that will be called when the asynchronous request is complete.
 */
+ (void)logInWithTarget:(id)target selector:(SEL)selector;

/*! @name Determining Whether a PFUser is Anonymous */

/*!
 Whether the user is logged in anonymously.
 @param user User to check for anonymity. The user must be logged in on this device.
 @result True if the user is anonymous.  False if the user is not the current user or is not anonymous.
 */
+ (BOOL)isLinkedWithUser:(PFUser *)user;

@end
