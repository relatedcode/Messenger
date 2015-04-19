//
//  IDMZoomingScrollView.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDMPhotoProtocol.h"
#import "IDMTapDetectingImageView.h"
#import "IDMTapDetectingView.h"

@class IDMPhotoBrowser, IDMPhoto;

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMZoomingScrollView : UIScrollView <UIScrollViewDelegate, IDMTapDetectingImageViewDelegate, IDMTapDetectingViewDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IDMPhotoBrowser *__weak _photoBrowser;
    id<IDMPhoto> _photo;

	IDMTapDetectingView *_tapView;
}

@property (nonatomic, strong) IDMTapDetectingImageView *photoImageView;
@property (nonatomic, strong) id<IDMPhoto> photo;

- (id)initWithPhotoBrowser:(IDMPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(IDMPhoto*)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
