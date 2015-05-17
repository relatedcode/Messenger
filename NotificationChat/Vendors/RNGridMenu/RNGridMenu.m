//
//  RNGridMenu.m
//  RNGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import "RNGridMenu.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

CGFloat const kRNGridMenuDefaultDuration = 0.25f;
CGFloat const kRNGridMenuDefaultBlur = 0.3f;
CGFloat const kRNGridMenuDefaultWidth = 280;

#pragma mark - Functions

CGPoint RNCentroidOfTouchesInView(NSSet *touches, UIView *view) {
    CGFloat sumX = 0.f;
    CGFloat sumY = 0.f;

    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:view];
        sumX += location.x;
        sumY += location.y;
    }

    return CGPointMake((CGFloat)round(sumX / touches.count), (CGFloat)round(sumY / touches.count));
}

#pragma mark - Categories

@implementation UIView (Screenshot)

- (UIImage *)rn_screenshot {
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    // helps w/ our colors when blurring
    // feel free to adjust jpeg quality (lower = higher perf)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    image = [UIImage imageWithData:imageData];

    return image;
}

- (UIImage *)rn_screenshotForScrollViewWithContentOffset:(CGPoint)contentOffset {
    UIGraphicsBeginImageContext(self.bounds.size);
    //need to translate the context down to the current visible portion of the scrollview
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, -contentOffset.y);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // helps w/ our colors when blurring
    // feel free to adjust jpeg quality (lower = higher perf)
    NSData *imageData = UIImageJPEGRepresentation(image, 0.55);
    image = [UIImage imageWithData:imageData];
    
    return image;
}

@end


@implementation UIImage (Blur)

-(UIImage *)rn_boxblurImageWithBlur:(CGFloat)blur exclusionPath:(UIBezierPath *)exclusionPath {
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }

    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;

    CGImageRef img = self.CGImage;
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;

    // create unchanged copy of the area inside the exclusionPath
    UIImage *unblurredImage = nil;
    if (exclusionPath != nil) {
        CAShapeLayer *maskLayer = [CAShapeLayer new];
        maskLayer.frame = (CGRect){CGPointZero, self.size};
        maskLayer.backgroundColor = [UIColor blackColor].CGColor;
        maskLayer.fillColor = [UIColor whiteColor].CGColor;
        maskLayer.path = exclusionPath.CGPath;

        // create grayscale image to mask context
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef context = CGBitmapContextCreate(nil, maskLayer.bounds.size.width, maskLayer.bounds.size.height, 8, 0, colorSpace,
													 (CGBitmapInfo) kCGImageAlphaNone);
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        [maskLayer renderInContext:context];
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage *maskImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);

        UIGraphicsBeginImageContext(self.size);
        context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, maskLayer.bounds.size.height);
        CGContextScaleCTM(context, 1.f, -1.f);
        CGContextClipToMask(context, maskLayer.bounds, maskImage.CGImage);
        CGContextDrawImage(context, maskLayer.bounds, self.CGImage);
        unblurredImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    //create vImage_Buffer with data from CGImageRef
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);

    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);

    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);

    //create vImage_Buffer for output
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));

    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");

    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);

    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);

    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);

    if (error) {
        NSLog(@"error from convolution %ld", error);
    }

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo) kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];

    // overlay images?
    if (unblurredImage != nil) {
        UIGraphicsBeginImageContext(returnImage.size);
        [returnImage drawAtPoint:CGPointZero];
        [unblurredImage drawAtPoint:CGPointZero];

        returnImage = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();
    }

    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);

    return returnImage;
}

@end

#pragma mark - RNMenuItemView

@interface RNMenuItemView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) NSInteger itemIndex;

@end


