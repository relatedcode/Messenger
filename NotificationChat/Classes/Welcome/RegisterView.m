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
#import "push.h"

#import "RegisterView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RegisterView()

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellPassword;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellEmail;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;
@property (strong, nonatomic) IBOutlet UITextField *fieldPassword;
@property (strong, nonatomic) IBOutlet UITextField *fieldEmail;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RegisterView

@synthesize cellName, cellPassword, cellEmail, cellButton;
@synthesize fieldName, fieldPassword, fieldEmail;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Register";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
	[self.tableView addGestureRecognizer:gestureRecognizer];
	gestureRecognizer.cancelsTouchesInView = NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	[fieldName becomeFirstResponder];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionRegister
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name		= fieldName.text;
	NSString *password	= fieldPassword.text;
	NSString *email		= [fieldEmail.text lowercaseString];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([name length] < 8)		{ [ProgressHUD showError:@"Name is too short."]; return; }
	if ([password length] == 0)	{ [ProgressHUD showError:@"Password must be set."]; return; }
	if ([email length] == 0)	{ [ProgressHUD showError:@"Email must be set."]; return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[ProgressHUD show:@"Please wait..." Interaction:NO];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser user];
	user.username = email;
	user.password = password;
	user.email = email;
	user[PF_USER_EMAILCOPY] = email;
	user[PF_USER_FULLNAME] = name;
	user[PF_USER_FULLNAME_LOWER] = [name lowercaseString];
	[user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			ParsePushUserAssign();
			[ProgressHUD showSuccess:@"Succeed."];
			[self dismissViewControllerAnimated:YES completion:nil];
		}
		else [ProgressHUD showError:error.userInfo[@"error"]];
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
	return 4;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.row == 0) return cellName;
	if (indexPath.row == 1) return cellPassword;
	if (indexPath.row == 2) return cellEmail;
	if (indexPath.row == 3) return cellButton;
	return nil;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.row == 3) [self actionRegister];
}

#pragma mark - UITextField delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)textFieldShouldReturn:(UITextField *)textField
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (textField == fieldName)
	{
		[fieldPassword becomeFirstResponder];
	}
	if (textField == fieldPassword)
	{
		[fieldEmail becomeFirstResponder];
	}
	if (textField == fieldEmail)
	{
		[self actionRegister];
	}
	return YES;
}

@end
