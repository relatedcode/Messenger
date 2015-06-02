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

#import "JSQMediaItem.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface VideoMediaItem : JSQMediaItem <JSQMessageMediaData, NSCoding, NSCopying>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (nonatomic, strong) NSURL *fileURL;
@property (nonatomic, assign) BOOL isReadyToPlay;

@property (copy, nonatomic) UIImage *image;

- (instancetype)initWithFileURL:(NSURL *)fileURL isReadyToPlay:(BOOL)isReadyToPlay;

@end
