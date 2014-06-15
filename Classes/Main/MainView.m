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
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "MainView.h"
#import "RoomView.h"
#import "ProfileView.h"
#import "WelcomeView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MainView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellChat;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellProfile;

@property (strong, nonatomic) IBOutlet UIButton *buttonChat;
@property (strong, nonatomic) IBOutlet UIButton *buttonProfile;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MainView

@synthesize cellChat, cellProfile;
@synthesize buttonChat, buttonProfile;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Main";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.separatorInset = UIEdgeInsetsZero;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	buttonChat.backgroundColor = HEXCOLOR(0xff3322ff);
	buttonProfile.backgroundColor = HEXCOLOR(0x205081ff);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionChat:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([PFUser currentUser] != nil)
	{
		RoomView *roomView = [[RoomView alloc] init];
		[self.navigationController pushViewController:roomView animated:YES];
	}
	else [self loginUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionProfile:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([PFUser currentUser] != nil)
	{
		ProfileView *profileView = [[ProfileView alloc] init];
		[self.navigationController pushViewController:profileView animated:YES];
	}
	else [self loginUser];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loginUser
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	WelcomeView *welcomeView = [[WelcomeView alloc] init];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeView];
	navigationController.navigationBar.translucent = NO;
	navigationController.navigationBar.barTintColor = HEXCOLOR(0x19C5FF00);
	navigationController.navigationBar.tintColor = [UIColor whiteColor];
	navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
	[self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.row == 0) return cellChat;
	if (indexPath.row == 1) return cellProfile;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

@end
