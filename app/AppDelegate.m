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

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

#import "AppConstant.h"

#import "AppDelegate.h"
#import "GroupView.h"
#import "PrivateView.h"
#import "ProfileView.h"
#import "NavigationController.h"

@implementation AppDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[Parse setApplicationId:@"ZpzAcELw53bsRGdN1ZNiDHTuPwT0QEvSQefQ8cUQ" clientKey:@"netW22vtS26ZmFaZi5rtqxYGSYdw9Xo89pdIyjkE"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFFacebookUtils initializeFacebook];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[PFImageView class];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

	NavigationController *nc1 = [[NavigationController alloc] initWithRootViewController:[[GroupView alloc] init]];
	NavigationController *nc2 = [[NavigationController alloc] initWithRootViewController:[[PrivateView alloc] init]];
	NavigationController *nc3 = [[NavigationController alloc] initWithRootViewController:[[ProfileView alloc] init]];

	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:nc1, nc2, nc3, nil];
	self.tabBarController.tabBar.barTintColor = COLOR_TABBAR_BACKGROUND;
	self.tabBarController.tabBar.tintColor = COLOR_TABBAR_LABEL;
	self.tabBarController.tabBar.translucent = NO;
	self.tabBarController.selectedIndex = 0;

	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillResignActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidEnterBackground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillEnterForeground:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationDidBecomeActive:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)applicationWillTerminate:(UIApplication *)application
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	
}

#pragma mark - Facebook responses

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
}

@end
