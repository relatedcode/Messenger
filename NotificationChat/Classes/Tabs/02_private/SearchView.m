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

#import "AppConstant.h"
#import "messages.h"
#import "utilities.h"

#import "SearchView.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SearchView()
{
	NSMutableArray *users;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SearchView

@synthesize viewHeader, searchBar;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Search";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self
																			action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUsers];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillAppear:animated];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
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

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchUsers:(NSString *)search_lower
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
	[query whereKey:PF_USER_FULLNAME_LOWER containsString:search_lower];
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
	PFUser *user1 = [PFUser currentUser];
	PFUser *user2 = users[indexPath.row];
	NSString *roomId = StartPrivateChat(user1, user2);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	ChatView *chatView = [[ChatView alloc] initWith:roomId];
	[self.navigationController pushViewController:chatView animated:YES];
}

#pragma mark - UISearchBarDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([searchText length] > 0)
	{
		[self searchUsers:[searchText lowercaseString]];
	}
	else [self loadUsers];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ setShowsCancelButton:YES animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ setShowsCancelButton:NO animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self searchBarCancelled];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[searchBar_ resignFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)searchBarCancelled
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	searchBar.text = @"";
	[searchBar resignFirstResponder];

	[self loadUsers];
}

@end
