//
//  PFCloud.h
//  Parse
//
//  Created by Shyam Jayaraman on 8/20/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFConstants.h"

@interface PFCloud : NSObject

/*!
 Calls the given cloud function with the parameters passed in.
 @param function The function name to call.
 @param parameters The parameters to send to the function.
 @result The response from the cloud function.
 */
+ (id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters;

/*!
 Calls the given cloud function with the parameters passed in and sets the error if there is one.
 @param function The function name to call.
 @param parameters The parameters to send to the function.
 @param error Pointer to an NSError that will be set if necessary.
 @result The response from the cloud function.  This result could be a NSDictionary, an NSArray, NSInteger or NSString.
 */
+ (id)callFunction:(NSString *)function withParameters:(NSDictionary *)parameters error:(NSError **)error;

/*!
 Calls the given cloud function with the parameters provided asynchronously and calls the given block when it is done.
 @param function The function name to call.
 @param parameters The parameters to send to the function.
 @param block The block to execute. The block should have the following argument signature:(id result, NSError *error).
 */
+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters block:(PFIdResultBlock)block;

/*!
 Calls the given cloud function with the parameters provided asynchronously and runs the callback when it is done.
 @param function The function name to call.
 @param parameters The parameters to send to the function.
 @param target The object to call the selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(id) result error:(NSError *)error. result will be nil if error is set and vice versa.
 */
+ (void)callFunctionInBackground:(NSString *)function withParameters:(NSDictionary *)parameters target:(id)target selector:(SEL)selector;
@end
