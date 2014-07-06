//
//  PFProduct.h
//  Parse
//
//  Created by Qian Wang on 6/7/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import "PFObject.h"
#import "PFSubclassing.h"
#import "PFFile.h"

/*!
 Represents an in-app purchase product on the Parse server.
 By default, products can only be created via the data browser; saving a PFProduct
 will result in error. However, the products' metadata information can be queried 
 and viewed.

 This class is currently for iOS only.
 */
@interface PFProduct : PFObject<PFSubclassing>

/*! The name of the Product class in the REST API. This is a required
 *  PFSubclassing method */
+ (NSString *)parseClassName;

/** @name Querying for Products */
/*!
 A query that fetches all product instances registered on Parse's server.
 */
+ (PFQuery *)query;

/** @name Accessing Product-specific Properties */
/*!
 The product identifier of the product. 
 This should match the product identifier in iTunes Connect exactly.
 */
@property (nonatomic, retain) NSString *productIdentifier;

/*!
 The icon of the product.
 */
@property (nonatomic, retain) PFFile *icon;

/*!
 The title of the product.
 */ 
@property (nonatomic, retain) NSString *title;

/*!
 The subtitle of the product.
 */
@property (nonatomic, retain) NSString *subtitle;

/*!
 The order in which the product information is displayed in PFProductTableViewController.
 The product with a smaller order is displayed earlier in the PFProductTableViewController. 
 */
@property (nonatomic, retain) NSNumber *order;

/*!
 The name of the associated download. If there is no downloadable asset, it should be nil.
 */
@property (nonatomic, readonly) NSString *downloadName;


@end
