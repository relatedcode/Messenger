//
//  PFImageView.h
//  Parse
//
//  Created by Qian Wang on 5/16/12.
//  Copyright (c) 2012 Parse Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFFile.h"

/*!
 An image view that downloads and displays remote image stored on Parse's server.
 */
@interface PFImageView : UIImageView

/// The remote file on Parse's server that stores the image.
/// Note that the download does not start until loadInBackground: is called.
@property (nonatomic, strong) PFFile *file;

/*!
 Initiate downloading of the remote image. Once the download completes, the remote image will be displayed.
 */
- (void)loadInBackground;

/*!
 Initiate downloading of the remote image. Once the download completes, the remote image will be displayed.
 @param completion the completion block.
 */
- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion;

@end
