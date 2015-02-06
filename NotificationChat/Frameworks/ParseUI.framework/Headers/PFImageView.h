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

@class BFTask;
@class PFFile;

/*!
 An image view that downloads and displays remote image stored on Parse's server.
 */
@interface PFImageView : UIImageView

/*!
 @abstract The remote file on Parse's server that stores the image.

 @warning Note that the download does not start until <loadInBackground:> is called.
 */
@property (nonatomic, strong) PFFile *file;

/*!
 @abstract Initiate downloading of the remote image.

 @discussion Once the download completes, the remote image will be displayed.

 @returns The task, that encapsulates the work being done.
 */
- (BFTask *)loadInBackground;

/*!
 @abstract Initiate downloading of the remote image.

 @discussion Once the download completes, the remote image will be displayed.

 @param completion the completion block.
 */
- (void)loadInBackground:(void (^)(UIImage *image, NSError *error))completion;

@end
