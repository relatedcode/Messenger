//
//  IDMTapDetectingImageView.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 04/11/2009.
//  Copyright 2009 d3i. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IDMTapDetectingImageViewDelegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMTapDetectingImageView : UIImageView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	id <IDMTapDetectingImageViewDelegate> __weak tapDelegate;
}

@property (nonatomic, weak) id <IDMTapDetectingImageViewDelegate> tapDelegate;

- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;

@end

//-------------------------------------------------------------------------------------------------------------------------------------------------
@protocol IDMTapDetectingImageViewDelegate <NSObject>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;

@end