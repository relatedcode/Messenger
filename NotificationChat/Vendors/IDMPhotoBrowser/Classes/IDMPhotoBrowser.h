//
//  IDMPhotoBrowser.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "IDMPhoto.h"
#import "IDMPhotoProtocol.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMPhotoBrowser : UIViewController <UIScrollViewDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, weak) UIImage *scaleImage;

@property (nonatomic) float animationDuration;

- (id)initWithPhotos:(NSArray *)photosArray;

- (void)reloadData;

@end
