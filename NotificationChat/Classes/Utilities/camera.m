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

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import "camera.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL ShouldStartCamera(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeImage;
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera] containsObject:type])
	{
		cameraUI.mediaTypes = [NSArray arrayWithObject:type];
		cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;

		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
		{
			cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		}
		else if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront])
		{
			cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		}
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cameraUI.allowsEditing = canEdit;
	cameraUI.showsCameraControls = YES;
	cameraUI.delegate = target;
	[target presentViewController:cameraUI animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL ShouldStartPhotoLibrary(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
		 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeImage;
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		cameraUI.mediaTypes = [NSArray arrayWithObject:type];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
			 && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		cameraUI.mediaTypes = [NSArray arrayWithObject:type];
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cameraUI.allowsEditing = canEdit;
	cameraUI.delegate = target;
	[target presentViewController:cameraUI animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL ShouldStartVideoLibrary(id target, BOOL canEdit)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
		 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *type = (NSString *)kUTTypeMovie;
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
		&& [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypePhotoLibrary] containsObject:type])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		cameraUI.mediaTypes = [NSArray arrayWithObject:type];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
			 && [[UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:type])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		cameraUI.mediaTypes = [NSArray arrayWithObject:type];
	}
	else return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	cameraUI.allowsEditing = canEdit;
	cameraUI.delegate = target;
	[target presentViewController:cameraUI animated:YES completion:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return YES;
}
