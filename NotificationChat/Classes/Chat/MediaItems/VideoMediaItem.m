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

#import "VideoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface VideoMediaItem()

@property (strong, nonatomic) UIImageView *cachedVideoImageView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation VideoMediaItem

#pragma mark - Initialization

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	if (self)
	{
		_fileURL = [fileURL copy];
		_isReadyToPlay = isReadyToPlay;
		_cachedVideoImageView = nil;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_fileURL = nil;
	_cachedVideoImageView = nil;
}

#pragma mark - Setters

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setFileURL:(NSURL *)fileURL
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_fileURL = [fileURL copy];
	_cachedVideoImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setIsReadyToPlay:(BOOL)isReadyToPlay
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_isReadyToPlay = isReadyToPlay;
	_cachedVideoImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setImage:(UIImage *)image
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_image = [image copy];
	_cachedVideoImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
	_cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)mediaView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.fileURL == nil || !self.isReadyToPlay)
	{
		return nil;
	}
	
	if (self.cachedVideoImageView == nil)
	{
		CGSize size = [self mediaViewDisplaySize];
		BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;

		UIImage *playIcon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor whiteColor]];
		UIImageView *iconView = [[UIImageView alloc] initWithImage:playIcon];
		iconView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		iconView.contentMode = UIViewContentModeCenter;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
		imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds = YES;
		[imageView addSubview:iconView];

		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
		self.cachedVideoImageView = imageView;
	}
	
	return self.cachedVideoImageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)mediaHash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return self.hash;
}

#pragma mark - NSObject

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (![super isEqual:object])
	{
		return NO;
	}
	
	VideoMediaItem *videoItem = (VideoMediaItem *)object;
	
	return [self.fileURL isEqual:videoItem.fileURL] && self.isReadyToPlay == videoItem.isReadyToPlay;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)hash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return super.hash ^ self.fileURL.hash;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [NSString stringWithFormat:@"<%@: fileURL=%@, isReadyToPlay=%@, appliesMediaViewMaskAsOutgoing=%@>",
			[self class], self.fileURL, @(self.isReadyToPlay), @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
		_isReadyToPlay = [aDecoder decodeBoolForKey:NSStringFromSelector(@selector(isReadyToPlay))];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)aCoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
	[aCoder encodeBool:self.isReadyToPlay forKey:NSStringFromSelector(@selector(isReadyToPlay))];
}

#pragma mark - NSCopying

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone *)zone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	VideoMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL isReadyToPlay:self.isReadyToPlay];
	copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
	return copy;
}

@end
