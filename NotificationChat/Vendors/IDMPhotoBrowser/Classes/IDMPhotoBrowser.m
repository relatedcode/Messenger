//
//  IDMPhotoBrowser.m
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "IDMPhotoBrowser.h"
#import "IDMZoomingScrollView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMPhotoBrowser ()
{
	NSMutableArray *_photos;

	UIScrollView *_pagingScrollView;

	UIPanGestureRecognizer *_panGesture;

	NSMutableSet *_visiblePages, *_recycledPages;
	NSUInteger _pageIndexBeforeRotation;
	NSUInteger _currentPageIndex;

	NSTimer *_controlVisibilityTimer;

	UIView *_senderViewForAnimation;

	BOOL _performingLayout;
	BOOL _rotating;
	BOOL _viewIsActive;
	NSInteger _initalPageIndex;

	BOOL _isdraggingPhoto;

	CGRect _senderViewOriginalFrame;

	UIWindow *_applicationWindow;

	UIViewController *_applicationTopViewController;
	int _previousModalPresentationStyle;
}

- (void)performLayout;

- (void)tilePages;
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;
- (IDMZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index;
- (IDMZoomingScrollView *)pageDisplayingPhoto:(id<IDMPhoto>)photo;
- (IDMZoomingScrollView *)dequeueRecycledPage;
- (void)configurePage:(IDMZoomingScrollView *)page forIndex:(NSUInteger)index;
- (void)didStartViewingPageAtIndex:(NSUInteger)index;

- (CGRect)frameForPagingScrollView;
- (CGRect)frameForPageAtIndex:(NSUInteger)index;
- (CGSize)contentSizeForPagingScrollView;
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index;

- (NSUInteger)numberOfPhotos;
- (id<IDMPhoto>)photoAtIndex:(NSUInteger)index;
- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo;
- (void)releaseAllUnderlyingPhotos;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation IDMPhotoBrowser

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)init
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((self = [super init]))
	{
		self.hidesBottomBarWhenPushed = YES;
		_currentPageIndex = 0;
		_performingLayout = NO;
		_rotating = NO;
		_viewIsActive = NO;
		_visiblePages = [NSMutableSet new];
		_recycledPages = [NSMutableSet new];
		_photos = [NSMutableArray new];

		_initalPageIndex = 0;

		_animationDuration = 0.28;
		_senderViewForAnimation = nil;
		_scaleImage = nil;

		_isdraggingPhoto = NO;

		if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)])
			self.automaticallyAdjustsScrollViewInsets = NO;

		_applicationWindow = [[[UIApplication sharedApplication] delegate] window];

		if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
		{
			self.modalPresentationStyle = UIModalPresentationCustom;
			self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		}
		else
		{
			_applicationTopViewController = [self topviewController];
			_previousModalPresentationStyle = _applicationTopViewController.modalPresentationStyle;
			_applicationTopViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
			self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		}

		self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	}
	
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithPhotos:(NSArray *)photosArray
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((self = [self init]))
	{
		_photos = [[NSMutableArray alloc] initWithArray:photosArray];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_pagingScrollView.delegate = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self releaseAllUnderlyingPhotos];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)releaseAllUnderlyingPhotos
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (id p in _photos) { if (p != [NSNull null]) [p unloadUnderlyingImage]; }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self releaseAllUnderlyingPhotos];
	[_recycledPages removeAllObjects];

	[super didReceiveMemoryWarning];
}

