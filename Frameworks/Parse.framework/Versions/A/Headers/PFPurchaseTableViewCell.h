//
//  PFPurchaseTableViewCell.h
//  Parse
//
//  Created by Qian Wang on 5/21/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PFTableViewCell.h"

/*!
 An enum that represents states of the PFPurchaseTableViewCell.
 @see PFPurchaseTableViewCell
 */
typedef NS_ENUM(uint8_t, PFPurchaseTableViewCellState) {
    /*! Normal state of the cell. */
    PFPurchaseTableViewCellStateNormal = 0,
    /*! Downloading state of the cell. */
    PFPurchaseTableViewCellStateDownloading,
    /*! State of the cell, when the product was downloaded. */
    PFPurchaseTableViewCellStateDownloaded
};

/*!
 PFPurchaseTableViewCell is a subclass PFTableViewCell that is used to show
 products in a PFProductTableViewController.
 @see PFProductTableViewController
 */
@interface PFPurchaseTableViewCell : PFTableViewCell

/*! State of the cell */
@property (nonatomic, assign) PFPurchaseTableViewCellState state;

/*! Label where price of the product is displayed. */
@property (nonatomic, strong, readonly) UILabel *priceLabel;

/*! Progress view that is shown, when the product is downloading. */
@property (nonatomic, strong, readonly) UIProgressView *progressView;

@end
