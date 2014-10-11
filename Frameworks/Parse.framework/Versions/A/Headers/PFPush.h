//
//  PFPush.h
//  Parse
//
//  Created by Ilya Sukhar on 7/4/11.
//  Copyright 2011 Parse, Inc. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>

#import "PFConstants.h"
#import "PFQuery.h"

/*!
 A class which defines a push notification that can be sent from
 a client device.

 The preferred way of modifying or retrieving channel subscriptions is to use
 the PFInstallation class, instead of the class methods in PFPush.

 This class is currently for iOS only. Parse does not handle Push Notifications
 to Parse applications running on OS X. Push Notifications can be sent from OS X
 applications via Cloud Code or the REST API to push-enabled devices (e.g. iOS
 or Android).
 */
@interface PFPush : NSObject <NSCopying>

/*! @name Creating a Push Notification */
+ (PFPush *)push;

/*! @name Configuring a Push Notification */

/*!
 Sets the channel on which this push notification will be sent.
 @param channel The channel to set for this push. The channel name must start
 with a letter and contain only letters, numbers, dashes, and underscores.
 */
- (void)setChannel:(NSString *)channel;

/*!
 Sets the array of channels on which this push notification will
 be sent.
 @param channels The array of channels to set for this push. Each channel name
 must start with a letter and contain only letters, numbers, dashes, and underscores.
 */
- (void)setChannels:(NSArray *)channels;

/*!
 Sets an installation query to which this push notification will be sent. The
 query should be created via [PFInstallation query] and should not specify a
 skip, limit, or order.
 @param query The installation query to set for this push.
 */
- (void)setQuery:(PFQuery *)query;

/*!
 Sets an alert message for this push notification. This will overwrite
 any data specified in setData.
 @param message The message to send in this push.
 */
- (void)setMessage:(NSString *)message;

/*!
 Sets an arbitrary data payload for this push notification. See the guide
 for information about the dictionary structure. This will overwrite any
 data specified in setMessage.
 @param data The data to send in this push.
 */
- (void)setData:(NSDictionary *)data;

/*!
 Sets whether this push will go to Android devices.
 @param pushToAndroid Whether this push will go to Android devices.
 @deprecated Please use a [PFInstallation query] with a constraint on deviceType instead.
 */
- (void)setPushToAndroid:(BOOL)pushToAndroid PARSE_DEPRECATED("Please use a [PFInstallation query] with a constraint on deviceType.");

/*!
 Sets whether this push will go to iOS devices.
 @param pushToIOS Whether this push will go to iOS devices.
 @deprecated Please use a [PFInstallation query] with a constraint on deviceType instead.
 */
- (void)setPushToIOS:(BOOL)pushToIOS PARSE_DEPRECATED("Please use a [PFInstallation query] with a constraint on deviceType.");

/*!
 Sets the expiration time for this notification. The notification will be
 sent to devices which are either online at the time the notification
 is sent, or which come online before the expiration time is reached.
 Because device clocks are not guaranteed to be accurate, most applications
 should instead use expireAfterTimeInterval.
 @param date The time at which the notification should expire.
 */
- (void)expireAtDate:(NSDate *)date;

/*!
 Sets the time interval after which this notification should expire.
 This notification will be sent to devices which are either online at
 the time the notification is sent, or which come online within the given
 time interval of the notification being received by Parse's server.
 An interval which is less than or equal to zero indicates that the
 message should only be sent to devices which are currently online.
 @param timeInterval The interval after which the notification should expire.
 */
- (void)expireAfterTimeInterval:(NSTimeInterval)timeInterval;

/*!
 Clears both expiration values, indicating that the notification should
 never expire.
 */
- (void)clearExpiration;

/*! @name Sending Push Notifications */

/*!
 Send a push message to a channel.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param message The message to send.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the send succeeded.
 */
+ (BOOL)sendPushMessageToChannel:(NSString *)channel
                     withMessage:(NSString *)message
                           error:(NSError **)error;

/*!
 Asynchronously send a push message to a channel.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param message The message to send.
 */
+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message;

/*!
 Asynchronously sends a push message to a channel and calls the given block.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param message The message to send.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                       block:(PFBooleanResultBlock)block;

/*!
 Asynchronously send a push message to a channel.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param message The message to send.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
+ (void)sendPushMessageToChannelInBackground:(NSString *)channel
                                 withMessage:(NSString *)message
                                      target:(id)target
                                    selector:(SEL)selector;

/*!
 Send a push message to a query.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param message The message to send.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the send succeeded.
 */
+ (BOOL)sendPushMessageToQuery:(PFQuery *)query
                   withMessage:(NSString *)message
                         error:(NSError **)error;

/*!
 Asynchronously send a push message to a query.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param message The message to send.
 */
+ (void)sendPushMessageToQueryInBackground:(PFQuery *)query
                               withMessage:(NSString *)message;

/*!
 Asynchronously sends a push message to a query and calls the given block.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param message The message to send.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)sendPushMessageToQueryInBackground:(PFQuery *)query
                               withMessage:(NSString *)message
                                     block:(PFBooleanResultBlock)block;

/*!
 Send this push message.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the send succeeded.
 */
- (BOOL)sendPush:(NSError **)error;

/*!
 Asynchronously send this push message.
 */
- (void)sendPushInBackground;

/*!
 Asynchronously send this push message and executes the given callback block.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
- (void)sendPushInBackgroundWithBlock:(PFBooleanResultBlock)block;

/*!
 Asynchronously send this push message and calls the given callback.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
- (void)sendPushInBackgroundWithTarget:(id)target selector:(SEL)selector;

/*!
 Send a push message with arbitrary data to a channel. See the guide for information about the dictionary structure.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param data The data to send.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the send succeeded.
 */
