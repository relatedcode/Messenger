//
//  PF_Twitter.h
//  Copyright (c) 2012 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 A simple interface for interacting with the Twitter REST API, automating sign-in and OAuth signing of requests against the API.
 */
@interface PF_Twitter : NSObject {
@private
    NSString *consumerKey;
    NSString *consumerSecret;
    NSString *authToken;
    NSString *authTokenSecret;
    NSString *userId;
    NSString *screenName;
}

@property (nonatomic, copy) NSString *consumerKey;
@property (nonatomic, copy) NSString *consumerSecret;
@property (nonatomic, copy) NSString *authToken;
@property (nonatomic, copy) NSString *authTokenSecret;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *screenName;

/*!
 Displays an auth dialog and populates the authToken, authTokenSecret, userId, and screenName properties if the Twitter user
 grants permission to the application.
 @param success Invoked upon successful authorization.
 @param failure Invoked upon an error occurring in the authorization process.
 @param cancel Invoked when the user cancels authorization.
 */
- (void)authorizeWithSuccess:(void (^)(void))success failure:(void (^)(NSError *error))failure cancel:(void (^)(void))cancel;

/*!
 Adds a 3-legged OAuth signature to an NSMutableURLRequest based upon the properties set for the Twitter object.
 Use this function to sign requests being made to the Twitter API.
 @param request Request to sign.
 */
- (void)signRequest:(NSMutableURLRequest *)request;

@end
