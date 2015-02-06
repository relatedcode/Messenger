/*
 *  Copyright (c) 2014, Facebook, Inc. All rights reserved.
 *
 *  You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
 *  copy, modify, and distribute this software in source code or binary form for use
 *  in connection with the web services and APIs provided by Facebook.
 *
 *  As with any software that integrates with the Facebook platform, your use of
 *  this software is subject to the Facebook Developer Principles and Policies
 *  [http://developers.facebook.com/policy/]. This copyright notice shall be
 *  included in all copies or substantial portions of the software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 *  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
 *  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
 *  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
 *  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 *  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

#import <UIKit/UIKit.h>

#import <ParseUI/PFTableViewCell.h>

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
 `PFPurchaseTableViewCell` is a subclass <PFTableViewCell> that is used to show
 products in a <PFProductTableViewController>.

 @see PFProductTableViewController
 */
@interface PFPurchaseTableViewCell : PFTableViewCell

/*!
 @abstract State of the cell.
 @see PFPurchaseTableViewCellState
 */
@property (nonatomic, assign) PFPurchaseTableViewCellState state;

/*!
 @abstract Label where price of the product is displayed.
 */
@property (nonatomic, strong, readonly) UILabel *priceLabel;

/*!
 @abstract Progress view that is shown, when the product is downloading.
 */
@property (nonatomic, strong, readonly) UIProgressView *progressView;

@end
