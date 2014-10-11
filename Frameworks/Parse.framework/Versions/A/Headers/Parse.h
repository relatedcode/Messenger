//
//  Parse.h
//  Parse
//
//  Created by Ilya Sukhar on 9/29/11.
//  Copyright 2011 Parse, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFACL.h"
#import "PFAnalytics.h"
#import "PFAnonymousUtils.h"
#import "PFCloud.h"
#import "PFConstants.h"
#import "PFConfig.h"
#import "PFFile.h"
#import "PFGeoPoint.h"
#import "PFObject.h"
#import "PFQuery.h"
#import "PFRelation.h"
#import "PFRole.h"
#import "PFSubclassing.h"
#import "PFUser.h"

#if PARSE_IOS_ONLY
#import "PFImageView.h"
#import "PFInstallation.h"
#import "PFLogInViewController.h"
#import "PFProduct.h"
#import "PFProductTableViewController.h"
#import "PFPurchase.h"
#import "PFPush.h"
#import "PFQueryTableViewController.h"
#import "PFSignUpViewController.h"
#import "PFTableViewCell.h"
#import "PFTwitterUtils.h"
#endif

/*!
 The Parse class contains static functions that handle global configuration for the Parse framework.
 */
@interface Parse : NSObject

/** @name Connecting to Parse */

/*!
 Sets the applicationId and clientKey of your application.
 @param applicationId The application id for your Parse application.
 @param clientKey The client key for your Parse application.
 */
+ (void)setApplicationId:(NSString *)applicationId clientKey:(NSString *)clientKey;
+ (NSString *)getApplicationId;
+ (NSString *)getClientKey;

#if PARSE_IOS_ONLY
/** @name Configuring UI Settings */

/*!
 Set whether to show offline messages when using a Parse view or view controller related classes.
 @param enabled Whether a UIAlertView should be shown when the device is offline and network access is required
                from a view or view controller.
 */
+ (void)offlineMessagesEnabled:(BOOL)enabled;

/*!
 Set whether to show an error message when using a Parse view or view controller related classes
 and a Parse error was generated via a query.
 @param enabled Whether a UIAlertView should be shown when a Parse error occurs.
 */
+ (void)errorMessagesEnabled:(BOOL)enabled;
#endif

@end
