//
//  IDMZoomingScrollView.m
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "IDMZoomingScrollView.h"
#import "IDMPhotoBrowser.h"
#import "IDMPhoto.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMPhotoBrowser ()

- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMZoomingScrollView ()

@property (nonatomic, weak) IDMPhotoBrowser *photoBrowser;
- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation IDMZoomingScrollView

@synthesize photoImageView = _photoImageView, photoBrowser = _photoBrowser, photo = _photo;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithPhotoBrowser:(IDMPhotoBrowser *)browser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((self = [super init]))
	{
		self.photoBrowser = browser;

		_tapView = [[IDMTapDetectingView alloc] initWithFrame:self.bounds];
		_tapView.tapDelegate = self;
		_tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_tapView.backgroundColor = [UIColor clearColor];
		[self addSubview:_tapView];

		_photoImageView = [[IDMTapDetectingImageView alloc] initWithFrame:CGRectZero];
		_photoImageView.tapDelegate = self;
		_photoImageView.backgroundColor = [UIColor clearColor];
		[self addSubview:_photoImageView];
		
		CGRect screenBound = [[UIScreen mainScreen] bounds];
		CGFloat screenWidth = screenBound.size.width;
		CGFloat screenHeight = screenBound.size.height;
		
		if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft ||
			[[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight)
		{
			screenWidth = screenBound.size.height;
			screenHeight = screenBound.size.width;
		}

		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setPhoto:(id<IDMPhoto>)photo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_photoImageView.image = nil;
	if (_photo != photo)
	{
		_photo = photo;
	}
	[self displayImage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)prepareForReuse
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.photo = nil;
}

#pragma mark - Image

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)displayImage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (_photo && _photoImageView.image == nil)
	{
		self.maximumZoomScale = 1;
		self.minimumZoomScale = 1;
		self.zoomScale = 1;
		
		self.contentSize = CGSizeMake(0, 0);

		UIImage *img = [self.photoBrowser imageForPhoto:_photo];
		if (img)
		{
			_photoImageView.image = img;
			_photoImageView.hidden = NO;

			CGRect photoImageViewFrame;
			photoImageViewFrame.origin = CGPointZero;
			photoImageViewFrame.size = img.size;
			
			_photoImageView.frame = photoImageViewFrame;
			self.contentSize = photoImageViewFrame.size;

			[self setMaxMinZoomScalesForCurrentBounds];
		}
		else
		{
			_photoImageView.hidden = YES;
		}
		
		[self setNeedsLayout];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setProgress:(CGFloat)progress forPhoto:(IDMPhoto*)photo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)displayImageFailure
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - Setup

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setMaxMinZoomScalesForCurrentBounds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.maximumZoomScale = 1;
	self.minimumZoomScale = 1;
	self.zoomScale = 1;

	if (_photoImageView.image == nil) return;

	CGSize boundsSize = self.bounds.size;
	CGSize imageSize = _photoImageView.frame.size;

	CGFloat xScale = boundsSize.width / imageSize.width;
	CGFloat yScale = boundsSize.height / imageSize.height;
	CGFloat minScale = MIN(xScale, yScale);

	if (xScale > 1 && yScale > 1)
	{
		//minScale = 1.0;
	}

	CGFloat maxScale = 4.0;
	if ([UIScreen instancesRespondToSelector:@selector(scale)])
	{
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}

	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;

	_photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
	[self setNeedsLayout];	
}

#pragma mark - Layout

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)layoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_tapView.frame = self.bounds;

	[super layoutSubviews];

	CGSize boundsSize = self.bounds.size;
	CGRect frameToCenter = _photoImageView.frame;

	if (frameToCenter.size.width < boundsSize.width)
	{
		frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	}
	else
	{
		frameToCenter.origin.x = 0;
	}

	if (frameToCenter.size.height < boundsSize.height)
	{
		frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	}
	else
	{
		frameToCenter.origin.y = 0;
	}

	if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter))
		_photoImageView.frame = frameToCenter;
}

#pragma mark - UIScrollViewDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return _photoImageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self setNeedsLayout];
	[self layoutIfNeeded];
}

#pragma mark - Tap Detection

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)handleSingleTap:(CGPoint)touchPoint
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)handleDoubleTap:(CGPoint)touchPoint
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];

	if (self.zoomScale == self.maximumZoomScale)
	{
		[self setZoomScale:self.minimumZoomScale animated:YES];
	}
	else
	{
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self handleSingleTap:[touch locationInView:imageView]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self handleDoubleTap:[touch locationInView:imageView]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self handleSingleTap:[touch locationInView:view]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self handleDoubleTap:[touch locationInView:view]];
}

@end
