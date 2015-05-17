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

#import "SelectMultipleView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SelectMultipleView()
{
	NSMutableArray *users;
	NSMutableArray *sections;
	NSMutableArray *selection;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SelectMultipleView

@synthesize delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Select Multiple";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self
																						   action:@selector(actionDone)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users = [[NSMutableArray alloc] init];
	selection = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadUsers];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
	[query1 whereKey:PF_BLOCKED_USER1 equalTo:user];

	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query2 whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
	[query2 orderByAscending:PF_USER_FULLNAME];
	[query2 setLimit:1000];
	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users removeAllObjects];
			[users addObjectsFromArray:objects];
			[self setObjects:users];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setObjects:(NSArray *)objects
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (sections != nil) [sections removeAllObjects];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSInteger sectionTitlesCount = [[[UILocalizedIndexedCollation currentCollation] sectionTitles] count];
	sections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSUInteger i=0; i<sectionTitlesCount; i++)
	{
		[sections addObject:[NSMutableArray array]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *object in objects)
	{
		NSInteger section = [[UILocalizedIndexedCollation currentCollation] sectionForObject:object collationStringSelector:@selector(fullname)];
		[sections[section] addObject:object];
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([selection count] == 0) { [ProgressHUD showError:@"Please select some users."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self dismissViewControllerAnimated:YES completion:^{
		if (delegate != nil)
		{
			NSMutableArray *selectedUsers = [[NSMutableArray alloc] init];
			for (PFUser *user in users)
			{
				if ([selection containsObject:user.objectId])
					[selectedUsers addObject:user];
			}
			[delegate didSelectMultipleUsers:selectedUsers];
		}
	}];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [sections[section] count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([sections[section] count] != 0)
	{
		return [[[UILocalizedIndexedCollation currentCollation] sectionTitles] objectAtIndex:section];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[UILocalizedIndexedCollation currentCollation] sectionIndexTitles];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[UILocalizedIndexedCollation currentCollation] sectionForSectionIndexTitleAtIndex:index];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	NSMutableArray *userstemp = sections[indexPath.section];
	PFUser *user = userstemp[indexPath.row];
	cell.textLabel.text = user[PF_USER_FULLNAME];

	BOOL selected = [selection containsObject:user.objectId];
	cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *userstemp = sections[indexPath.section];
	PFUser *user = userstemp[indexPath.row];
	BOOL selected = [selection containsObject:user.objectId];
	if (selected) [selection removeObject:user.objectId]; else [selection addObject:user.objectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView reloadData];
}

@end
