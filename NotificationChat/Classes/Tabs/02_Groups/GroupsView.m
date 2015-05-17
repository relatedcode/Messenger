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

#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "PFUser+Util.h"

#import "AppConstant.h"
#import "common.h"
#import "group.h"
#import "recent.h"

#import "GroupsView.h"
#import "CreateGroupView.h"
#import "GroupSettingsView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface GroupsView()
{
	NSMutableArray *groups;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation GroupsView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_groups"]];
		self.tabBarItem.title = @"Groups";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Groups";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
																						   action:@selector(actionNew)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(loadGroups) forControlEvents:UIControlEventValueChanged];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	groups = [[NSMutableArray alloc] init];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadGroups];
	}
	else LoginUser(self);
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadGroups
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	PFQuery *query = [PFQuery queryWithClassName:PF_GROUP_CLASS_NAME];
	[query whereKey:PF_GROUP_MEMBERS equalTo:user.objectId];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[groups removeAllObjects];
			[groups addObjectsFromArray:objects];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
		[self.refreshControl endRefreshing];
	}];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionNew
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CreateGroupView *createGroupView = [[CreateGroupView alloc] init];
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:createGroupView];
	[self presentViewController:navController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[groups removeAllObjects];
	[self.tableView reloadData];
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
	return [groups count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	PFObject *group = groups[indexPath.row];
	cell.textLabel.text = group[PF_GROUP_NAME];

	cell.detailTextLabel.text = [NSString stringWithFormat:@"%d members", (int) [group[PF_GROUP_MEMBERS] count]];
	cell.detailTextLabel.textColor = [UIColor lightGrayColor];

	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFObject *group = groups[indexPath.row];
	[groups removeObject:group];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user1 = [PFUser currentUser];
	PFUser *user2 = group[PF_GROUP_USER];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([user1 isEqualTo:user2]) RemoveGroupItem(group); else RemoveGroupMember(group, user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	GroupSettingsView *groupSettingsView = [[GroupSettingsView alloc] initWith:groups[indexPath.row]];
	groupSettingsView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:groupSettingsView animated:YES];
}

@end
