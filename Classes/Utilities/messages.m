
#import <Parse/Parse.h>

#import "AppConstant.h"

#import "messages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateMessageItem(PFUser *user, NSString *roomId, NSString *description)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_USER equalTo:user];
	[query whereKey:PF_MESSAGES_ROOMID equalTo:roomId];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] == 0)
			{
				PFObject *message = [PFObject objectWithClassName:PF_MESSAGES_CLASS_NAME];
				message[PF_MESSAGES_USER] = user;
				message[PF_MESSAGES_ROOMID] = roomId;
				message[PF_MESSAGES_DESCRIPTION] = description;
				message[PF_MESSAGES_LASTUSER] = [PFUser currentUser];
				message[PF_MESSAGES_LASTMESSAGE] = @"";
				message[PF_MESSAGES_COUNTER] = @0;
				message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];
				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error != nil) NSLog(@"CreateMessageItem save error.");
				}];
			}
		}
		else NSLog(@"CreateMessageItem query error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteMessageItem(PFObject *message)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil) NSLog(@"DeleteMessageItem delete error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateMessageCounter(NSString *roomId, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_ROOMID equalTo:roomId];
	query.limit = 1000;
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			for (PFObject *message in objects)
			{
				PFUser *user = message[PF_MESSAGES_USER];
				if ([user.objectId isEqualToString:[PFUser currentUser].objectId] == NO)
					[message incrementKey:PF_MESSAGES_COUNTER byAmount:@1];
				//---------------------------------------------------------------------------------------------------------------------------------
				message[PF_MESSAGES_LASTUSER] = [PFUser currentUser];
				message[PF_MESSAGES_LASTMESSAGE] = lastMessage;
				message[PF_MESSAGES_UPDATEDACTION] = [NSDate date];
				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error != nil) NSLog(@"UpdateMessageCounter save error.");
				}];
			}
		}
		else NSLog(@"UpdateMessageCounter query error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearMessageCounter(NSString *roomId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
	[query whereKey:PF_MESSAGES_ROOMID equalTo:roomId];
	[query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			for (PFObject *message in objects)
			{
				message[PF_MESSAGES_COUNTER] = @0;
				[message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
				{
					if (error != nil) NSLog(@"ClearMessageCounter save error.");
				}];
			}
		}
		else NSLog(@"ClearMessageCounter query error.");
	}];
}