@implementation RNMenuItemView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor clearColor];


        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect frame = self.bounds;
    CGFloat inset = floorf(CGRectGetHeight(frame) * 0.1f);

    BOOL hasImage = self.imageView.image != nil;
    BOOL hasText = [self.titleLabel.text length] > 0;

    if (hasImage) {
        CGFloat y = 0;
        CGFloat height = CGRectGetHeight(frame);
        if (hasText) {
            y = inset / 2;
            height = floorf(CGRectGetHeight(frame) * 2/3.f);
        }
        self.imageView.frame = CGRectInset(CGRectMake(0, y, CGRectGetWidth(frame), height), inset, inset);
    }
    else {
        self.imageView.frame = CGRectZero;
    }

    if (hasText) {
        CGFloat y = 0;
        CGFloat height = CGRectGetHeight(frame);
        CGFloat left = 0;
        if (hasImage) {
            y = floorf(CGRectGetHeight(frame) * 2/3.f) - inset / 2;
            height = floorf(CGRectGetHeight(frame) / 3.f);
        }
        if (self.titleLabel.textAlignment == NSTextAlignmentLeft) {
            left = 10;
        }
        self.titleLabel.frame = CGRectMake(left, y, CGRectGetWidth(frame), height);
    }
    else {
        self.titleLabel.frame = CGRectZero;
    }
}

@end

#pragma mark - RNGridMenuItem

@implementation RNGridMenuItem

+ (instancetype)emptyItem {
    static RNGridMenuItem *emptyItem = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emptyItem = [[RNGridMenuItem alloc] initWithImage:nil title:nil action:nil];
    });

    return emptyItem;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title action:(dispatch_block_t)action {
    if ((self = [super init])) {
        _image = image;
        _title = [title copy];
        _action = [action copy];
    }

    return self;
}

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title {
    return [self initWithImage:image title:title action:nil];
}

- (instancetype)initWithImage:(UIImage *)image {
    return [self initWithImage:image title:nil action:nil];
}

- (instancetype)initWithTitle:(NSString *)title {
    return [self initWithImage:nil title:title action:nil];
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:[RNGridMenuItem class]]) {
        return NO;
    }

    return ((self.title == [object title] || [self.title isEqualToString:[object title]]) &&
            (self.image == [object image]));
}

- (NSUInteger)hash {
    return self.title.hash;
}

- (BOOL)isEmpty {
    return [self isEqual:[[self class] emptyItem]];
}

@end

#pragma mark - RNGridMenu

@interface RNGridMenu ()

@property (nonatomic, assign) CGPoint menuCenter;
@property (nonatomic, strong) NSMutableArray *itemViews;
@property (nonatomic, strong) RNMenuItemView *selectedItemView;
@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, assign) BOOL parentViewCouldScroll;

@end

static RNGridMenu *rn_visibleGridMenu;

@implementation RNGridMenu

#pragma mark - Lifecycle

+ (instancetype)visibleGridMenu {
    return rn_visibleGridMenu;
}

- (instancetype)initWithItems:(NSArray *)items {
    if ((self = [super init])) {
        _itemSize = CGSizeMake(100.f, 100.f);
        _cornerRadius = 8.f;
        _blurLevel = kRNGridMenuDefaultBlur;
        _animationDuration = kRNGridMenuDefaultDuration;
        _itemTextColor = [UIColor whiteColor];
        _itemFont = [UIFont boldSystemFontOfSize:14.f];
        _highlightColor = [UIColor colorWithRed:.02f green:.549f blue:.961f alpha:1.f];
        _menuStyle = RNGridMenuStyleGrid;
        _itemTextAlignment = NSTextAlignmentCenter;
        _menuView = [UIView new];
        _backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        _bounces = YES;

        BOOL hasImages = [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RNGridMenuItem *item, NSDictionary *bindings) {
            return item.image != nil;
        }]].count > 0;
        _menuStyle = hasImages ? RNGridMenuStyleGrid : RNGridMenuStyleList;
        _items = [items copy];

        [self setupItemViews];
    }

    return self;
}

- (instancetype)initWithImages:(NSArray *)images {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:images.count];
    for (UIImage *image in images) {
        RNGridMenuItem *item = [[RNGridMenuItem alloc] initWithImage:image];
        [items addObject:item];
    }

    return [self initWithItems:items];
}