#pragma mark - Pan Gesture

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)panGestureRecognized:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IDMZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];

	static float firstX, firstY;

	float viewHeight = scrollView.frame.size.height;
	float viewHalfHeight = viewHeight/2;

	CGPoint translatedPoint = [(UIPanGestureRecognizer*)sender translationInView:self.view];

	if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateBegan)
	{
		firstX = [scrollView center].x;
		firstY = [scrollView center].y;
		
		_senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
		
		_isdraggingPhoto = YES;
		[self setNeedsStatusBarAppearanceUpdate];
	}

	translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
	[scrollView setCenter:translatedPoint];

	float newY = scrollView.center.y - viewHalfHeight;
	float newAlpha = 1 - fabsf(newY)/viewHeight;

	self.view.opaque = YES;

	self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:newAlpha];

	if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
	{
		if (scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40)
		{
			if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex)
			{
				[self performCloseAnimationWithScrollView:scrollView];
				return;
			}
			
			CGFloat finalX = firstX, finalY;
			
			CGFloat windowsHeigt = [_applicationWindow frame].size.height;
			
			if (scrollView.center.y > viewHalfHeight+30)
				finalY = windowsHeigt*2;
			else
				finalY = -viewHalfHeight;
			
			CGFloat animationDuration = 0.35;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:animationDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
			[UIView setAnimationDelegate:self];
			[scrollView setCenter:CGPointMake(finalX, finalY)];
			self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
			[UIView commitAnimations];
			
			[self performSelector:@selector(doneButtonPressed:) withObject:self afterDelay:animationDuration];
		}
		else
		{
			_isdraggingPhoto = NO;
			[self setNeedsStatusBarAppearanceUpdate];
			
			self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
			
			CGFloat velocityY = (.35*[(UIPanGestureRecognizer*)sender velocityInView:self.view].y);
			
			CGFloat finalX = firstX;
			CGFloat finalY = viewHalfHeight;
			
			CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:animationDuration];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDelegate:self];
			[scrollView setCenter:CGPointMake(finalX, finalY)];
			[UIView commitAnimations];
		}
	}
}

#pragma mark - Animation

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage*)rotateImageToCurrentOrientation:(UIImage*)image
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation))
	{
		UIImageOrientation orientation = ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationLandscapeLeft) ?UIImageOrientationLeft : UIImageOrientationRight;
		
		UIImage *rotatedImage = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:orientation];
		image = rotatedImage;
	}
	
	return image;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)performPresentAnimation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.view.alpha = 0.0f;
	
	UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
	imageFromView = [self rotateImageToCurrentOrientation:imageFromView];
	
	_senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
	
	CGRect screenBound = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth = screenBound.size.width;
	CGFloat screenHeight = screenBound.size.height;
	
	UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	fadeView.backgroundColor = [UIColor clearColor];
	[_applicationWindow addSubview:fadeView];
	
	UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
	resizableImageView.frame = _senderViewOriginalFrame;
	resizableImageView.clipsToBounds = YES;
	resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
	resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
	[_applicationWindow addSubview:resizableImageView];
	_senderViewForAnimation.hidden = YES;
	
	void (^completion)() = ^() {
		self.view.alpha = 1.0f;
		resizableImageView.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
		[fadeView removeFromSuperview];
		[resizableImageView removeFromSuperview];
	};
	
	[UIView animateWithDuration:_animationDuration animations:^{
		fadeView.backgroundColor = [UIColor blackColor];
	} completion:nil];
	
	float scaleFactor = (imageFromView ? imageFromView.size.width : screenWidth) / screenWidth;
	CGRect finalImageViewFrame = CGRectMake(0, (screenHeight/2)-((imageFromView.size.height / scaleFactor)/2), screenWidth, imageFromView.size.height / scaleFactor);
	
	[UIView animateWithDuration:_animationDuration animations:^{
		resizableImageView.layer.frame = finalImageViewFrame;
	} completion:^(BOOL finished) {
		completion();
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)performCloseAnimationWithScrollView:(IDMZoomingScrollView*)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	float fadeAlpha = 1 - fabs(scrollView.frame.origin.y)/scrollView.frame.size.height;
	
	UIImage *imageFromView = [scrollView.photo underlyingImage];
	
	CGRect screenBound = [[UIScreen mainScreen] bounds];
	CGFloat screenWidth = screenBound.size.width;
	CGFloat screenHeight = screenBound.size.height;
	
	float scaleFactor = imageFromView.size.width / screenWidth;
	
	UIView *fadeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
	fadeView.backgroundColor = [UIColor blackColor];
	fadeView.alpha = fadeAlpha;
	[_applicationWindow addSubview:fadeView];
	
	UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
	resizableImageView.frame = (imageFromView) ? CGRectMake(0, (screenHeight/2)-((imageFromView.size.height / scaleFactor)/2)+scrollView.frame.origin.y, screenWidth, imageFromView.size.height / scaleFactor) : CGRectZero;
	resizableImageView.contentMode = UIViewContentModeScaleAspectFill;
	resizableImageView.backgroundColor = [UIColor clearColor];
	resizableImageView.clipsToBounds = YES;
	[_applicationWindow addSubview:resizableImageView];
	self.view.hidden = YES;
	
	void (^completion)() = ^() {
		_senderViewForAnimation.hidden = NO;
		_senderViewForAnimation = nil;
		_scaleImage = nil;
		
		[fadeView removeFromSuperview];
		[resizableImageView removeFromSuperview];
		
		[self prepareForClosePhotoBrowser];
		[self dismissPhotoBrowserAnimated:YES];
	};
	
	[UIView animateWithDuration:_animationDuration animations:^{
		fadeView.alpha = 0;
		self.view.backgroundColor = [UIColor clearColor];
	} completion:nil];
	
	[UIView animateWithDuration:_animationDuration animations:^{
		resizableImageView.layer.frame = _senderViewOriginalFrame;
	} completion:^(BOOL finished) {
		completion();
	}];
}

