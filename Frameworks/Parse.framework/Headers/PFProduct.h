//
//  PFProduct.h
//
//  Copyright 2011-present Parse Inc. All rights reserved.
//

#import <Parse/PFFile.h>
#import <Parse/PFObject.h>
#import <Parse/PFSubclassing.h>

/*!
 The `PFProduct` class represents an in-app purchase product on the Parse server.
 By default, products can only be created via the Data Browser. Saving a `PFProduct` will result in error.
 However, the products' metadata information can be queried and viewed.

 This class is currently for iOS only.
 */
@interface PFProduct : PFObject<PFSubclassing>

/*!
 @abstract The name of the Installation class in the REST API.

 @discussion This is a required PFSubclassing method.
 */
+ (NSString *)parseClassName;

///--------------------------------------
/// @name Querying for Products
///--------------------------------------

/*!
 @abstract A <PFQuery> that could be used to fetch all product instances from Parse.
 */
+ (PFQuery *)query;

///--------------------------------------
/// @name Product-specific Properties
///--------------------------------------

/*!
 @abstract The product identifier of the product.

 @discussion This should match the product identifier in iTunes Connect exactly.
 */
@property (nonatomic, strong) NSString *productIdentifier;

/*!
 @abstract The icon of the product.
 */
@property (nonatomic, strong) PFFile *icon;

/*!
 @abstract The title of the product.
 */ 
@property (nonatomic, strong) NSString *title;

/*!
 @abstract The subtitle of the product.
 */
@property (nonatomic, strong) NSString *subtitle;

/*!
 @abstract The order in which the product information is displayed in <PFProductTableViewController>.

 @discussion The product with a smaller order is displayed earlier in the <PFProductTableViewController>.
 */
@property (nonatomic, strong) NSNumber *order;

/*!
 @abstract The name of the associated download.

 @discussion If there is no downloadable asset, it should be `nil`.
 */
@property (nonatomic, strong, readonly) NSString *downloadName;

@end
