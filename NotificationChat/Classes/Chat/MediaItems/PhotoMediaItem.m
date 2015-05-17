//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AppConstant.h"

#import "PhotoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PhotoMediaItem()

@property (strong, nonatomic) UIImageView *cachedImageView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation PhotoMediaItem

#pragma mark - Initialization

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithImage:(UIImage *)image Width:(NSNumber *)width Height:(NSNumber *)height
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	if (self)
	{
		_image = [image copy];
		_width = width;
		_height = height;
		_cachedImageView = nil;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_image = nil;
	_cachedImageView = nil;
}

#pragma mark - Setters

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setImage:(UIImage *)image
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_image = [image copy];
	_cachedImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setWidth:(NSNumber *)width
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_width = width;
	_cachedImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setHeight:(NSNumber *)height
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_height = height;
	_cachedImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
	_cachedImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)mediaView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.image == nil)
	{
		return nil;
	}

	if (self.cachedImageView == nil)
	{
		CGSize size = [self mediaViewDisplaySize];

		UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
		imageView.frame = CGRectMake(0, 0, size.width, size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds = YES;

		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:self.appliesMediaViewMaskAsOutgoing];
		self.cachedImageView = imageView;
	}

	return self.cachedImageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGSize)mediaViewDisplaySize
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CGFloat width = [self.width floatValue];
	CGFloat height = [self.height floatValue];
	CGFloat base = (width > 210) ? 210 : 100;
	return CGSizeMake(base, height*base/width);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)mediaHash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return self.hash;
}

#pragma mark - NSObject

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)hash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return super.hash ^ self.image.hash;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [NSString stringWithFormat:@"<%@: image=%@, width=%@, height=%@, appliesMediaViewMaskAsOutgoing=%@>",
			[self class], self.image, self.width, self.height, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_image = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(image))];
		_width = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(width))];
		_height = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(height))];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)aCoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.image forKey:NSStringFromSelector(@selector(image))];
	[aCoder encodeObject:self.width forKey:NSStringFromSelector(@selector(width))];
	[aCoder encodeObject:self.height forKey:NSStringFromSelector(@selector(height))];
}

#pragma mark - NSCopying

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone *)zone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PhotoMediaItem *copy = [[[self class] allocWithZone:zone] initWithImage:self.image Width:self.width Height:self.height];
	copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
	return copy;
}

@end