#pragma mark - Genaral

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)prepareForClosePhotoBrowser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[_applicationWindow removeGestureRecognizer:_panGesture];

	[NSObject cancelPreviousPerformRequestsWithTarget:self];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissPhotoBrowserAnimated:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
	
	[self dismissViewControllerAnimated:animated completion:^{
		if (SYSTEM_VERSION_LESS_THAN(@"8.0"))
		{
			_applicationTopViewController.modalPresentationStyle = _previousModalPresentationStyle;
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage*)getImageFromView:(UIView *)view
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIViewController *)topviewController
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIViewController *topviewController = [UIApplication sharedApplication].keyWindow.rootViewController;
	
	while (topviewController.presentedViewController)
	{
		topviewController = topviewController.presentedViewController;
	}
	
	return topviewController;
}

#pragma mark - View Lifecycle

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self performPresentAnimation];

	self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
	
	self.view.clipsToBounds = YES;

	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
	_pagingScrollView = [[UIScrollView alloc] initWithFrame:pagingScrollViewFrame];
	_pagingScrollView.pagingEnabled = YES;
	_pagingScrollView.delegate = self;
	_pagingScrollView.showsHorizontalScrollIndicator = NO;
	_pagingScrollView.showsVerticalScrollIndicator = NO;
	_pagingScrollView.backgroundColor = [UIColor clearColor];
	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
	[self.view addSubview:_pagingScrollView];

	_panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
	[_panGesture setMinimumNumberOfTouches:1];
	[_panGesture setMaximumNumberOfTouches:1];

	[super viewDidLoad];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self reloadData];

	[super viewWillAppear:animated];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	_viewIsActive = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidUnload
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_currentPageIndex = 0;
	_pagingScrollView = nil;
	_visiblePages = nil;
	_recycledPages = nil;
	
	[super viewDidUnload];
}

#pragma mark - Status Bar

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIStatusBarStyle)preferredStatusBarStyle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)prefersStatusBarHidden
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (_isdraggingPhoto)
	{
		return NO;
	}
	else return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIStatusBarAnimationFade;
}

#pragma mark - Layout

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillLayoutSubviews
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_performingLayout = YES;

	NSUInteger indexPriorToLayout = _currentPageIndex;

	CGRect pagingScrollViewFrame = [self frameForPagingScrollView];

	_pagingScrollView.frame = pagingScrollViewFrame;

	_pagingScrollView.contentSize = [self contentSizeForPagingScrollView];

	for (IDMZoomingScrollView *page in _visiblePages)
	{
		NSUInteger index = PAGE_INDEX(page);
		page.frame = [self frameForPageAtIndex:index];
		[page setMaxMinZoomScalesForCurrentBounds];
	}

	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
	[self didStartViewingPageAtIndex:_currentPageIndex];

	_currentPageIndex = indexPriorToLayout;
	_performingLayout = NO;

	[super viewWillLayoutSubviews];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)performLayout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_performingLayout = YES;

	[_visiblePages removeAllObjects];
	[_recycledPages removeAllObjects];

	_pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
	[self tilePages];
	_performingLayout = NO;
	
	[self.view addGestureRecognizer:_panGesture];
}

