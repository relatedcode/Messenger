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
#import "camera.h"
#import "pushnotification.h"
#import "utilities.h"

#import "ProfileView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ProfileView()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet PFImageView *imageUser;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellName;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellButton;

@property (strong, nonatomic) IBOutlet UITextField *fieldName;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ProfileView

@synthesize viewHeader, imageUser;
@synthesize cellName, cellButton;
@synthesize fieldName;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self)
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_profile"]];
		self.tabBarItem.title = @"Profile";
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Profile";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:self
																			action:@selector(actionLogout)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.tableView.tableHeaderView = viewHeader;
	self.tableView.separatorInset = UIEdgeInsetsZero;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.layer.cornerRadius = imageUser.frame.size.width / 2;
	imageUser.layer.masksToBounds = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{
		[self profileLoad];
	}
	else LoginUser(self);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dismissKeyboard
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self.view endEditing:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)profileLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];

	[imageUser setFile:user[PF_USER_PICTURE]];
	[imageUser loadInBackground];

	fieldName.text = user[PF_USER_FULLNAME];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionLogout
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
											   otherButtonTitles:@"Log out", nil];
	[action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		[PFUser logOut];
		ParsePushUserResign();
		PostNotification(NOTIFICATION_USER_LOGGED_OUT);

		imageUser.image = [UIImage imageNamed:@"blank_profile"];
		fieldName.text = @"";

		LoginUser(self);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionPhoto:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ShouldStartPhotoLibrary(self, YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionSave:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissKeyboard];

	if ([fieldName.text isEqualToString:@""] == NO)
	{
		[ProgressHUD show:@"Please wait..."];

		PFUser *user = [PFUser currentUser];
		user[PF_USER_FULLNAME] = fieldName.text;
		user[PF_USER_FULLNAME_LOWER] = [fieldName.text lowercaseString];

		[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
		{
			if (error == nil)
			{
				[ProgressHUD showSuccess:@"Saved."];
			}
			else [ProgressHUD showError:@"Network error."];
		}];
	}
	else [ProgressHUD showError:@"Name field must be set."];
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIImage *image = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (image.size.width > 140) image = ResizeImage(image, 140, 140);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
	[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	imageUser.image = image;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (image.size.width > 30) image = ResizeImage(image, 30, 30);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.6)];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	user[PF_USER_PICTURE] = filePicture;
	user[PF_USER_THUMBNAIL] = fileThumbnail;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) [ProgressHUD showError:@"Network error."];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.section == 0) return cellName;
	if (indexPath.section == 1) return cellButton;
	return nil;
}

@end
