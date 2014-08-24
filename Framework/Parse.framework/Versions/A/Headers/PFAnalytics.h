//
//  PFAnalytics.h
//  Parse
//
//  Created by Christine Yen on 1/29/13.
//  Copyright (c) 2013 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 PFAnalytics provides an interface to Parse's logging and analytics backend.

 Methods will return immediately and cache the request (+ timestamp) to be
 handled "eventually." That is, the request will be sent immediately if possible
 or the next time a network connection is available otherwise.
 */
@interface PFAnalytics : NSObject

/*!
 Tracks this application being launched. If this happened as the result of the
 user opening a push notification, this method sends along information to
 correlate this open with that push.

 Pass in nil to track a standard "application opened" event.

 @param launchOptions The dictionary indicating the reason the application was
 launched, if any. This value can be found as a parameter to various
 UIApplicationDelegate methods, and can be empty or nil.
 */
+ (void)trackAppOpenedWithLaunchOptions:(NSDictionary *)launchOptions;

/*!
 Tracks this application being launched. If this happened as the result of the
 user opening a push notification, this method sends along information to
 correlate this open with that push.

 @param userInfo The Remote Notification payload, if any. This value can be
 found either under UIApplicationLaunchOptionsRemoteNotificationKey on
 launchOptions, or as a parameter to application:didReceiveRemoteNotification:.
 This can be empty or nil.
 */
+ (void)trackAppOpenedWithRemoteNotificationPayload:(NSDictionary *)userInfo;

/*!
 Tracks the occurrence of a custom event. Parse will store a data point at the
 time of invocation with the given event name.
 
 @param name The name of the custom event to report to Parse as having happened.
 */
+ (void)trackEvent:(NSString *)name;

/*!
 Tracks the occurrence of a custom event with additional dimensions. Parse will
 store a data point at the time of invocation with the given event name.
 
 Dimensions will allow segmentation of the occurrences of this custom event.
 Keys and values should be NSStrings, and will throw otherwise.

 To track a user signup along with additional metadata, consider the following:
   NSDictionary *dimensions = @{ @"gender": @"m",
                                 @"source": @"web",
                                 @"dayType": @"weekend" };
   [PFAnalytics trackEvent:@"signup" dimensions:dimensions];

 There is a default limit of 4 dimensions per event tracked.
 
 @param name The name of the custom event to report to Parse as having happened.
 @param dimensions The dictionary of information by which to segment this event.
 */
+ (void)trackEvent:(NSString *)name dimensions:(NSDictionary *)dimensions;

@end