+ (BOOL)sendPushDataToChannel:(NSString *)channel
                     withData:(NSDictionary *)data
                        error:(NSError **)error;

/*!
 Asynchronously send a push message with arbitrary data to a channel. See the guide for information about the dictionary structure.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param data The data to send.
 */
+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data;

/*!
 Asynchronously sends a push message with arbitrary data to a channel and calls the given block. See the guide for information about the dictionary structure.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param data The data to send.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                    block:(PFBooleanResultBlock)block;

/*!
 Asynchronously send a push message with arbitrary data to a channel. See the guide for information about the dictionary structure.
 @param channel The channel to send to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param data The data to send.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
+ (void)sendPushDataToChannelInBackground:(NSString *)channel
                                 withData:(NSDictionary *)data
                                   target:(id)target
                                 selector:(SEL)selector;

/*!
 Send a push message with arbitrary data to a query. See the guide for information about the dictionary structure.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param data The data to send.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the send succeeded.
 */
+ (BOOL)sendPushDataToQuery:(PFQuery *)query
                   withData:(NSDictionary *)data
                      error:(NSError **)error;

/*!
 Asynchronously send a push message with arbitrary data to a query. See the guide for information about the dictionary structure.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param data The data to send.
 */
+ (void)sendPushDataToQueryInBackground:(PFQuery *)query
                               withData:(NSDictionary *)data;

/*!
 Asynchronously sends a push message with arbitrary data to a query and calls the given block. See the guide for information about the dictionary structure.
 @param query The query to send to. The query must be a PFInstallation query
 created with [PFInstallation query].
 @param data The data to send.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)sendPushDataToQueryInBackground:(PFQuery *)query
                               withData:(NSDictionary *)data
                                  block:(PFBooleanResultBlock)block;

/*! @name Handling Notifications */

/*!
 A default handler for push notifications while the app is active to mimic the behavior of iOS push notifications while the app is backgrounded or not running. Call this from didReceiveRemoteNotification.
 @param userInfo The userInfo dictionary you get in didReceiveRemoteNotification.
 */
+ (void)handlePush:(NSDictionary *)userInfo;

/*! @name Managing Channel Subscriptions */

/*!
 Store the device token locally for push notifications. Usually called from you main app delegate's didRegisterForRemoteNotificationsWithDeviceToken.
 @param deviceToken Either as an NSData straight from didRegisterForRemoteNotificationsWithDeviceToken or as an NSString if you converted it yourself.
 */
+ (void)storeDeviceToken:(id)deviceToken;

/*!
 Get all the channels that this device is subscribed to.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns an NSSet containing all the channel names this device is subscribed to.
 */
+ (NSSet *)getSubscribedChannels:(NSError **)error;

/*!
 Get all the channels that this device is subscribed to.
 @param block The block to execute. The block should have the following argument signature: (NSSet *channels, NSError *error)
 */
+ (void)getSubscribedChannelsInBackgroundWithBlock:(PFSetResultBlock)block;

/*!
 Asynchronously get all the channels that this device is subscribed to.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSSet *)result error:(NSError *)error. error will be nil on success and set if there was an error.
 @result Returns an NSSet containing all the channel names this device is subscribed to.
 */
+ (void)getSubscribedChannelsInBackgroundWithTarget:(id)target
                                           selector:(SEL)selector;

/*!
 Subscribes the device to a channel of push notifications.
 @param channel The channel to subscribe to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the subscribe succeeded.
 */
+ (BOOL)subscribeToChannel:(NSString *)channel error:(NSError **)error;

/*!
 Asynchronously subscribes the device to a channel of push notifications.
 @param channel The channel to subscribe to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 */
+ (void)subscribeToChannelInBackground:(NSString *)channel;

/*!
 Asynchronously subscribes the device to a channel of push notifications and calls the given block.
 @param channel The channel to subscribe to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)subscribeToChannelInBackground:(NSString *)channel
                                 block:(PFBooleanResultBlock)block;

/*!
 Asynchronously subscribes the device to a channel of push notifications and calls the given callback.
 @param channel The channel to subscribe to. The channel name must start with
 a letter and contain only letters, numbers, dashes, and underscores.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
+ (void)subscribeToChannelInBackground:(NSString *)channel
                                target:(id)target
                              selector:(SEL)selector;

/*!
 Unsubscribes the device to a channel of push notifications.
 @param channel The channel to unsubscribe from.
 @param error Pointer to an NSError that will be set if necessary.
 @result Returns whether the unsubscribe succeeded.
 */
+ (BOOL)unsubscribeFromChannel:(NSString *)channel error:(NSError **)error;

/*!
 Asynchronously unsubscribes the device from a channel of push notifications.
 @param channel The channel to unsubscribe from.
 */
+ (void)unsubscribeFromChannelInBackground:(NSString *)channel;

/*!
 Asynchronously unsubscribes the device from a channel of push notifications and calls the given block.
 @param channel The channel to unsubscribe from.
 @param block The block to execute. The block should have the following argument signature: (BOOL succeeded, NSError *error)
 */
+ (void)unsubscribeFromChannelInBackground:(NSString *)channel
                                     block:(PFBooleanResultBlock)block;

/*!
 Asynchronously unsubscribes the device from a channel of push notifications and calls the given callback.
 @param channel The channel to unsubscribe from.
 @param target The object to call selector on.
 @param selector The selector to call. It should have the following signature: (void)callbackWithResult:(NSNumber *)result error:(NSError *)error. error will be nil on success and set if there was an error. [result boolValue] will tell you whether the call succeeded or not.
 */
+ (void)unsubscribeFromChannelInBackground:(NSString *)channel
                                    target:(id)target
                                  selector:(SEL)selector;

@end