- (instancetype)initWithTitles:(NSArray *)titles {
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSString *title in titles) {
        RNGridMenuItem *item = [[RNGridMenuItem alloc] initWithTitle:title];
        [items addObject:item];
    }

    return [self initWithItems:items];
}

- (instancetype)init {
    NSAssert(NO, @"Unable to create with plain init.");
    return nil;
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = RNCentroidOfTouchesInView(touches, self.view);

    [self selectItemViewAtPoint:point];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    CGPoint point = RNCentroidOfTouchesInView(touches, self.view);

    [self selectItemViewAtPoint:point];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    id<RNGridMenuDelegate> delegate = self.delegate;

    if (self.selectedItemView != nil) {
        RNGridMenuItem *item = self.items[self.selectedItemView.itemIndex];

        if ([delegate respondsToSelector:@selector(gridMenu:willDismissWithSelectedItem:atIndex:)]) {
            [delegate gridMenu:self
   willDismissWithSelectedItem:item
                       atIndex:self.selectedItemView.itemIndex];
        }

        if (item.action != nil) {
            item.action();
        }
    } else {
        if ([delegate respondsToSelector:@selector(gridMenuWillDismiss:)]) {
            [delegate gridMenuWillDismiss:self];
        }
    }

    [self dismissAnimated:YES];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.selectedItemView.backgroundColor = [UIColor clearColor];
    self.selectedItemView = nil;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.menuView.backgroundColor = self.backgroundColor;
    self.menuView.opaque = NO;
    self.menuView.clipsToBounds = YES;

    CGFloat m34 = 1 / 300.f;
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = m34;
    self.menuView.layer.transform = transform;

    if (self.backgroundPath != nil) {
        CAShapeLayer *maskLayer = [CAShapeLayer new];
        maskLayer.frame = self.menuView.frame;
        maskLayer.transform = self.menuView.layer.transform;
        maskLayer.path = self.backgroundPath.CGPath;
        self.menuView.layer.mask = maskLayer;
    } else {
        self.menuView.layer.cornerRadius = self.cornerRadius;
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];

    CGRect bounds = self.view.bounds;
    self.blurView.frame = bounds;

    [self styleItemViews];

    if (self.menuStyle == RNGridMenuStyleGrid) {
        [self layoutAsGrid];
    }
    else if (self.menuStyle == RNGridMenuStyleList) {
        [self layoutAsList];
    }

    CGRect headerFrame = self.headerView.frame;
    headerFrame.size.width = self.menuView.bounds.size.width;
    headerFrame.origin = CGPointZero;
    self.headerView.frame = headerFrame;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];

    if ([self isViewLoaded] && self.view.window != nil) {
        [self createScreenshotAndLayoutWithScreenshotCompletion:nil];
    }
}

#pragma mark - Actions

- (void)setupItemViews {
    self.itemViews = [NSMutableArray array];

    [self.items enumerateObjectsUsingBlock:^(RNGridMenuItem *item, NSUInteger idx, BOOL *stop) {
        RNMenuItemView *itemView = [[RNMenuItemView alloc] init];
        itemView.imageView.image = item.image;
        itemView.titleLabel.text = item.title;
        itemView.itemIndex = idx;

        [self.menuView addSubview:itemView];
        [self.itemViews addObject:itemView];
    }];
}

#pragma mark - Layout

- (void)styleItemViews {
    [self.itemViews enumerateObjectsUsingBlock:^(RNMenuItemView *itemView, NSUInteger idx, BOOL *stop) {
        itemView.titleLabel.textColor = self.itemTextColor;
        itemView.titleLabel.textAlignment = self.itemTextAlignment;
        itemView.titleLabel.font = self.itemFont;
    }];
}

- (void)layoutAsList {
    CGFloat width = self.itemSize.width;
    CGFloat height = self.itemSize.height * self.items.count;
    CGFloat headerOffset = CGRectGetHeight(self.headerView.bounds);

    self.menuView.frame = [self menuFrameWithWidth:width height:height center:self.menuCenter headerOffset:headerOffset];

    [self.itemViews enumerateObjectsUsingBlock:^(RNMenuItemView *itemView, NSUInteger idx, BOOL *stop) {
        itemView.frame = CGRectMake(0, idx * self.itemSize.height + headerOffset, self.itemSize.width, self.itemSize.height);
    }];
}

