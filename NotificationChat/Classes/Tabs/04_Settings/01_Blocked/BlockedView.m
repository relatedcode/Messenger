
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "AppConstant.h"

#import "BlockedView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface BlockedView()
{
	NSMutableArray *blockeds;
	NSIndexPath *indexSelected;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation BlockedView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Blocked users";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	blockeds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadBlockeds];
}

#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadBlockeds
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
	[query whereKey:PF_BLOCKED_USER equalTo:[PFUser currentUser]];
	[query whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];
	[query includeKey:PF_BLOCKED_USER2];
	[query setLimit:1000];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[blockeds removeAllObjects];
			[blockeds addObjectsFromArray:objects];
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
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
	return [blockeds count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

	PFObject *blocked = blockeds[indexPath.row];
	PFUser *user = blocked[PF_BLOCKED_USER2];
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
	indexSelected = indexPath;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:nil otherButtonTitles:@"Unblock user", nil];
	[action showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{

	}
}

@end
