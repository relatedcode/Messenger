//
//  PFImageViewCell.h
//  Parse
//
//  Created by Qian Wang on 5/16/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFImageView.h"

/*!
 The PFTableViewCell is a table view cell which can download and display remote images stored on Parse's server. When used in a PFQueryTableViewController, the downloading and displaying of the remote images are automatically managed by the PFQueryTableViewController.
 */
@interface PFTableViewCell : UITableViewCell

/// The imageView of the table view cell. PFImageView supports remote image downloading.
@property (nonatomic, strong, readonly) PFImageView *imageView;

@end	