- (void)layoutAsGrid {
    NSInteger itemCount = self.items.count;
    NSInteger rowCount = ceilf(sqrtf(itemCount));

    CGFloat height = self.itemSize.height * rowCount;
    CGFloat width = self.itemSize.width * ceilf(itemCount / (CGFloat)rowCount);
    CGFloat itemHeight = floorf(height / (CGFloat)rowCount);
    CGFloat headerOffset = self.headerView.bounds.size.height;

    self.menuView.frame = [self menuFrameWithWidth:width height:height center:self.menuCenter headerOffset:headerOffset];

    for (NSInteger i = 0; i < rowCount; i++) {
        NSInteger rowLength = ceilf(itemCount / (CGFloat)rowCount);
        NSInteger rowStartIndex = i * rowLength;

        //NSInteger offset = 0;
        if ((i + 1) * rowLength > itemCount) {
            rowLength = itemCount - i * rowLength;
        }
        NSArray *subItems = [self.itemViews subarrayWithRange:NSMakeRange(rowStartIndex, rowLength)];
        CGFloat itemWidth = floorf(width / (CGFloat)rowLength);
        [subItems enumerateObjectsUsingBlock:^(RNMenuItemView *itemView, NSUInteger idx, BOOL *stop) {
            itemView.frame = CGRectMake(idx * itemWidth, i * itemHeight + headerOffset, itemWidth, itemHeight);
        }];
    }
}

- (void)createScreenshotAndLayoutWithScreenshotCompletion:(dispatch_block_t)screenshotCompletion {
    if (self.blurLevel > 0.f) {
        self.blurView.alpha = 0.f;

        self.menuView.alpha = 0.f;
        UIImage *screenshot = ([self.parentViewController.view isKindOfClass:[UIScrollView class]] ?
                               [self.parentViewController.view rn_screenshotForScrollViewWithContentOffset:[(UIScrollView *)self.parentViewController.view contentOffset]] :
                               [self.parentViewController.view rn_screenshot]);        
        self.menuView.alpha = 1.f;
        self.blurView.alpha = 1.f;
        self.blurView.layer.contents = (id)screenshot.CGImage;

        if (screenshotCompletion != nil) {
            screenshotCompletion();
        }

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0L), ^{
            UIImage *blur = [screenshot rn_boxblurImageWithBlur:self.blurLevel exclusionPath:self.blurExclusionPath];

            dispatch_async(dispatch_get_main_queue(), ^{
                CATransition *transition = [CATransition animation];

                transition.duration = 0.2;
                transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                transition.type = kCATransitionFade;

                [self.blurView.layer addAnimation:transition forKey:nil];
                self.blurView.layer.contents = (id)blur.CGImage;

                [self.view setNeedsLayout];
                [self.view layoutIfNeeded];
            });
        });
    }
}

#pragma mark - Animations

- (void)showInViewController:(UIViewController *)parentViewController center:(CGPoint)center {
    NSParameterAssert(parentViewController != nil);

    if (rn_visibleGridMenu != nil) {
        [rn_visibleGridMenu dismissAnimated:NO];
    }

    [self rn_addToParentViewController:parentViewController callingAppearanceMethods:YES];
    self.menuCenter = [self.view convertPoint:center toView:self.view];
    self.view.frame = parentViewController.view.bounds;

    [self showAnimated:YES];
}

