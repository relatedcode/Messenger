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

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "FacebookFriendsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FacebookFriendsView()
{
	NSMutableArray *users;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation FacebookFriendsView

@synthesize delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Facebook Friends";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																			action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadFacebook];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([FBSession.activeSession isOpen] == NO) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	FBRequest *request = [FBRequest requestForMyFriends];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if (error == nil)
		{
			NSMutableArray *fbids = [[NSMutableArray alloc] init];
			NSDictionary *userData = (NSDictionary *)result;
			NSArray *fbusers = [userData objectForKey:@"data"];
			for (NSDictionary *fbuser in fbusers)
			{
				[fbids addObject:[fbuser valueForKey:@"id"]];
			}

			PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
			[query whereKey:PF_USER_FACEBOOKID containedIn:fbids];
			[query orderByAscending:PF_USER_FULLNAME];
			[query setLimit:1000];
			[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
			{
				if (error == nil)
				{
					[users removeAllObjects];
					[users addObjectsFromArray:objects];
					[self.tableView reloadData];
				}
				else [ProgressHUD showError:@"Network error."];
			}];
		}
		else [ProgressHUD showError:@"Facebook request error."];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
	return [users count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	PFUser *user = users[indexPath.row];
	cell.textLabel.text = user[PF_USER_FULLNAME];

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil) [delegate didSelectFacebookUser:users[indexPath.row]];
	}];
}

@end
