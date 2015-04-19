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

#import <AVFoundation/AVFoundation.h>

#import "video.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
UIImage* VideoThumbnail(NSURL *video)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
	AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	generator.appliesPreferredTrackTransform = YES;
	CMTime time = [asset duration]; time.value = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSError *error = nil;
	CMTime actualTime;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CGImageRef image = [generator copyCGImageAtTime:time actualTime:&actualTime error:&error];
	UIImage *thumbnail = [[UIImage alloc] initWithCGImage:image];
	CGImageRelease(image);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return thumbnail;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSNumber* VideoDuration(NSURL *video)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AVURLAsset *asset = [AVURLAsset URLAssetWithURL:video options:nil];
	int duration = (int) round(CMTimeGetSeconds(asset.duration));
	return [NSNumber numberWithInt:duration];
}