- (void)showAnimated:(BOOL)animated {
    rn_visibleGridMenu = self;

    self.blurView = [[UIView alloc] initWithFrame:self.parentViewController.view.bounds];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.blurView];
    [self.view addSubview:self.menuView];
    if (self.headerView) {
        [self.menuView addSubview:self.headerView];
    }

    [self createScreenshotAndLayoutWithScreenshotCompletion:^{
        if (animated) {
            CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
            opacityAnimation.fromValue = @0.;
            opacityAnimation.toValue = @1.;
            opacityAnimation.duration = self.animationDuration * 0.5f;

            CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];

            CATransform3D startingScale = CATransform3DScale(self.menuView.layer.transform, 0, 0, 0);
            CATransform3D overshootScale = CATransform3DScale(self.menuView.layer.transform, 1.05, 1.05, 1.0);
            CATransform3D undershootScale = CATransform3DScale(self.menuView.layer.transform, 0.98, 0.98, 1.0);
            CATransform3D endingScale = self.menuView.layer.transform;

            NSMutableArray *scaleValues = [NSMutableArray arrayWithObject:[NSValue valueWithCATransform3D:startingScale]];
            NSMutableArray *keyTimes = [NSMutableArray arrayWithObject:@0.0f];
            NSMutableArray *timingFunctions = [NSMutableArray arrayWithObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];

            if (self.bounces) {
                [scaleValues addObjectsFromArray:@[[NSValue valueWithCATransform3D:overshootScale], [NSValue valueWithCATransform3D:undershootScale]]];
                [keyTimes addObjectsFromArray:@[@0.5f, @0.85f]];
                [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            }

            [scaleValues addObject:[NSValue valueWithCATransform3D:endingScale]];
            [keyTimes addObject:@1.0f];
            [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];

            scaleAnimation.values = scaleValues;
            scaleAnimation.keyTimes = keyTimes;
            scaleAnimation.timingFunctions = timingFunctions;

            CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
            animationGroup.animations = @[scaleAnimation, opacityAnimation];
            animationGroup.duration = self.animationDuration;

            [self.menuView.layer addAnimation:animationGroup forKey:nil];
        }
    }];
}

- (void)dismissAnimated:(BOOL)animated {
    if (self.dismissAction != nil) {
        self.dismissAction();
    }

    if (animated) {
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @1.;
        opacityAnimation.toValue = @0.;
        opacityAnimation.duration = self.animationDuration;
        [self.blurView.layer addAnimation:opacityAnimation forKey:nil];

        CATransform3D transform = CATransform3DScale(self.menuView.layer.transform, 0, 0, 0);

        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        scaleAnimation.fromValue = [NSValue valueWithCATransform3D:self.menuView.layer.transform];
        scaleAnimation.toValue = [NSValue valueWithCATransform3D:transform];
        scaleAnimation.duration = self.animationDuration;

        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.animations = @[opacityAnimation, scaleAnimation];
        animationGroup.duration = self.animationDuration;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [self.menuView.layer addAnimation:animationGroup forKey:nil];

        self.blurView.layer.opacity = 0;
        self.menuView.layer.transform = transform;
        [self performSelector:@selector(cleanupGridMenu) withObject:nil afterDelay:self.animationDuration];
    } else {
        self.view.hidden = YES;
        [self cleanupGridMenu];
    }

    rn_visibleGridMenu = nil;
}

- (void)cleanupGridMenu {
    self.selectedItemView = nil;
    [self rn_removeFromParentViewControllerCallingAppearanceMethods:YES];
}

#pragma mark - Private

- (void)rn_addToParentViewController:(UIViewController *)parentViewController callingAppearanceMethods:(BOOL)callAppearanceMethods {
    if (self.parentViewController != nil) {
        [self rn_removeFromParentViewControllerCallingAppearanceMethods:callAppearanceMethods];
    }

    if (callAppearanceMethods) [self beginAppearanceTransition:YES animated:NO];
    [parentViewController addChildViewController:self];
    [parentViewController.view addSubview:self.view];
    [self didMoveToParentViewController:self];
    if (callAppearanceMethods) [self endAppearanceTransition];
    
    if ([parentViewController.view respondsToSelector:@selector(setScrollEnabled:)] && [(UIScrollView *)parentViewController.view isScrollEnabled]) {
        self.parentViewCouldScroll = YES;
        [(UIScrollView *)parentViewController.view setScrollEnabled:NO];
    }
}

