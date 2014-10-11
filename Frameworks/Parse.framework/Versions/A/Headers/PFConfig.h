//
//  PFConfig.h
//  Parse
//
//  Created by Nikita Lutsenko on 6/9/14.
//  Copyright (c) 2014 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFConfig;

typedef void(^PFConfigResultBlock)(PFConfig *config, NSError *error);

/*!
 PFConfig is a representation of the remote configuration object.
 It enables you to add things like feature gating, a/b testing or simple "Message of the day".
*/
@interface PFConfig : NSObject

#pragma mark -
#pragma mark Init

/*!
 Returns the most recently fetched config.
 If there was no config fetched - this method will return an empty instance of PFConfig.
 @return Current, last fetched instance of PFConfig.
 */
+ (PFConfig *)currentConfig;

#pragma mark -
#pragma mark Fetch

/*!
 Gets the PFConfig object synchronously from the server.
 @return Instance of PFConfig if the operation succeeded. Nil - if there was an error.
 */
+ (PFConfig *)getConfig;

/*!
 Gets the PFConfig object synchronously from the server and sets an error if it occurs.
 @param error Pointer to an NSError that will be set if necessary.
 @return Instance of PFConfig if the operation succeeded. Nil - if there was an error.
 */
+ (PFConfig *)getConfig:(NSError **)error;

/*!
 Gets the PFConfig asynchronously and executes the given callback block.
 @param block The block to execute.
 The block should have the following argument signature: (PFConfig *config, NSError *error).
 */
+ (void)getConfigInBackgroundWithBlock:(PFConfigResultBlock)block;

#pragma mark -
#pragma mark Getting Values

/*!
 Returns the object associated with a given key.
 @param key The key for which to return the corresponding configuration value.
 @return The value associated with `key`, or nil if there is no such value.
 */
- (id)objectForKey:(NSString *)key;

/*!
 Returns the object associated with a given key.
 This method behaves the same as `objectForKey:`.
 @param keyedSubscript The key for which to return the corresponding configuration value.
 @return The value associated with `key`, or nil if there is no such value.
 */
- (id)objectForKeyedSubscript:(NSString *)keyedSubscript;

@end
