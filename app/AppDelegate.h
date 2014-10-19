//
// Copyright (c) 2014 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>

#import "GroupView.h"
#import "PrivateView.h"
#import "MessagesView.h"
#import "ProfileView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface AppDelegate : UIResponder <UIApplicationDelegate>
//-------------------------------------------------------------------------------------------------------------------------------------------------

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@property (strong, nonatomic) GroupView *groupView;
@property (strong, nonatomic) PrivateView *privateView;
@property (strong, nonatomic) MessagesView *messagesView;
@property (strong, nonatomic) ProfileView *profileView;

@end
