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

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSTimer *timer;
	BOOL isLoading;

	NSString *chatroom;

	NSMutableArray *users;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	UIImageView *outgoingBubbleImageView;
	UIImageView *incomingBubbleImageView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)chatroom_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	chatroom = chatroom_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";

	users = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];

	self.sender = [PFUser currentUser].objectId;

	outgoingBubbleImageView = [JSQMessagesBubbleImageFactory outgoingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	incomingBubbleImageView = [JSQMessagesBubbleImageFactory incomingMessageBubbleImageViewWithColor:[UIColor jsq_messageBubbleGreenColor]];

	isLoading = NO;
	[self loadMessages];
	timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];

	self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[timer invalidate];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (isLoading == NO)
	{
		isLoading = YES;
		JSQMessage *message_last = [messages lastObject];

		PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
		[query whereKey:PF_CHAT_ROOM equalTo:chatroom];
		if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
		[query includeKey:PF_CHAT_USER];
		[query orderByAscending:PF_CHAT_CREATEDAT];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				for (PFObject *object in objects)
				{
					PFUser *user = object[PF_CHAT_USER];
					[users addObject:user];

					JSQMessage *message = [[JSQMessage alloc] initWithText:object[PF_CHAT_TEXT] sender:user.objectId date:object.createdAt];
					[messages addObject:message];
				}
				if ([objects count] != 0) [self finishReceivingMessage];
			}
			else [ProgressHUD showError:@"Network error."];
			isLoading = NO;
		}];
	}
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text sender:(NSString *)sender date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
	object[PF_CHAT_ROOM] = chatroom;
	object[PF_CHAT_USER] = [PFUser currentUser];
	object[PF_CHAT_TEXT] = text;
	[object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			[JSQSystemSoundPlayer jsq_playMessageSentSound];
			[self loadMessages];
		}
		else [ProgressHUD showError:@"Network error"];;
	}];
	[self finishSendingMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didPressAccessoryButton");
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages objectAtIndex:indexPath.item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView bubbleImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return [[UIImageView alloc] initWithImage:outgoingBubbleImageView.image highlightedImage:outgoingBubbleImageView.highlightedImage];
	}
	else return [[UIImageView alloc] initWithImage:incomingBubbleImageView.image highlightedImage:incomingBubbleImageView.highlightedImage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIImageView *)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageViewForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [users objectAtIndex:indexPath.item];

	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blank_avatar"]];
	if (avatars[user.objectId] == nil)
	{
		PFFile *filePicture = user[PF_USER_THUMBNAIL];
		[filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
		{
			if (error == nil)
			{
				avatars[user.objectId] = [UIImage imageWithData:imageData];
				[imageView setImage:avatars[user.objectId]];
			}
		}];
	}
	else [imageView setImage:avatars[user.objectId]];

	imageView.layer.cornerRadius = imageView.frame.size.width/2;
	imageView.layer.masksToBounds = YES;

	return imageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = [messages objectAtIndex:indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		return nil;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:message.sender])
		{
			return nil;
		}
	}

	PFUser *user = [users objectAtIndex:indexPath.item];
	return [[NSAttributedString alloc] initWithString:user[PF_USER_FULLNAME]];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
	
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([message.sender isEqualToString:self.sender])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	
	cell.textView.linkTextAttributes = @{NSForegroundColorAttributeName:cell.textView.textColor,
										 NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle | NSUnderlinePatternSolid)};
	
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = [messages objectAtIndex:indexPath.item];
	if ([[message sender] isEqualToString:self.sender])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
		if ([[previousMessage sender] isEqualToString:[message sender]])
		{
			return 0.0f;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

@end
