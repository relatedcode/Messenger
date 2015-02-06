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

#import "MessagesView.h"
#import "MessagesCell.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface MessagesView()
{
	NSMutableArray *messages;
	UIRefreshControl *refreshControl;
}

@property (strong, nonatomic) IBOutlet UITableView *tableMessages;
@property (strong, nonatomic) IBOutlet UIView *viewEmpty;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation MessagesView

@synthesize tableMessages, viewEmpty;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_messages"]];
		self.tabBarItem.title = @"Messages";
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
	self.title = @"Messages";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[tableMessages registerNib:[UINib nibWithNibName:@"MessagesCell" bundle:nil] forCellReuseIdentifier:@"MessagesCell"];
	tableMessages.tableFooterView = [[UIView alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	refreshControl = [[UIRefreshControl alloc] init];
	[refreshControl addTarget:self action:@selector(loadMessages) forControlEvents:UIControlEventValueChanged];
	[tableMessages addSubview:refreshControl];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	messages = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	viewEmpty.hidden = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self loadMessages];
	}
	else LoginUser(self);
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([PFUser currentUser] != nil)
	{
		PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
		[query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
		[query includeKey:PF_MESSAGES_LASTUSER];
		[query orderByDescending:PF_MESSAGES_UPDATEDACTION];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				[messages removeAllObjects];
				[messages addObjectsFromArray:objects];
				[tableMessages reloadData];
				[self updateEmptyView];
				[self updateTabCounter];
			}
			else [ProgressHUD showError:@"Network error."];
			[refreshControl endRefreshing];
		}];
	}
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateEmptyView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	viewEmpty.hidden = ([messages count] != 0);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int total = 0;
	for (PFObject *message in messages)
	{
		total += [message[PF_MESSAGES_COUNTER] intValue];
	}
	UITabBarItem *item = self.tabBarController.tabBar.items[2];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[messages removeAllObjects];
	[tableMessages reloadData];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITabBarItem *item = self.tabBarController.tabBar.items[2];
	item.badgeValue = nil;
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
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MessagesCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessagesCell" forIndexPath:indexPath];
	[cell bindData:messages[indexPath.row]];
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
	DeleteMessageItem(messages[indexPath.row]);
	[messages removeObjectAtIndex:indexPath.row];
	[tableMessages deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	[self updateEmptyView];
	[self updateTabCounter];
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFObject *message = messages[indexPath.row];
	ChatView *chatView = [[ChatView alloc] initWith:message[PF_MESSAGES_ROOMID]];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

@end
