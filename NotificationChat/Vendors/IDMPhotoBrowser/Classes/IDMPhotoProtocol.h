//
//  IDMPhotoProtocol.h
//  IDMPhotoBrowser
//
//  Created by Michael Waterfall on 02/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "IDMPBConstants.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@protocol IDMPhoto <NSObject>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@required

- (UIImage *)underlyingImage;

- (void)unloadUnderlyingImage;

@end
