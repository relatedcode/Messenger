
//-------------------------------------------------------------------------------------------------------------------------------------------------
void		CreateMessageItem			(PFUser *user, NSString *roomId, NSString *description);
void		DeleteMessageItem			(PFObject *message);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void		UpdateMessageCounter		(NSString *roomId, NSString *lastMessage);
void		ClearMessageCounter			(NSString *roomId);