#pragma mark - Data

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)reloadData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self releaseAllUnderlyingPhotos];

	[self performLayout];

	[self.view setNeedsLayout];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)numberOfPhotos
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return _photos.count;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<IDMPhoto>)photoAtIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return _photos[index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImage *)imageForPhoto:(id<IDMPhoto>)photo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (photo)
	{
		if ([photo underlyingImage])
		{
			return [photo underlyingImage];
		}
	}
	return nil;
}
#pragma mark - Paging

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tilePages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger iFirstIndex = (NSInteger) floorf((CGRectGetMinX(visibleBounds)+PADDING*2) / CGRectGetWidth(visibleBounds));
	NSInteger iLastIndex  = (NSInteger) floorf((CGRectGetMaxX(visibleBounds)-PADDING*2-1) / CGRectGetWidth(visibleBounds));
	if (iFirstIndex < 0) iFirstIndex = 0;
	if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
	if (iLastIndex < 0) iLastIndex = 0;
	if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;

	NSInteger pageIndex;
	for (IDMZoomingScrollView *page in _visiblePages)
	{
		pageIndex = PAGE_INDEX(page);
		if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex)
		{
			[_recycledPages addObject:page];
			[page prepareForReuse];
			[page removeFromSuperview];
		}
	}
	[_visiblePages minusSet:_recycledPages];
	while (_recycledPages.count > 2)
		[_recycledPages removeObject:[_recycledPages anyObject]];

	for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++)
	{
		if (![self isDisplayingPageForIndex:index])
		{
			IDMZoomingScrollView *page;
			page = [[IDMZoomingScrollView alloc] initWithPhotoBrowser:self];
			page.backgroundColor = [UIColor clearColor];
			page.opaque = YES;
			
			[self configurePage:page forIndex:index];
			[_visiblePages addObject:page];
			[_pagingScrollView addSubview:page];
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (IDMZoomingScrollView *page in _visiblePages)
		if (PAGE_INDEX(page) == index) return YES;
	return NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IDMZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IDMZoomingScrollView *thePage = nil;
	for (IDMZoomingScrollView *page in _visiblePages)
	{
		if (PAGE_INDEX(page) == index)
		{
			thePage = page; break;
		}
	}
	return thePage;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IDMZoomingScrollView *)pageDisplayingPhoto:(id<IDMPhoto>)photo
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IDMZoomingScrollView *thePage = nil;
	for (IDMZoomingScrollView *page in _visiblePages)
	{
		if (page.photo == photo)
		{
			thePage = page; break;
		}
	}
	return thePage;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)configurePage:(IDMZoomingScrollView *)page forIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	page.frame = [self frameForPageAtIndex:index];
	page.tag = PAGE_INDEX_TAG_OFFSET + index;
	page.photo = [self photoAtIndex:index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IDMZoomingScrollView *)dequeueRecycledPage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	IDMZoomingScrollView *page = [_recycledPages anyObject];
	if (page)
	{
		[_recycledPages removeObject:page];
	}
	return page;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didStartViewingPageAtIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - Frame Calculations

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGRect)frameForPagingScrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect frame = self.view.bounds;
	frame.origin.x -= PADDING;
	frame.size.width += (2 * PADDING);
	return frame;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGRect)frameForPageAtIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect bounds = _pagingScrollView.bounds;
	CGRect pageFrame = bounds;
	pageFrame.size.width -= (2 * PADDING);
	pageFrame.origin.x = (bounds.size.width * index) + PADDING;
	return pageFrame;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGSize)contentSizeForPagingScrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGRect bounds = _pagingScrollView.bounds;
	return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGFloat pageWidth = _pagingScrollView.bounds.size.width;
	CGFloat newOffset = index * pageWidth;
	return CGPointMake(newOffset, 0);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isLandscape:(UIInterfaceOrientation)orientation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return UIInterfaceOrientationIsLandscape(orientation);
}

#pragma mark - UIScrollView Delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (!_viewIsActive || _performingLayout || _rotating) return;

	[self tilePages];

	CGRect visibleBounds = _pagingScrollView.bounds;
	NSInteger index = (NSInteger) (floorf(CGRectGetMidX(visibleBounds) / CGRectGetWidth(visibleBounds)));
	if (index < 0) index = 0;
	if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
	NSUInteger previousCurrentPage = _currentPageIndex;
	_currentPageIndex = index;
	if (_currentPageIndex != previousCurrentPage)
	{
		[self didStartViewingPageAtIndex:index];
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

#pragma mark - Buttons

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)doneButtonPressed:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex)
	{
		IDMZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
		[self performCloseAnimationWithScrollView:scrollView];
	}
	else
	{
		_senderViewForAnimation.hidden = NO;
		[self prepareForClosePhotoBrowser];
		[self dismissPhotoBrowserAnimated:YES];
	}
}

@end
