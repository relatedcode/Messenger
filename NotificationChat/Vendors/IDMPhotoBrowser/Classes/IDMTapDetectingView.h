//
//  IDMTapDetectingView.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDMTapDetectingViewDelegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMTapDetectingView : UIView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	id <IDMTapDetectingViewDelegate> __weak tapDelegate;
}

@property (nonatomic, weak) id <IDMTapDetectingViewDelegate> tapDelegate;

- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@protocol IDMTapDetectingViewDelegate <NSObject>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;

@end