- (void)rn_removeFromParentViewControllerCallingAppearanceMethods:(BOOL)callAppearanceMethods {
    if (self.parentViewCouldScroll) {
        [(UIScrollView *)self.parentViewController.view setScrollEnabled:YES];
        self.parentViewCouldScroll = NO;
    }
    
    if (callAppearanceMethods) [self beginAppearanceTransition:NO animated:NO];
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
    if (callAppearanceMethods) [self endAppearanceTransition];
}


- (RNMenuItemView *)itemViewAtPoint:(CGPoint)point {
    RNMenuItemView *selectedView = nil;

    if (CGRectContainsPoint(self.menuView.frame, point)) {
        point =  [self.view convertPoint:point toView:self.menuView];
        selectedView = [[self.itemViews filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(RNMenuItemView *itemView, NSDictionary *bindings) {
            return CGRectContainsPoint(itemView.frame, point);
        }]] lastObject];
    }

    return selectedView;
}

- (void)selectItemViewAtPoint:(CGPoint)point {
    RNMenuItemView *selectedItemView = [self itemViewAtPoint:point];
    RNGridMenuItem *item = self.items[selectedItemView.itemIndex];

    if (selectedItemView != self.selectedItemView) {
        self.selectedItemView.backgroundColor = [UIColor clearColor];
    }

    if (![item isEmpty]) {
        selectedItemView.backgroundColor = self.highlightColor;
        self.selectedItemView = selectedItemView;
    } else {
        self.selectedItemView = nil;
    }
}

- (CGRect)menuFrameWithWidth:(CGFloat)width height:(CGFloat)height center:(CGPoint)center headerOffset:(CGFloat)headerOffset {
    height += headerOffset;

    CGRect frame = CGRectMake(center.x - width/2.f, center.y - height/2.f, width, height);

    CGFloat offsetX = 0.f;
    CGFloat offsetY = 0.f;

    // make sure frame doesn't exceed views bounds
    {
        CGFloat tempOffset = CGRectGetMinX(frame) - CGRectGetMinX(self.view.bounds);
        if (tempOffset < 0.f) {
            offsetX = -tempOffset;
        } else {
            tempOffset = CGRectGetMaxX(frame) - CGRectGetMaxX(self.view.bounds);
            if (tempOffset > 0.f) {
                offsetX = -tempOffset;
            }
        }

        tempOffset = CGRectGetMinY(frame) - CGRectGetMinY(self.view.bounds);
        if (tempOffset < 0.f) {
            offsetY = -tempOffset;
        } else {
            tempOffset = CGRectGetMaxY(frame) - CGRectGetMaxY(self.view.bounds);
            if (tempOffset > 0.f) {
                offsetY = -tempOffset;
            }
        }

        frame = CGRectOffset(frame, offsetX, offsetY);
    }

    return CGRectIntegral(frame);
}

@end


#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation RNLongPressGestureRecognizer {
    BOOL _touchesDidMove;
    CGPoint _startLocation;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];

    _touchesDidMove = NO;
    _startLocation = [[touches anyObject] locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];

    if (!_touchesDidMove) {
        // detect if touches moved at least self.allowableMovement
        CGPoint location = [[touches anyObject] locationInView:self.view];
        CGFloat distanceSquared = (location.x - _startLocation.x) * (location.x - _startLocation.x) + (location.y - _startLocation.y) * (location.y - _startLocation.y);

        if (distanceSquared >= self.allowableMovement * self.allowableMovement) {
            _touchesDidMove = YES;
        }
    }

    if (_touchesDidMove) {
        RNGridMenu *menu = [RNGridMenu visibleGridMenu];
        [menu touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    if (_touchesDidMove) {
        RNGridMenu *menu = [RNGridMenu visibleGridMenu];
        [menu touchesEnded:touches withEvent:event];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    
    if (_touchesDidMove) {
        RNGridMenu *menu = [RNGridMenu visibleGridMenu];
        [menu touchesCancelled:touches withEvent:event];
    }
}

@end

