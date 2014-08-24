//
//  PFProductsTableViewController.h
//  Parse
//
//  Created by Qian Wang on 5/15/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import "PFQueryTableViewController.h"

/*!
 PFProductTableViewController displays in-app purchase products stored on Parse.
 In addition to setting up in-app purchases in iTunesConnect, the app developer needs 
 to register product information on Parse, in the Product class.
 */
@interface PFProductTableViewController : PFQueryTableViewController

/*!
 Initializes a product table view controller.
 */
- (instancetype)init;
@end
