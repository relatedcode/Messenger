//
//  PFPurchase.h
//  Parse
//
//  Created by Qian Wang on 5/2/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

#import "PFConstants.h"

/*!
 PFPurchase provides a set of APIs for working with in-app purchases.

 This class is currently for iOS only.
 */
@interface PFPurchase : NSObject

/*!
 Use this method to add application logic block which is run when buying a product.
 This method should be called once for each product, and should be called before
 calling buyProduct:block. All invocations to addObserverForProduct:block: should happen within
 the same method, and on the main thread. It is recommended to place all invocations of this method
 in application:didFinishLaunchingWithOptions:.

 @param productIdentifier the product identifier
 @param block The block to be run when buying a product.
 */
+ (void)addObserverForProduct:(NSString *)productIdentifier block:(void(^)(SKPaymentTransaction *transaction))block;

/*!
 Asynchronously initiates the purchase for the product.

 @param productIdentifier the product identifier
 @param block the completion block.
 */
+ (void)buyProduct:(NSString *)productIdentifier block:(void(^)(NSError *error))block;

/*!
 Asynchronously download the purchased asset, which is stored on Parse's server.
 Parse verifies the receipt with Apple and delivers the content only if the receipt is valid.

 @param transaction the transaction, which contains the receipt.
 @param completion the completion block.
 */
+ (void)downloadAssetForTransaction:(SKPaymentTransaction *)transaction completion:(void(^)(NSString *filePath, NSError *error))completion;

/*!
 Asynchronously download the purchased asset, which is stored on Parse's server.
 Parse verifies the receipt with Apple and delivers the content only if the receipt is valid.

 @param transaction the transaction, which contains the receipt.
 @param completion the completion block.
 @param progress the progress block, which is called multiple times to reveal progress of the download.
 */
+ (void)downloadAssetForTransaction:(SKPaymentTransaction *)transaction completion:(void(^)(NSString *filePath, NSError *error))completion progress:(PFProgressBlock)progress;

/*!
 Asynchronously restore completed transactions for the current user.
 Note: This method is only important to developers who want to preserve purchase states across
 different installations of the same app.
 Only nonconsumable purchases are restored. If observers for the products have been added before
 calling this method, invoking the method reruns the application logic associated with the purchase.
 */
+ (void)restore;

@end
