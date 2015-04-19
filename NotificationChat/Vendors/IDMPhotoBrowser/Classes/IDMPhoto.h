//
//  IDMPhoto.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 17/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import "IDMPhotoProtocol.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface IDMPhoto : NSObject <IDMPhoto>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, strong) NSURL *photoURL;

+ (IDMPhoto *)photoWithImage:(UIImage *)image;

+ (NSArray *)photosWithImages:(NSArray *)imagesArray;

- (id)initWithImage:(UIImage *)image;

@end

