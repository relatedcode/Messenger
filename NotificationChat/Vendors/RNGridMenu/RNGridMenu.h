//
//  RNGridMenu.h
//  RNGridMenu
//
//  Created by Ryan Nystrom on 6/11/13.
//  Copyright (c) 2013 Ryan Nystrom. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef NS_ENUM(NSInteger, RNGridMenuStyle) {
    RNGridMenuStyleGrid,
    RNGridMenuStyleList
};


@class RNGridMenu;

@interface RNGridMenuItem : NSObject

@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, readonly) NSString *title;

@property (nonatomic, copy) dispatch_block_t action;

+ (instancetype)emptyItem;

- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title action:(dispatch_block_t)action;
- (instancetype)initWithImage:(UIImage *)image title:(NSString *)title;
- (instancetype)initWithImage:(UIImage *)image;
- (instancetype)initWithTitle:(NSString *)title;

- (BOOL)isEmpty;

@end

@protocol RNGridMenuDelegate <NSObject>
@optional
- (void)gridMenu:(RNGridMenu *)gridMenu willDismissWithSelectedItem:(RNGridMenuItem *)item atIndex:(NSInteger)itemIndex;
- (void)gridMenuWillDismiss:(RNGridMenu *)gridMenu;
@end


@interface RNGridMenu : UIViewController

+ (instancetype)visibleGridMenu;

@property (nonatomic, readonly) UIView *menuView;

// the menu items. Instances of RNGridMenuItem
@property (nonatomic, readonly) NSArray *items;

// An optional delegate to receive information about what items were selected
@property (nonatomic, weak) id<RNGridMenuDelegate> delegate;

// The color that items will be highlighted with on selection.
// default table view selection blue
@property (nonatomic, strong) UIColor *highlightColor;

// The background color of the main view (note this is a UIViewController subclass)
// default black with 0.7 alpha
@property (nonatomic, strong) UIColor *backgroundColor;

// defaults to nil, the path to be applied as a mask to the background image. if this path is set, cornerRadius is ignored
@property (nonatomic, strong) UIBezierPath *backgroundPath;

// defaults to 8 (only applied if backgroundPath == nil)
@property (nonatomic, assign) CGFloat cornerRadius;

// The size of an item
// default {100, 100}
@property (nonatomic, assign) CGSize itemSize;

// The level of blur for the background image. Range is 0.0 to 1.0
// default 0.3
@property (nonatomic, assign) CGFloat blurLevel;
// defaults to nil ( == the whole background gets blurred)
@property (nonatomic, strong) UIBezierPath *blurExclusionPath;

// The time in seconds for the show and dismiss animation
// default 0.25f
@property (nonatomic, assign) CGFloat animationDuration;

// The text color for list items
// default white
@property (nonatomic, strong) UIColor *itemTextColor;

// The font used for list items
// default bold size 14
@property (nonatomic, strong) UIFont *itemFont;

// The text alignment of the item titles
// default center
@property (nonatomic, assign) NSTextAlignment itemTextAlignment;

// The list layout
// default RNGridMenuStyleGrid
@property (nonatomic, assign) RNGridMenuStyle menuStyle;

// An optional header view. Make sure to set the frame height when setting.
@property (nonatomic, strong) UIView *headerView;

// An optional block that gets executed before the gridMenu gets dismissed
@property (nonatomic, copy) dispatch_block_t dismissAction;

// Determine whether or not to bounce in the animation
// default YES
@property (nonatomic, assign) BOOL bounces;

// Initialize the menu with a list of menu items.
// Note: this changes the view to style RNGridMenuStyleList if no images are supplied
- (instancetype)initWithItems:(NSArray *)items;
// Initialize the menu with a list of images. Maintains style RNGridMenuStyleGrid
- (instancetype)initWithImages:(NSArray *)images;
// Initialize the menu with a list of titles. Note: this changes the view to style RNGridMenuStyleList since no images are supplied
- (instancetype)initWithTitles:(NSArray *)titles;

// Show the menu
- (void)showInViewController:(UIViewController *)parentViewController center:(CGPoint)center;

// Dismiss the menu
// This is called when the window is tapped. If tapped inside the view an item will be selected.
// If tapped outside the view, the menu is simply dismissed.
- (void)dismissAnimated:(BOOL)animated;

@end


@interface RNLongPressGestureRecognizer : UILongPressGestureRecognizer

@end
